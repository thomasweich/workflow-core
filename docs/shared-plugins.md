---
summary: How consumer repositories should expose workflow-core-owned Codex plugins through local marketplace metadata.
type: doc
read_when:
  - Moving a repo-local plugin into workflow-core.
  - Wiring a consumer repo to use a shared plugin from `shared/workflow-core/plugins/`.
code_paths:
  - plugins/chatgpt-chat-export/**
  - docs/workflow-core-usage.md
---

# Shared Plugins

## Ownership Model
- Shared plugin implementation lives in `shared/workflow-core/plugins/<plugin-name>/`.
- Consumer repos keep local marketplace metadata in `.agents/plugins/marketplace.json`.
- Consumer repos may keep local feature docs about how they use a shared plugin, but shared implementation docs and plugin assets should live in `workflow-core`.

## Consumer Integration Steps
1. Ensure `workflow-core` is checked out at `shared/workflow-core/`.
2. Point the consumer marketplace entry at the shared plugin path.
3. Keep any consumer-specific storage/output policy local.
4. Do not copy the plugin into the consumer repo unless the plugin is intentionally forked.

## Marketplace Entry Pattern

```json
{
  "name": "chatgpt-chat-export",
  "source": {
    "source": "local",
    "path": "./shared/workflow-core/plugins/chatgpt-chat-export"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity"
}
```

## `chatgpt-chat-export` Example
- Shared plugin path:
  - `shared/workflow-core/plugins/chatgpt-chat-export`
- Renderer CLI from the consumer repo root:
  - `python3 shared/workflow-core/plugins/chatgpt-chat-export/scripts/render_chatgpt_export.py --input - --output-dir chats`
- Shared browser workflow reference:
  - `shared/workflow-core/plugins/chatgpt-chat-export/references/browser-workflow.md`

## Consumer Responsibilities
- Own the local `.agents/plugins/marketplace.json` file.
- Own any repo-specific output directory policy like `chats/`.
- Own any repo-specific docs that describe where exported files are stored locally.
- Run plugin tests from the shared path when modifying the shared plugin.
