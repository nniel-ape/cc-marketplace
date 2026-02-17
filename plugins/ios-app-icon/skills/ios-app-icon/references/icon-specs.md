# iOS App Icon Specifications

## Modern Mode (Xcode 14+)

Xcode 14 and later accept a single 1024x1024 PNG and automatically generate all required sizes. This is the recommended approach for new projects.

### Contents.json — Single Size

```json
{
  "images": [
    {
      "filename": "AppIcon-1024.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

### Contents.json — With Dark and Tinted Variants (iOS 18+)

```json
{
  "images": [
    {
      "filename": "AppIcon-1024.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    },
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
    },
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
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

## iOS 18 Dark and Tinted Variants

iOS 18 introduced automatic icon appearance switching. Apps can provide three icon variants:

### Light (Default)
- Standard icon displayed in light mode
- Must have a solid, opaque background
- No transparency allowed

### Dark
- Displayed when the device is in dark mode
- May use transparency for the background — iOS composites it onto the system dark background
- Artwork should be designed for visibility against dark surfaces
- Typically uses lighter or brighter colors than the light variant

### Tinted
- Displayed when the user enables the tinted icon style
- Must be **grayscale only** — iOS applies the user's selected tint color
- Focus on luminance contrast rather than color
- Good tinted icons have clear silhouettes and strong value separation

## Legacy Mode — Complete iOS Icon Size Table

All sizes required for iOS apps when not using the single-size feature:

| Context              | Points  | Scale | Pixels | Filename        |
|----------------------|---------|-------|--------|-----------------|
| Notification (iPad)  | 20      | 1x    | 20     | AppIcon-20.png  |
| Notification         | 20      | 2x    | 40     | AppIcon-40.png  |
| Notification (Phone) | 20      | 3x    | 60     | AppIcon-60.png  |
| Settings (iPad)      | 29      | 1x    | 29     | AppIcon-29.png  |
| Settings             | 29      | 2x    | 58     | AppIcon-58.png  |
| Settings (Phone)     | 29      | 3x    | 87     | AppIcon-87.png  |
| Spotlight (iPad)     | 40      | 1x    | 40     | AppIcon-40.png  |
| Spotlight            | 40      | 2x    | 80     | AppIcon-80.png  |
| Spotlight (Phone)    | 40      | 3x    | 120    | AppIcon-120.png |
| App (Phone)          | 60      | 2x    | 120    | AppIcon-120.png |
| App (Phone)          | 60      | 3x    | 180    | AppIcon-180.png |
| App (iPad)           | 76      | 1x    | 76     | AppIcon-76.png  |
| App (iPad)           | 76      | 2x    | 152    | AppIcon-152.png |
| App (iPad Pro)       | 83.5    | 2x    | 167    | AppIcon-167.png |
| App Store            | 1024    | 1x    | 1024   | AppIcon-1024.png|

Note: Some pixel sizes overlap (e.g., 40px for 20@2x and 40@1x, 120px for 40@3x and 60@2x). The script deduplicates these — only unique pixel sizes are generated.

### Contents.json — Legacy All Sizes

```json
{
  "images": [
    {
      "filename": "AppIcon-20.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "1x",
      "size": "20x20"
    },
    {
      "filename": "AppIcon-40.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "2x",
      "size": "20x20"
    },
    {
      "filename": "AppIcon-60.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "3x",
      "size": "20x20"
    },
    {
      "filename": "AppIcon-29.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "1x",
      "size": "29x29"
    },
    {
      "filename": "AppIcon-58.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "2x",
      "size": "29x29"
    },
    {
      "filename": "AppIcon-87.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "3x",
      "size": "29x29"
    },
    {
      "filename": "AppIcon-40.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "1x",
      "size": "40x40"
    },
    {
      "filename": "AppIcon-80.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "2x",
      "size": "40x40"
    },
    {
      "filename": "AppIcon-120.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "3x",
      "size": "40x40"
    },
    {
      "filename": "AppIcon-120.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "2x",
      "size": "60x60"
    },
    {
      "filename": "AppIcon-180.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "3x",
      "size": "60x60"
    },
    {
      "filename": "AppIcon-76.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "1x",
      "size": "76x76"
    },
    {
      "filename": "AppIcon-152.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "2x",
      "size": "76x76"
    },
    {
      "filename": "AppIcon-167.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "2x",
      "size": "83.5x83.5"
    },
    {
      "filename": "AppIcon-1024.png",
      "idiom": "universal",
      "platform": "ios",
      "scale": "1x",
      "size": "1024x1024"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

## Design Best Practices

### Mandatory Requirements
- **Square format**: SVG viewBox must be square. The script warns if width and height differ.
- **No rounded corners**: Apple applies the standard squircle mask automatically. Including your own corners creates a double-rounded effect.
- **No transparency**: The App Store icon and light variant must have a fully opaque background. Only the dark variant may use transparency.

### Recommended
- **sRGB color space**: Use sRGB for maximum compatibility across devices.
- **Simple at small sizes**: The icon must remain recognizable at 20x20px. Avoid fine detail, thin lines, and small text.
- **Consistent identity**: All three variants (light, dark, tinted) should be immediately recognizable as the same app.
- **Test at actual sizes**: Preview the icon at 60x60, 40x40, and 20x20 to verify legibility.
- **Avoid photographs**: Vector artwork scales better and produces crisper results at all sizes.
- **Center the main element**: Leave some padding from the edges — the squircle mask clips corners.

### Common Mistakes
- Adding rounded corners to the artwork (Apple adds them)
- Using transparency in the light/default icon
- Fine detail that disappears at small sizes
- Text in the icon that becomes unreadable
- Placing important elements too close to corners (clipped by mask)
