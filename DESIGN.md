# Design System Specification: A High-End Editorial Approach

## 1. Overview & Creative North Star
**Creative North Star: "The Sacred Sanctuary"**

This design system rejects the clinical, "app-like" aesthetic of modern utility software in favor of a tactile, editorial experience. It is designed to feel like a premium physical object—a high-end journal or a stone-carved inscription found in a desert retreat. 

To move beyond "standard" UI, we utilize **intentional asymmetry** and **tonal layering**. We break the rigid grid by allowing elements to overlap slightly, mimicking the way sand drifts over stone. The system avoids "boxes inside boxes," instead using soft, organic Neomorphism to create "sculpted" surfaces that emerge from the background rather than sitting on top of it.

## 2. Colors & Materiality
The palette is rooted in the earth, using a sophisticated hierarchy of warmth and cooling "water" tones to represent spiritual clarity.

### The Palette (Material Design Tokens)
- **Background (`surface`):** `#fef9ef` (The base "sand" upon which everything is built).
- **Primary (`primary` / `primary_container`):** `#006a62` / `#40e0d0` (The "Oasis" turquoise for active states and primary prayer times).
- **Secondary/Accent (`secondary`):** `#9f402d` (The "Terracotta" for highlights and focus).
- **Surface Hierarchy:** 
    - `surface_container_low`: `#f8f3e9`
    - `surface_container_highest`: `#e7e2d8`

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section content. Boundaries must be defined solely through background color shifts or Neomorphic depth. For example, a "Next Prayer" card should not have a stroke; it should be defined by a shift to `surface_container_highest` or a soft inner shadow that makes it look "pressed" into the sand.

### The Glass & Gradient Rule
To add "soul," use subtle radial gradients on main CTAs. Transition from `primary` (#006a62) to `primary_container` (#40e0d0) with a 45-degree angle. For floating elements, use **Glassmorphism**: a semi-transparent `surface_container_lowest` with a `20px` backdrop-blur to create a "frosted quartz" effect.

## 3. Typography
The typography scale uses a high-contrast pairing: a serif for moments of reflection and a modern sans-serif for functional data.

- **Display & Headlines (`notoSerif`):** Used for spiritual quotes, city names, and prayer names (e.g., *Fajr*, *Maghrib*). The serif nature evokes the elegance of traditional Naskh calligraphy.
- **Body & Labels (`plusJakartaSans` / `IBMPlexSansArabic`):** Used for countdown timers, dates, and settings. This provides a modern, clean counterpoint to the more decorative headlines.

**Hierarchy as Identity:** Use `display-lg` (3.5rem) for the current time to create an editorial "hero" moment. Use `label-sm` (0.6875rem) with increased letter spacing (0.05rem) for secondary metadata to mimic the look of a premium architectural plaque.

## 4. Elevation & Depth: The Tactile Layering Principle
We move away from flat design. This system is three-dimensional and organic.

### Stacking Tiers
Depth is achieved by stacking `surface-container` tiers. 
- Place a `surface_container_lowest` (#ffffff) card on a `surface_container_low` (#f8f3e9) background. 
- The contrast is barely perceptible to the eye but creates a sophisticated "lift" that feels natural and expensive.

### Ambient Shadows & Neomorphism
When an element needs to "float" (like a FAB or an active prayer card):
1. **Light Source:** Always top-left.
2. **Shadow 1 (Dark):** Offset: 8px 8px, Blur: 16px, Color: `on_surface` at 6% opacity.
3. **Shadow 2 (Highlight):** Offset: -8px -8px, Blur: 16px, Color: `#ffffff` at 80% opacity.
This creates the "Soft UI" look where the button looks like it was molded from the desert floor.

### The "Ghost Border" Fallback
If accessibility requires a container edge, use the `outline_variant` token at **15% opacity**. Never use a 100% opaque border.

## 5. Components & Interaction Patterns

### Buttons
- **Primary:** Rounded `xl` (3rem). Uses the Turquoise gradient. No shadow on hover; instead, use a subtle `inner-shadow` to make the button look "pressed" when active.
- **Tertiary:** Text-only in `secondary` (Terracotta). No background. High-contrast editorial style.

### Cards (Prayer Times)
- **Forbid Dividers:** Do not use lines between prayer times. Use vertical white space (`spacing-6`) or a subtle tonal shift (e.g., the current prayer time is `surface_container_highest`, while others are `surface`).
- **Nesting:** Group "Sunnah" prayers inside a nested container that is slightly "recessed" (inner shadow) to show hierarchy.

### Iconography: The "Hand-Drawn" Standard
Avoid line-art icons (like Feather or Lucide). Icons must have "weight." Use a thick-to-thin stroke variation that mimics a bamboo pen (Qalam). Icons should be multi-tonal, using `on_surface` for the main shape and a `primary` (Turquoise) dot or accent within the icon to tie it to the Oasis theme.

### Specialized Component: The Qibla Compass
The compass should not be a flat circle. It should be a sculpted `surface_container_highest` disk with a Glassmorphic needle. The "North" indicator should use a `secondary` (Terracotta) highlight.

## 6. Do’s and Don’ts

### Do:
- **Use Asymmetry:** Place the "Next Prayer" countdown slightly off-center or overlapping the header image to create an editorial feel.
- **Embrace Large Radii:** All containers should use `roundness-xl` (3rem) to maintain the organic, "eroded by wind" look.
- **Use White Space:** Treat the `background` color as a luxury. Don't crowd the screen; let the "sand" breathe.

### Don’t:
- **Don’t use Pure Black:** Never use `#000000`. Always use `on_surface` (#1d1c16) for text to maintain the warm, earthy tone.
- **Don’t use Standard Shadows:** Avoid the default CSS `0px 2px 4px rgba(0,0,0,0.1)`. It looks cheap. Use the multi-layered Ambient Shadows described in Section 4.
- **Don’t use Hard Corners:** Avoid `none` or `sm` roundedness unless it is for a tiny utility label. Small radii break the organic spirit of the system.