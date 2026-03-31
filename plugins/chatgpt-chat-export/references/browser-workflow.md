# Browser Workflow

This plugin expects a normalized JSON payload that the renderer script can turn into stable markdown.

## Normalized payload shape

```json
{
  "title": "Human-AI Collaboration Challenges",
  "source_url": "https://chatgpt.com/c/69cb9864-b944-8397-a456-823d4147826a",
  "conversation_id": "69cb9864-b944-8397-a456-823d4147826a",
  "exported_at": "2026-03-31T10:06:50Z",
  "mode": "full",
  "messages": [
    {
      "role": "user",
      "markdown": "User markdown content"
    },
    {
      "role": "assistant",
      "markdown": "Assistant markdown content with ```code fences```"
    }
  ]
}
```

Accepted message alternatives:
- `markdown`
- `content`
- `text`
- `parts` where parts can be `markdown`, `paragraph`, `code_block`, `blockquote`, `heading`, `bullet_list`, `ordered_list`, or `thematic_break`

## Recent visible chats snippet

Use this in the current logged-in `chatgpt.com` page context to list recent visible chats:

```js
() => {
  const seen = new Set();
  return Array.from(document.querySelectorAll('a[href^="/c/"]'))
    .map((link) => {
      const title = (link.textContent || "").replace(/\s+/g, " ").trim();
      const href = link.getAttribute("href");
      if (!title || !href) return null;
      const url = new URL(href, location.origin).href;
      const key = `${title}::${url}`;
      if (seen.has(key)) return null;
      seen.add(key);
      return { title, url };
    })
    .filter(Boolean)
    .slice(0, 10);
}
```

## Current conversation id snippet

```js
() => {
  const match = location.pathname.match(/\/c\/([^/?#]+)/);
  return match ? match[1] : null;
}
```

## Primary extraction path: current visible DOM

Use this on the current conversation page. It targets the current ChatGPT thread DOM shape,
which exposes each message root with `data-message-author-role`.

```js
() => {
  const conversationId = (location.pathname.match(/\/c\/([^/?#]+)/) || [null, null])[1];
  const canonicalUrl = conversationId ? `${location.origin}/c/${conversationId}` : location.href;
  const messageNodes = Array.from(document.querySelectorAll("[data-message-author-role]"));

  const messages = messageNodes
    .map((node) => {
      const role = node.getAttribute("data-message-author-role");
      if (role !== "user" && role !== "assistant") {
        return null;
      }

      const codeBlocks = Array.from(node.querySelectorAll("pre code")).map((code) => {
        const language =
          Array.from(code.classList).find((value) => value.startsWith("language-"))?.replace("language-", "") || "";
        return {
          type: "code_block",
          language,
          text: code.textContent || "",
        };
      });

      const clone = node.cloneNode(true);
      clone.querySelectorAll("pre").forEach((pre) => pre.remove());
      const textContent = (clone.innerText || "").replace(/\n{3,}/g, "\n\n").trim();

      if (codeBlocks.length > 0) {
        const parts = textContent ? [{ type: "paragraph", text: textContent }, ...codeBlocks] : codeBlocks;
        return { role, parts };
      }

      if (!textContent) {
        return null;
      }

      return { role, markdown: textContent };
    })
    .filter(Boolean);

  return {
    ok: messages.length > 0,
    error: messages.length > 0 ? null : "Current thread DOM did not expose any user or assistant messages.",
    payload: {
      title: document.title.replace(/\s*\|\s*ChatGPT\s*$/i, "").trim() || "untitled-chat",
      source_url: canonicalUrl,
      conversation_id: conversationId || "unknown-conversation",
      exported_at: new Date().toISOString(),
      mode: "full",
      messages,
    },
  };
}
```

## Optional fallback path: private in-page fetch

Use this only when the DOM path cannot preserve enough structure and the current ChatGPT
session still exposes the private conversation endpoint. This endpoint is brittle and may
return `404` even while the page is fully visible and logged in.

```js
async () => {
  const match = location.pathname.match(/\/c\/([^/?#]+)/);
  if (!match) {
    return { ok: false, error: "Not on a conversation URL." };
  }

  const conversationId = match[1];
  const response = await fetch(`/backend-api/conversation/${conversationId}`, {
    credentials: "include",
  });

  if (!response.ok) {
    return {
      ok: false,
      error: `Fetch failed with ${response.status}.`,
      status: response.status,
    };
  }

  const canonicalUrl = `${location.origin}/c/${conversationId}`;
  const payload = await response.json();
  const mapping = payload?.mapping || {};
  const nodes = Object.values(mapping)
    .map((node) => node?.message)
    .filter(Boolean)
    .filter((message) => {
      const author = message?.author?.role;
      return author === "user" || author === "assistant";
    })
    .sort((a, b) => (a?.create_time || 0) - (b?.create_time || 0))
    .map((message) => {
      const role = message.author.role;
      const parts = Array.isArray(message?.content?.parts)
        ? message.content.parts.filter((part) => typeof part === "string")
        : [];
      return {
        role,
        markdown: parts.join("\n\n").trim(),
      };
    })
    .filter((message) => message.markdown.length > 0);

  return {
    ok: nodes.length > 0,
    error: nodes.length > 0 ? null : "Private conversation fetch returned no visible user or assistant messages.",
    payload: {
      title: document.title.replace(/\s*\|\s*ChatGPT\s*$/i, "").trim() || "untitled-chat",
      source_url: canonicalUrl,
      conversation_id: conversationId,
      exported_at: new Date().toISOString(),
      mode: "full",
      messages: nodes,
    },
  };
}
```

## Renderer invocation

Render a full chat from normalized JSON on stdin:

```bash
python3 shared/workflow-core/plugins/chatgpt-chat-export/scripts/render_chatgpt_export.py --input - --output-dir chats
```

Render last assistant answer only:

```bash
python3 shared/workflow-core/plugins/chatgpt-chat-export/scripts/render_chatgpt_export.py --input - --output-dir chats --mode last-answer
```
