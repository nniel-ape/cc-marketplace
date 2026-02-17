---
name: ios-app-icon
description: Generates iOS app icons from SVG files using rsvg-convert. Use when the user asks to "generate app icons", "create iOS icons from SVG", "make app icon", "convert SVG to app icon", or needs to produce AppIcon.appiconset contents for Xcode. Supports modern single 1024x1024 mode (Xcode 14+), iOS 18 dark/tinted variants, and legacy all-sizes mode.
---

# iOS App Icon Generation

Generate complete iOS app icon sets from SVG source files. Produces correctly sized PNGs and a valid `Contents.json` ready to drop into an Xcode project's `Assets.xcassets/`.

## Dependency

This skill requires `rsvg-convert` from the `librsvg` package.

Check availability before running:

```bash
command -v rsvg-convert
```

If missing, install with:

```bash
brew install librsvg
```

## Default Workflow (Modern — Xcode 14+)

Modern iOS development requires only a single 1024x1024 PNG. Xcode auto-generates all other sizes.

1. Locate or confirm the user's SVG source file
2. Determine the output directory — default to `AppIcon.appiconset/` inside the project's `Assets.xcassets/` if an Xcode project structure is detected, otherwise use the current directory
3. Run the generation script:

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/ios-app-icon/scripts/generate_icons.sh" input.svg -o path/to/AppIcon.appiconset
```

This produces:
- `AppIcon-1024.png` — the single required icon
- `Contents.json` — Xcode-compatible manifest

## Dark and Tinted Variants (iOS 18+)

iOS 18 introduced automatic dark mode and tinted icon variants. To support these:

**Preparing variant SVGs:**
- **Dark variant**: Design for dark backgrounds. May use transparency for the background (Apple composites it). Typically lighter/brighter artwork.
- **Tinted variant**: Must be **grayscale**. iOS applies the user's chosen tint color. Focus on luminance contrast only.

**Generating with variants:**

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/ios-app-icon/scripts/generate_icons.sh" \
  -d dark-icon.svg \
  -t tinted-icon.svg \
  input.svg
```

The script generates all three PNGs and a `Contents.json` with the correct `appearances` entries for each variant.

If the user only has a single SVG and wants dark/tinted support, guide them on creating the variants:
- Dark: adjust colors for dark backgrounds, optionally make background transparent
- Tinted: convert to grayscale, ensure good luminance contrast

## Legacy Workflow (Pre-Xcode 14)

For projects targeting older Xcode versions or requiring explicit per-size icons:

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/ios-app-icon/scripts/generate_icons.sh" -m legacy input.svg
```

Generates 15 individual PNGs covering all iOS icon contexts (notifications, settings, spotlight, app, App Store) at appropriate scales, plus a full `Contents.json`.

## Output Placement

When determining where to output icons:

1. Check if the current project has an `.xcodeproj` or `.xcworkspace`
2. Look for an existing `Assets.xcassets/AppIcon.appiconset/` directory
3. If found, confirm with the user before overwriting
4. If not found, create `AppIcon.appiconset/` in the current directory

## Design Requirements

Remind users of Apple's icon guidelines:
- **Square**: SVG must have a square viewBox (the script warns if not)
- **No rounded corners**: Apple applies the squircle mask automatically
- **No transparency**: Use a solid background (except dark variant)
- **sRGB color space**: Recommended for broadest compatibility
- **Simple at small sizes**: Icon must remain legible at 20px

## Additional Resources

- **`references/icon-specs.md`** — Complete iOS icon size table, Contents.json templates, and design best practices
- **`scripts/generate_icons.sh`** — The conversion script (run with `--help` for full usage)
