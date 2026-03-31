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

## Primary extraction path: in-page fetch

This snippet assumes the current page is already on the target conversation URL.

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
    });

  return {
    ok: true,
    payload: {
      title: document.title.replace(/\s*\|\s*ChatGPT\s*$/i, "").trim() || "untitled-chat",
      source_url: location.href,
      conversation_id: conversationId,
      exported_at: new Date().toISOString(),
      mode: "full",
      messages: nodes,
    },
  };
}
```

## Fallback extraction path: DOM

Use this only when the in-page fetch path fails. It is weaker, but still normalizes the current visible thread into renderer input.

```js
() => {
  const conversationId = (location.pathname.match(/\/c\/([^/?#]+)/) || [null, null])[1];
  const articleNodes = Array.from(document.querySelectorAll("article"));

  const messages = articleNodes
    .map((node) => {
      const roleLabel =
        node.querySelector("[data-message-author-role]")?.getAttribute("data-message-author-role") ||
        (node.innerText.includes("You said:") ? "user" : node.innerText.includes("ChatGPT said:") ? "assistant" : null);

      if (roleLabel !== "user" && roleLabel !== "assistant") {
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

      const textContent = (node.innerText || "").trim();
      return codeBlocks.length > 0
        ? { role: roleLabel, parts: [{ type: "paragraph", text: textContent }, ...codeBlocks] }
        : { role: roleLabel, markdown: textContent };
    })
    .filter(Boolean);

  return {
    ok: true,
    payload: {
      title: document.title.replace(/\s*\|\s*ChatGPT\s*$/i, "").trim() || "untitled-chat",
      source_url: location.href,
      conversation_id: conversationId || "unknown-conversation",
      exported_at: new Date().toISOString(),
      mode: "full",
      messages,
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
