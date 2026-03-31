from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

ALLOWED_ROLES = {"user", "assistant", "system", "tool"}
BLOCK_PART_TYPES = {
    "markdown",
    "paragraph",
    "heading",
    "bullet_list",
    "ordered_list",
    "blockquote",
    "code_block",
    "thematic_break",
}
INLINE_FOOTNOTE_RE = re.compile(r"\[\^([^\]\s]+)\]")
FOOTNOTE_DEF_RE = re.compile(r"^\[\^([^\]\s]+)\]:(\s*)")


def slugify_title(title: str) -> str:
    text = (title or "").strip().lower()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    text = re.sub(r"-{2,}", "-", text).strip("-")
    return text or "untitled-chat"


def build_output_filename(title: str, conversation_id: str, mode: str) -> str:
    slug = slugify_title(title)
    suffix = ".last-answer.md" if mode == "last-answer" else ".md"
    return f"{slug}--{conversation_id}{suffix}"


def build_output_path(output_dir: str | Path, title: str, conversation_id: str, mode: str) -> Path:
    return Path(output_dir) / build_output_filename(title, conversation_id, mode)


def normalize_export_payload(payload: dict[str, Any], override_mode: str | None = None) -> dict[str, Any]:
    conversation_id = str(payload.get("conversation_id") or "").strip()
    if not conversation_id:
        raise ValueError("conversation_id is required")

    raw_messages = payload.get("messages") or payload.get("items")
    if not isinstance(raw_messages, list) or not raw_messages:
        raise ValueError("messages must be a non-empty list")

    normalized_messages = [normalize_message(message) for message in raw_messages]
    mode = override_mode or str(payload.get("mode") or "full").strip()
    if mode not in {"full", "last-answer"}:
        raise ValueError("mode must be 'full' or 'last-answer'")

    if mode == "last-answer":
        assistant_messages = [message for message in normalized_messages if message["role"] == "assistant"]
        if not assistant_messages:
            raise ValueError("last-answer export requires at least one assistant message")
        normalized_messages = [assistant_messages[-1]]

    title = str(payload.get("title") or conversation_id).strip() or conversation_id
    source_url = canonicalize_source_url(str(payload.get("source_url") or "").strip(), conversation_id)
    exported_at = str(payload.get("exported_at") or current_timestamp()).strip()

    return {
        "title": title,
        "source_url": source_url,
        "conversation_id": conversation_id,
        "exported_at": exported_at,
        "mode": mode,
        "message_count": len(normalized_messages),
        "messages": normalized_messages,
    }


def canonicalize_source_url(source_url: str, conversation_id: str) -> str:
    if not source_url:
        return ""
    if not conversation_id:
        return source_url

    parsed = urlparse(source_url)
    if parsed.scheme not in {"http", "https"}:
        return source_url
    if parsed.netloc != "chatgpt.com":
        return source_url
    if parsed.path != f"/c/{conversation_id}":
        return source_url
    return f"https://chatgpt.com/c/{conversation_id}"


def normalize_message(message: dict[str, Any]) -> dict[str, Any]:
    role = str(message.get("role") or "").strip().lower()
    if role not in ALLOWED_ROLES:
        raise ValueError(f"unsupported role: {role or '<empty>'}")

    direct_markdown = first_present_string(message, ("markdown", "content", "text"))
    if direct_markdown is not None:
        return {"role": role, "markdown": direct_markdown}

    parts = message.get("parts")
    if not isinstance(parts, list) or not parts:
        raise ValueError("message must provide markdown/content/text or a non-empty parts list")

    return {"role": role, "parts": [normalize_part(part) for part in parts]}


def first_present_string(message: dict[str, Any], keys: tuple[str, ...]) -> str | None:
    for key in keys:
        value = message.get(key)
        if isinstance(value, str):
            return value
    return None


def normalize_part(part: dict[str, Any]) -> dict[str, Any]:
    part_type = str(part.get("type") or "").strip()
    if part_type not in BLOCK_PART_TYPES:
        raise ValueError(f"unsupported part type: {part_type or '<empty>'}")

    if part_type in {"markdown", "paragraph", "blockquote"}:
        return {"type": part_type, "text": str(part.get("text") or "")}
    if part_type == "heading":
        level = int(part.get("level") or 2)
        return {"type": "heading", "level": max(1, min(level, 6)), "text": str(part.get("text") or "")}
    if part_type in {"bullet_list", "ordered_list"}:
        items = part.get("items")
        if not isinstance(items, list) or not all(isinstance(item, str) for item in items):
            raise ValueError(f"{part_type} requires string items")
        return {"type": part_type, "items": items}
    if part_type == "code_block":
        return {
            "type": "code_block",
            "language": str(part.get("language") or "").strip(),
            "text": str(part.get("text") or ""),
        }
    return {"type": "thematic_break"}


def render_export_markdown(payload: dict[str, Any]) -> str:
    lines = [
        "---",
        f"title: {yaml_quote(payload['title'])}",
        f"source_url: {yaml_quote(payload['source_url'])}",
        f"conversation_id: {yaml_quote(payload['conversation_id'])}",
        f"exported_at: {yaml_quote(payload['exported_at'])}",
        f"mode: {yaml_quote(payload['mode'])}",
        f"message_count: {payload['message_count']}",
        "---",
        "",
    ]

    for index, message in enumerate(payload["messages"], start=1):
        body = namespace_footnotes(render_message_body(message), f"m{index:04d}")
        lines.append(f"## Message {index:04d} · {message['role'].title()}")
        lines.append("")
        lines.append(body or "_Empty message._")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def render_message_body(message: dict[str, Any]) -> str:
    if "markdown" in message:
        return str(message["markdown"]).strip()
    parts = [render_part(part) for part in message["parts"]]
    return "\n\n".join(part for part in parts if part.strip()).strip()


def render_part(part: dict[str, Any]) -> str:
    part_type = part["type"]
    if part_type in {"markdown", "paragraph"}:
        return part["text"].strip()
    if part_type == "heading":
        return f"{'#' * part['level']} {part['text'].strip()}".rstrip()
    if part_type == "bullet_list":
        return "\n".join(f"- {item}" for item in part["items"])
    if part_type == "ordered_list":
        return "\n".join(f"{index}. {item}" for index, item in enumerate(part["items"], start=1))
    if part_type == "blockquote":
        return "\n".join(f"> {line}" if line else ">" for line in part["text"].splitlines())
    if part_type == "code_block":
        fence = f"```{part['language']}".rstrip()
        return f"{fence}\n{part['text']}\n```"
    return "---"


def namespace_footnotes(markdown: str, prefix: str) -> str:
    if not markdown:
        return markdown

    namespaced_lines: list[str] = []
    in_fence = False
    fence_marker = ""

    for line in markdown.splitlines():
        stripped = line.lstrip()
        if stripped.startswith(("```", "~~~")):
            marker = stripped[:3]
            if not in_fence:
                in_fence = True
                fence_marker = marker
            elif stripped.startswith(fence_marker):
                in_fence = False
                fence_marker = ""
            namespaced_lines.append(line)
            continue

        if in_fence:
            namespaced_lines.append(line)
            continue

        line = FOOTNOTE_DEF_RE.sub(lambda match: f"[^{prefix}-{match.group(1)}]:{match.group(2)}", line)
        line = INLINE_FOOTNOTE_RE.sub(lambda match: f"[^{prefix}-{match.group(1)}]", line)
        namespaced_lines.append(line)

    return "\n".join(namespaced_lines)


def yaml_quote(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def current_timestamp() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
