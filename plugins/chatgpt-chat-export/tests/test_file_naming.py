from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from chatgpt_export_lib import build_output_filename, build_output_path, slugify_title


def test_slugify_title_normalizes_to_kebab_case() -> None:
    assert slugify_title("  Human + AI Collaboration!  ") == "human-ai-collaboration"
    assert slugify_title("###") == "untitled-chat"


def test_output_filename_uses_last_answer_suffix() -> None:
    assert build_output_filename("Demo Chat", "abc123", "full") == "demo-chat--abc123.md"
    assert build_output_filename("Demo Chat", "abc123", "last-answer") == "demo-chat--abc123.last-answer.md"


def test_output_path_joins_output_dir_and_filename() -> None:
    assert build_output_path("chats", "Demo Chat", "abc123", "full") == Path("chats/demo-chat--abc123.md")
