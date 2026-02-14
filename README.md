# cc-marketplace

A personal collection of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugins I've built and find useful. Feel free to grab anything that looks helpful.

## Plugins

| Plugin | Description |
|--------|-------------|
| [zed-notify](plugins/zed-notify) | macOS notifications for Claude Code events with smart suppression when Zed is focused |

## zed-notify

Native macOS notifications when Claude Code needs your attention — task complete, permission needed, waiting for input, or a dialog popped up. Stays quiet when you're already looking at the right Zed window.

**Events:**

- **Stop** — task finished (Hero sound)
- **Permission prompt** — tool use needs approval (Ping sound)
- **Idle prompt** — Claude is waiting for input (Glass sound)
- **Elicitation dialog** — MCP tool needs input (Ping sound)

**Features:**

- Smart suppression — no notification if the project's Zed window is already focused
- Click-to-focus — clicking a notification opens the project in Zed
- Uses `terminal-notifier` when available, falls back to `osascript`
- Notifications grouped per project to avoid spam

**Requirements:**

- macOS
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) (recommended): `brew install terminal-notifier`
- Accessibility permission for Zed focus detection (optional, suppression degrades gracefully)

## Installing a plugin

```bash
claude plugin add github:nniel-ape/cc-marketplace/plugins/<plugin-name>
```

For example:

```bash
claude plugin add github:nniel-ape/cc-marketplace/plugins/zed-notify
```
