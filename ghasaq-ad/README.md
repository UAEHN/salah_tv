# 🌙 Ghasaq · غسق

Cinematic promotional animation for the Ghasaq Islamic prayer times app.

## 🚀 Quick Start

```bash
npm install
npm run dev
```

Then open `http://localhost:5173` in your browser.

To build for production:

```bash
npm run build
```

The output will be in the `dist/` folder.

## 📁 Project Structure

```
src/
├── App.jsx                    Main scene router & timeline
├── main.jsx                   React entry point
│
├── constants/
│   ├── colors.js              🎨 Brand color palette
│   ├── fonts.js               ✍️  Font stacks
│   ├── images.js              🖼️  Base64 logo + screenshots
│   └── scenes.js              📋 Scene timeline & feature props
│
├── styles/
│   └── animations.css         🎬 All @keyframes + font classes
│
├── components/
│   ├── Phone.jsx              📱 iPhone-style mockup frame
│   ├── StarDots.jsx           ✨ Twinkling background dots
│   ├── PatternLayer.jsx       🕌 Tiled Islamic pattern
│   ├── MeshGradient.jsx       🌈 Atmospheric blurred glows
│   │
│   ├── icons/                 🔣 Custom SVG icons
│   │   ├── IconClock.jsx
│   │   ├── IconCompass.jsx
│   │   ├── IconBeads.jsx
│   │   └── IconBell.jsx
│   │
│   └── ornaments/             🌸 Decorative SVG elements
│       ├── Arabesque.jsx      Horizontal divider
│       ├── CornerOrnament.jsx Corner arc decoration
│       └── IslamicTile.jsx    8-pointed star tile
│
└── scenes/                    🎞️ The 9 scenes of the ad
    ├── SceneHook.jsx          Sun + moon = "غسق" intro
    ├── SceneVerse.jsx         Quranic verse (17:78)
    ├── SceneProblem.jsx       "How many prayers have we missed?"
    ├── ScenePhone.jsx         Reusable feature template
    ├── SceneNotification.jsx  Realistic lock-screen notification
    ├── SceneStats.jsx         "5 prayers · 60+ dhikr · 0 ads"
    └── SceneCTA.jsx           Final logo + download buttons
```

## ⚡ Quick Customization

| What you want to change | File to edit |
|-------------------------|-------------|
| Colors (gold tone, navy) | `constants/colors.js` |
| Fonts | `constants/fonts.js` + `styles/animations.css` |
| Replace screenshots | `constants/images.js` (paste new base64) |
| Scene durations | `constants/scenes.js` |
| Feature scene texts | `constants/scenes.js` (FEATURES object) |
| Reorder scenes | `constants/scenes.js` (SCENE_TIMELINE) |
| Add a new scene | Create file in `scenes/` then register in `App.jsx` + `scenes.js` |

## 🎬 The 9 Scenes

| # | Scene | Duration | Concept |
|---|-------|----------|---------|
| 1 | Hook | 8.0s | Sun arcs across, moon rises, they meet → "غسق" reveals |
| 2 | Verse | 5.5s | Quranic verse referencing the brand name |
| 3 | Problem | 5.0s | Emotional question, app shown as the answer |
| 4 | Prayer Times | 5.5s | Real screenshot + features |
| 5 | Qibla | 5.5s | Real screenshot + features |
| 6 | Athkar | 5.5s | Real screenshot + features |
| 7 | Notification | 5.5s | Realistic iOS lock screen with notification |
| 8 | Stats | 5.0s | Three big numbers: 5 / 60+ / 100% |
| 9 | CTA | 7.0s | Logo + download buttons + sadaqah footer |

**Total: ~52 seconds** — full ad duration. Loops automatically.

## 🎯 Recording Tips

For TikTok/Reels (vertical 9:16):
- Record only scenes 1, 2, 6, 9 (Hook → Verse → Notification → CTA) ≈ 25 seconds

For YouTube (horizontal 16:9):
- Record full sequence ≈ 52 seconds

For App Store / website:
- Record CTA scene only as a hero animation

Use OBS Studio or Mac's `Cmd+Shift+5` for screen capture.
Add ambient/cinematic music in CapCut or DaVinci Resolve.

---

Made with care · Sadaqah jariyah for whoever helped build it.
