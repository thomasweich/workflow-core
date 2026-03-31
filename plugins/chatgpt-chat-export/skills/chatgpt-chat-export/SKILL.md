---
name: chatgpt-chat-export
description: Export ChatGPT web chats through Chrome DevTools MCP into repo-tracked markdown under chats/. Use when you need the 10 most recent chat titles, a full transcript by URL or exact recent title, or the last assistant answer rendered with stable message headings and preserved code fences.
---

# ChatGPT Chat Export

## Use this skill for
- Listing the 10 most recent visible ChatGPT conversation titles and URLs.
- Exporting one full ChatGPT thread to `chats/`.
- Exporting only the last assistant answer from one ChatGPT thread.

## Prerequisites
- Chrome DevTools MCP must be connected to a browser that has an authenticated `chatgpt.com` session.
- Use the browser page directly when the user gives an exact conversation URL.
- Use recent-title lookup only against the visible recent sidebar entries; do not guess across ambiguous matches.

## Workflow
1. Resolve the target chat.
   - If the user gave a ChatGPT conversation URL, navigate to it directly.
   - If the user gave a title, first list recent visible chats and require an exact match.
   - If multiple recent chats share the same title, stop and report the ambiguous URLs.
2. Verify login state.
   - If `chatgpt.com` is not logged in or the page cannot show recent chats/current thread content, stop with an actionable error.
3. Prefer the primary extraction path.
   - Read `references/browser-workflow.md`.
   - Use the current-DOM snippet there, which targets the visible thread via `[data-message-author-role]`.
4. Fall back only when needed.
   - If the DOM path cannot preserve enough structure, try the private in-page fetch snippet from `references/browser-workflow.md`.
   - Keep that fallback scoped to the current page and current visible thread only.
   - If both paths fail or return zero messages, stop and report the failure; do not write a partial export.
5. Render deterministic markdown.
   - Pipe the normalized JSON payload to:
     - `python3 shared/workflow-core/plugins/chatgpt-chat-export/scripts/render_chatgpt_export.py --input - --output-dir chats`
   - For last-answer-only exports, add:
     - `--mode last-answer`
6. Report the output path.
   - Return the saved file path and summarize what was exported.

## Output rules
- Default output directory is `chats/`.
- Full-chat filename:
  - `<slug>--<conversation_id>.md`
- Last-answer filename:
  - `<slug>--<conversation_id>.last-answer.md`
- Message sections must stay explicit:
  - `## Message 0001 · User`
  - `## Message 0002 · Assistant`
- Preserve fenced code blocks and message ordering.

## Recent chat listing
- Use the recent-chat DOM snippet from `references/browser-workflow.md`.
- Return titles inline by default; do not save them to a file unless the user explicitly asks.
- Do not include non-chat items like `Home`, `Images`, or `Apps`.

## Ambiguity and failure handling
- Title resolution must be exact against recent visible entries.
- If the title is ambiguous, return the matching titles and URLs and stop.
- If extraction returns incomplete or malformed data, do not write a partial markdown file.
- If login state is missing, tell the user to open a logged-in `chatgpt.com` tab and retry.
- Prefer canonical conversation URLs of the form `https://chatgpt.com/c/<conversation_id>` in saved exports.

## Read next
- `references/browser-workflow.md` for the browser-side snippets and normalized payload schema.
