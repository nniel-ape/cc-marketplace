# cc-marketplace

A personal collection of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugins I've built and find useful. Feel free to grab anything that looks helpful.

## Plugins

| Plugin | Description |
|--------|-------------|
| [ios-app-icon](plugins/ios-app-icon) | Generates iOS app icons from SVG files with modern, dark/tinted, and legacy mode support |
| [skill-creator](plugins/skill-creator) | Guides Claude through creating effective skills following Anthropic's official best practices |
| [zed-notify](plugins/zed-notify) | macOS notifications for Claude Code events with smart suppression when Zed is focused |

## ios-app-icon

Generates complete iOS app icon sets from SVG source files using `rsvg-convert`. Produces correctly sized PNGs and a valid `Contents.json` ready to drop into Xcode's `Assets.xcassets/`.

**Modes:**

- **Modern** (default) — single 1024x1024 PNG for Xcode 14+, auto-generates all sizes
- **Dark/Tinted** — iOS 18 appearance variants (dark mode and user-tinted icons)
- **Legacy** — all 15 individual sizes (20px–1024px) for older Xcode versions

**Features:**

- Square viewBox validation with warnings for non-square SVGs
- Correct `Contents.json` generation for each mode
- Dark variant supports transparency, tinted variant enforces grayscale guidance

**Requirements:**

- macOS or Linux
- [librsvg](https://wiki.gnome.org/Projects/LibRsvg): `brew install librsvg`

## skill-creator

Guides Claude through creating effective skills for Claude Code, following Anthropic's official best practices for skill authoring.

**What it does:**

- Walks through a structured creation process: understand usage, plan resources, create structure, write skill, validate
- Enforces progressive disclosure (metadata → SKILL.md → references) to manage context efficiently
- Produces skills with proper frontmatter, trigger descriptions, and bundled resources

**Key guidance areas:**

- **Naming** — gerund form preferred (`processing-pdfs`, `analyzing-data`)
- **Descriptions** — third person, specific trigger phrases, concrete scenarios
- **Content** — imperative writing style, only what Claude doesn't already know
- **Structure** — SKILL.md under 500 lines, detailed content in `references/`
- **Validation** — checklist covering structure, content quality, and progressive disclosure

**Includes reference material on:**

- Best practices for progressive disclosure, workflow design, and anti-patterns
- Claude Code skill features (frontmatter, subagents, dynamic context, arguments)
- Evaluation-driven development and testing across models

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
