from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from chatgpt_export_lib import normalize_export_payload, render_export_markdown


def test_renderer_preserves_code_fences_and_message_headings() -> None:
    payload = normalize_export_payload(
        {
            "title": "Demo Chat",
            "source_url": "https://chatgpt.com/c/abc123",
            "conversation_id": "abc123",
            "mode": "full",
            "messages": [
                {"role": "user", "markdown": "Please show me a Python example."},
                {
                    "role": "assistant",
                    "parts": [
                        {"type": "paragraph", "text": "Here is one:"},
                        {"type": "code_block", "language": "python", "text": "print('hello')"},
                    ],
                },
            ],
        }
    )

    markdown = render_export_markdown(payload)

    assert "## Message 0001 · User" in markdown
    assert "## Message 0002 · Assistant" in markdown
    assert "```python\nprint('hello')\n```" in markdown
    assert 'conversation_id: "abc123"' in markdown


def test_renderer_namespaces_footnotes_per_message() -> None:
    payload = normalize_export_payload(
        {
            "title": "Footnotes",
            "source_url": "https://chatgpt.com/c/foot",
            "conversation_id": "foot",
            "mode": "full",
            "messages": [
                {"role": "assistant", "markdown": "One[^1]\n\n[^1]: First footnote"},
                {"role": "assistant", "markdown": "Two[^1]\n\n[^1]: Second footnote"},
            ],
        }
    )

    markdown = render_export_markdown(payload)

    assert "[^m0001-1]" in markdown
    assert "[^m0002-1]" in markdown
    assert "[^1]:" not in markdown
