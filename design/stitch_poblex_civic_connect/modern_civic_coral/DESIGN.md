---
name: Modern Civic Coral
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#59413a'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#8d7169'
  outline-variant: '#e0bfb6'
  surface-tint: '#ac3509'
  primary: '#ac3509'
  on-primary: '#ffffff'
  primary-container: '#ff7043'
  on-primary-container: '#641800'
  inverse-primary: '#ffb59f'
  secondary: '#575e70'
  on-secondary: '#ffffff'
  secondary-container: '#d9dff5'
  on-secondary-container: '#5c6274'
  tertiary: '#006a61'
  on-tertiary: '#ffffff'
  tertiary-container: '#3aada0'
  on-tertiary-container: '#003b36'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbd0'
  primary-fixed-dim: '#ffb59f'
  on-primary-fixed: '#3a0a00'
  on-primary-fixed-variant: '#852300'
  secondary-fixed: '#dce2f7'
  secondary-fixed-dim: '#c0c6db'
  on-secondary-fixed: '#141b2b'
  on-secondary-fixed-variant: '#404758'
  tertiary-fixed: '#89f5e7'
  tertiary-fixed-dim: '#6bd8cb'
  on-tertiary-fixed: '#00201d'
  on-tertiary-fixed-variant: '#005049'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

This design system establishes a "Smart City" aesthetic that moves away from cold, institutional blues toward a warm, accessible, and high-energy Coral identity. The brand personality is **transparent, efficient, and sophisticated**. 

The design style is a hybrid of **Minimalism** and **Glassmorphism**. It prioritizes extreme clarity through high-quality whitespace and intentional layout, while using translucent "glass" overlays and soft, ambient depth to create a sense of layering and modern technology. The interface should feel like a premium digital concierge for the modern citizen—breathable, legible, and distinctly optimistic.

## Colors

The palette is anchored by a vibrant **Coral (#FF7043)**, used strategically for primary actions and brand presence to evoke a sense of energy and civic warmth. 

- **Backgrounds:** Utilize a "clean-slate" approach with off-whites (`#F9FAFB`) and subtle surface shifts (`#F3F4F6`) to define content areas without heavy lines.
- **Content:** Deep Slate and Charcoal (`#111827`) provide high-contrast legibility, ensuring the interface remains authoritative and sophisticated.
- **Semantic Colors:** Success (Teal), Warning (Amber), and Error (Crimson) are used sparingly. They are slightly desaturated to align with the modern palette but remain distinct for accessibility.

## Typography

This design system utilizes **Atkinson Hyperlegible Next** across all roles to ensure maximum inclusivity and clarity for a diverse citizenry. 

The typography scale is generous. Headlines use tight letter-spacing for a bold, modern look, while body copy utilizes increased line-height (1.5x minimum) and subtle tracking to prevent eye fatigue during long reading sessions. All "Label" roles should be treated with intentionality—often appearing in semi-bold or medium weights to differentiate from standard body text.

## Layout & Spacing

The layout follows a **Fluid Grid** model with a maximum container width of 1280px to maintain content density on ultra-wide monitors. 

- **Desktop:** 12-column grid with 24px gutters. Use large 40px outer margins to create the "Smart City" feel of breathing room and premium quality.
- **Mobile:** 4-column grid with 16px margins. 
- **Rhythm:** All spacing (padding, margins, gap) must be multiples of the **4px base unit**. Component vertical stack should primarily use 16px (`stack-md`) for standard grouping and 32px (`stack-lg`) for section separation.

## Elevation & Depth

Depth is communicated through **Glassmorphism** and **Ambient Shadows**. 

1.  **Surfaces:** The primary background is flat. Elevated cards use a pure white background with a very soft, diffused shadow (Blur: 20px, Spread: -5px, Opacity: 4%).
2.  **Overlays:** Navigation bars and floating modals use a backdrop-filter blur (12px to 20px) with a semi-transparent white tint (80-90% opacity). This allows the vibrant Coral accents to peek through from the background layer, creating a sense of environmental awareness.
3.  **Borders:** Use 1px "ghost" borders (`#000000` at 5% opacity) on all cards to define edges without adding visual weight.

## Shapes

The shape language is defined by **Soft Roundedness**. All primary containers, including cards, modals, and large buttons, use a **16px (rounded-lg)** radius. Small elements like chips and checkboxes use an **8px** radius. 

Avoid sharp corners entirely to maintain a friendly, approachable civic presence. Interactive elements should feel "tactile" but not "bubbly"—maintaining a professional architectural structure.

## Components

- **Buttons:** Primary buttons are Solid Coral with white text. High-emphasis hover states should involve a subtle scale-up (1.02x) rather than just a color shift. Secondary buttons use a light gray ghost style with Coral text.
- **Input Fields:** Use a solid light gray background (`#F3F4F6`) with no border in the default state. Upon focus, the background turns white with a 2px Coral border and a soft outer glow.
- **Cards:** Large 16px radius. Cards should not have heavy borders; use the ambient shadow and the ghost-border defined in the Elevation section.
- **Chips/Badges:** For status updates (e.g., "In Progress," "Resolved"), use low-saturation background tints of the semantic colors with high-saturation text of the same hue.
- **Civic Specifics:**
    - **Service Cards:** Use large, clear iconography paired with a headline-md.
    - **Status Bars:** For application tracking, use a progress indicator with a Coral fill.
    - **Quick Actions:** Floating Action Buttons (FAB) should be avoided in favor of high-visibility grounded buttons to maintain an institutional "stable" feel.