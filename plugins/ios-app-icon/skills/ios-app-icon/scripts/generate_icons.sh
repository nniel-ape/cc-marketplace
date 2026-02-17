#!/usr/bin/env bash
set -euo pipefail

# iOS App Icon Generator
# Converts SVG files to iOS app icon sets using rsvg-convert.
# Produces correctly sized PNGs and a valid Contents.json for Xcode.

usage() {
    cat <<'USAGE'
Usage: generate_icons.sh [OPTIONS] <input.svg>

Options:
  -o, --output DIR     Output directory (default: AppIcon.appiconset)
  -m, --mode MODE      Generation mode: modern (default) or legacy
  -d, --dark SVG       Dark variant SVG (iOS 18+)
  -t, --tinted SVG     Tinted variant SVG (iOS 18+)
  -h, --help           Show this help message

Modes:
  modern    Single 1024x1024 PNG for Xcode 14+ (default)
  legacy    All individual sizes (20-1024px) for older Xcode

Examples:
  generate_icons.sh logo.svg
  generate_icons.sh -o Assets.xcassets/AppIcon.appiconset logo.svg
  generate_icons.sh -m legacy logo.svg
  generate_icons.sh -d logo-dark.svg -t logo-tinted.svg logo.svg
USAGE
    exit 0
}

# --- Dependency check ---

if ! command -v rsvg-convert &>/dev/null; then
    echo "Error: rsvg-convert not found." >&2
    echo "Install with: brew install librsvg" >&2
    exit 1
fi

# --- Parse arguments ---

OUTPUT_DIR="AppIcon.appiconset"
MODE="modern"
DARK_SVG=""
TINTED_SVG=""
INPUT_SVG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)  OUTPUT_DIR="$2"; shift 2 ;;
        -m|--mode)    MODE="$2"; shift 2 ;;
        -d|--dark)    DARK_SVG="$2"; shift 2 ;;
        -t|--tinted)  TINTED_SVG="$2"; shift 2 ;;
        -h|--help)    usage ;;
        -*)           echo "Error: Unknown option: $1" >&2; exit 1 ;;
        *)            INPUT_SVG="$1"; shift ;;
    esac
done

if [[ -z "$INPUT_SVG" ]]; then
    echo "Error: No input SVG specified." >&2
    echo "Run with --help for usage." >&2
    exit 1
fi

if [[ ! -f "$INPUT_SVG" ]]; then
    echo "Error: File not found: $INPUT_SVG" >&2
    exit 1
fi

# --- Validate SVG viewBox is square ---

viewbox=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "$INPUT_SVG" | head -1)
if [[ -n "$viewbox" ]]; then
    vb_w=$(echo "$viewbox" | awk '{print $3}')
    vb_h=$(echo "$viewbox" | awk '{print $4}')
    if [[ -n "$vb_w" && -n "$vb_h" && "$vb_w" != "$vb_h" ]]; then
        echo "Warning: SVG viewBox is not square (${vb_w}x${vb_h}). Icon may appear stretched." >&2
    fi
fi

mkdir -p "$OUTPUT_DIR"

# --- Helper: generate a single PNG ---

generate_png() {
    local svg="$1" size="$2" output="$3"
    rsvg-convert -w "$size" -h "$size" "$svg" -o "$output"
    echo "  Created: $(basename "$output") (${size}x${size})"
}

# --- Modern mode: single 1024x1024 ---

generate_modern() {
    echo "Generating modern single-size icon set..."
    generate_png "$INPUT_SVG" 1024 "$OUTPUT_DIR/AppIcon-1024.png"

    # Start building Contents.json images array
    local images
    images=$(cat <<'JSON'
    {
      "filename": "AppIcon-1024.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    }
JSON
    )

    if [[ -n "$DARK_SVG" ]]; then
        if [[ ! -f "$DARK_SVG" ]]; then
            echo "Error: Dark SVG not found: $DARK_SVG" >&2
            exit 1
        fi
        echo "Generating dark variant..."
        generate_png "$DARK_SVG" 1024 "$OUTPUT_DIR/AppIcon-Dark-1024.png"
        images="$images"$(cat <<'JSON'
,
    {
      "appearances": [
        {
          "appearance": "luminosity",
          "value": "dark"
        }
      ],
      "filename": "AppIcon-Dark-1024.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    }
JSON
        )
    fi

    if [[ -n "$TINTED_SVG" ]]; then
        if [[ ! -f "$TINTED_SVG" ]]; then
            echo "Error: Tinted SVG not found: $TINTED_SVG" >&2
            exit 1
        fi
        echo "Generating tinted variant..."
        generate_png "$TINTED_SVG" 1024 "$OUTPUT_DIR/AppIcon-Tinted-1024.png"
        images="$images"$(cat <<'JSON'
,
    {
      "appearances": [
        {
          "appearance": "luminosity",
          "value": "tinted"
        }
      ],
      "filename": "AppIcon-Tinted-1024.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    }
JSON
        )
    fi

    cat > "$OUTPUT_DIR/Contents.json" <<EOF
{
  "images": [
$images
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
EOF
}

# --- Legacy mode: all individual sizes ---

generate_legacy() {
    echo "Generating legacy all-sizes icon set..."

    # Format: "points scale pixels"
    local specs=(
        "20 1 20"
        "20 2 40"
        "20 3 60"
        "29 1 29"
        "29 2 58"
        "29 3 87"
        "40 1 40"
        "40 2 80"
        "40 3 120"
        "60 2 120"
        "60 3 180"
        "76 1 76"
        "76 2 152"
        "83.5 2 167"
        "1024 1 1024"
    )

    local images=""
    local first=true

    for spec in "${specs[@]}"; do
        local pts scale px
        read -r pts scale px <<< "$spec"
        local filename="AppIcon-${px}.png"

        generate_png "$INPUT_SVG" "$px" "$OUTPUT_DIR/$filename"

        if [[ "$first" == true ]]; then
            first=false
        else
            images="$images,"
        fi

        images="$images
    {
      \"filename\": \"$filename\",
      \"idiom\": \"universal\",
      \"platform\": \"ios\",
      \"scale\": \"${scale}x\",
      \"size\": \"${pts}x${pts}\"
    }"
    done

    cat > "$OUTPUT_DIR/Contents.json" <<EOF
{
  "images": [$images
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
EOF
}

# --- Main ---

case "$MODE" in
    modern) generate_modern ;;
    legacy) generate_legacy ;;
    *)
        echo "Error: Unknown mode '$MODE'. Use 'modern' or 'legacy'." >&2
        exit 1
        ;;
esac

echo ""
echo "Done. Output: $OUTPUT_DIR/"
ls "$OUTPUT_DIR/"
