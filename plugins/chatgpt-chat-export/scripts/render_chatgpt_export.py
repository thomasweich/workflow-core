from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from chatgpt_export_lib import build_output_path, normalize_export_payload, render_export_markdown


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Render normalized ChatGPT export payloads into markdown.")
    parser.add_argument("--input", default="-", help="JSON payload path or '-' for stdin")
    parser.add_argument("--output-dir", default="chats", help="Output directory for generated markdown")
    parser.add_argument("--output", help="Explicit output file path; overrides --output-dir filename generation")
    parser.add_argument(
        "--mode",
        choices=("full", "last-answer"),
        help="Override payload mode before rendering",
    )
    return parser.parse_args()


def read_payload(input_path: str) -> dict:
    if input_path == "-":
        return json.load(sys.stdin)
    with Path(input_path).open("r", encoding="utf-8") as handle:
        return json.load(handle)


def main() -> int:
    args = parse_args()
    payload = normalize_export_payload(read_payload(args.input), override_mode=args.mode)
    output_path = Path(args.output) if args.output else build_output_path(
        args.output_dir,
        payload["title"],
        payload["conversation_id"],
        payload["mode"],
    )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(render_export_markdown(payload), encoding="utf-8")
    print(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
