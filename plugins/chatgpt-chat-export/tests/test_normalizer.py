from pathlib import Path
import sys

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from chatgpt_export_lib import canonicalize_source_url, normalize_export_payload


def test_normalizer_accepts_direct_content_field() -> None:
    payload = normalize_export_payload(
        {
            "title": "Content field",
            "source_url": "https://chatgpt.com/c/content",
            "conversation_id": "content",
            "messages": [
                {"role": "user", "content": "hello"},
                {"role": "assistant", "markdown": "world"},
            ],
        }
    )

    assert payload["mode"] == "full"
    assert payload["message_count"] == 2
    assert payload["messages"][0]["markdown"] == "hello"


def test_normalizer_last_answer_mode_keeps_only_last_assistant_message() -> None:
    payload = normalize_export_payload(
        {
            "title": "Last answer",
            "source_url": "https://chatgpt.com/c/last",
            "conversation_id": "last",
            "messages": [
                {"role": "user", "markdown": "first"},
                {"role": "assistant", "markdown": "answer one"},
                {"role": "user", "markdown": "second"},
                {"role": "assistant", "markdown": "answer two"},
            ],
        },
        override_mode="last-answer",
    )

    assert payload["mode"] == "last-answer"
    assert payload["message_count"] == 1
    assert payload["messages"][0]["markdown"] == "answer two"


def test_normalizer_last_answer_requires_assistant_message() -> None:
    with pytest.raises(ValueError, match="last-answer export requires at least one assistant message"):
        normalize_export_payload(
            {
                "title": "Last answer",
                "source_url": "https://chatgpt.com/c/last",
                "conversation_id": "last",
                "messages": [{"role": "user", "markdown": "only user"}],
            },
            override_mode="last-answer",
        )


def test_normalizer_canonicalizes_chatgpt_conversation_source_url() -> None:
    payload = normalize_export_payload(
        {
            "title": "Canonical source",
            "source_url": "https://chatgpt.com/c/thread-123?src=history_search",
            "conversation_id": "thread-123",
            "messages": [{"role": "assistant", "markdown": "hello"}],
        }
    )

    assert payload["source_url"] == "https://chatgpt.com/c/thread-123"


def test_canonicalize_source_url_preserves_non_matching_urls() -> None:
    assert canonicalize_source_url("https://example.com/c/thread-123?src=history_search", "thread-123") == (
        "https://example.com/c/thread-123?src=history_search"
    )
    assert canonicalize_source_url("https://chatgpt.com/share/thread-123", "thread-123") == (
        "https://chatgpt.com/share/thread-123"
    )


def test_normalizer_rejects_missing_conversation_id() -> None:
    with pytest.raises(ValueError, match="conversation_id is required"):
        normalize_export_payload({"messages": [{"role": "user", "markdown": "hi"}]})
