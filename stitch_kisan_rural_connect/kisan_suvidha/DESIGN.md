---
name: Kisan Suvidha
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0edec'
  surface-container-high: '#ebe7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#3f4945'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#707975'
  outline-variant: '#bfc9c4'
  surface-tint: '#29695b'
  primary: '#00342b'
  on-primary: '#ffffff'
  primary-container: '#004d40'
  on-primary-container: '#7ebdac'
  inverse-primary: '#94d3c1'
  secondary: '#705d00'
  on-secondary: '#ffffff'
  secondary-container: '#fdd400'
  on-secondary-container: '#6f5c00'
  tertiary: '#253028'
  on-tertiary: '#ffffff'
  tertiary-container: '#3b463e'
  on-tertiary-container: '#a7b4a9'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#afefdd'
  primary-fixed-dim: '#94d3c1'
  on-primary-fixed: '#00201a'
  on-primary-fixed-variant: '#065043'
  secondary-fixed: '#ffe170'
  secondary-fixed-dim: '#e9c400'
  on-secondary-fixed: '#221b00'
  on-secondary-fixed-variant: '#544600'
  tertiary-fixed: '#d9e6da'
  tertiary-fixed-dim: '#bdcabe'
  on-tertiary-fixed: '#131e17'
  on-tertiary-fixed-variant: '#3e4a41'
  background: '#fcf9f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
typography:
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Be Vietnam Pro
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Noto Sans
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 26px
  body-md:
    fontFamily: Noto Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.5px
  label-md:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  margin-mobile: 20px
  gutter-mobile: 16px
  touch-target-min: 56px
  stack-gap-lg: 24px
  stack-gap-md: 16px
---

## Brand & Style

The design system is engineered for maximum utility and legibility in high-glare, outdoor environments typical of rural Indian agriculture. The brand personality is **Dependable, Empathetic, and Accessible**. It prioritizes functional clarity over decorative flair, ensuring that farmers of varying literacy levels and digital proficiency can navigate critical procurement and registration workflows with confidence.

The visual style is a hybrid of **Modern Corporate** and **High-Contrast Minimalism**. It utilizes the structural logic of Material Design 3 but strips away complex shadows and subtle gradients that often disappear on low-budget, low-nit mobile displays. The aesthetic is defined by "Pictorial-First" communication—using large, recognizable metaphors and high-visibility color blocks to guide the user through offline-capable task flows.

## Colors

The palette is optimized for **outdoor visibility**.
- **Primary (Deep Green):** Represents trust and agriculture. Used for top bars, primary buttons, and successful state indicators. It provides a strong contrast against white backgrounds.
- **Secondary (Bright Yellow):** Used for attention-grabbing elements, warnings, and active stepper icons. It is chosen for its cultural resonance with growth and its high visibility in sunlight.
- **Tertiary (Mint White):** A very soft green-tinted white used for large card surfaces to reduce eye strain while maintaining high contrast with text.
- **Surface & Background:** High-purity white (#FFFFFF) is used for the primary background to ensure the best possible screen reflection management.

## Typography

The typography system uses **Be Vietnam Pro** for its modern, friendly, and geometric structure in English titles, paired with **Noto Sans** for its exceptional multi-script support (specifically Devanagari/Hindi). 

Key rules:
- **Oversized Defaults:** Standard body text starts at 16px, with 18px preferred for critical instructions to assist users with varying visual acuity.
- **Weight as Hierarchy:** Since color is used sparingly for functional states, font weight (Bold/Medium) is the primary tool for distinguishing headers from body text.
- **Line Height:** Generous line heights are maintained to prevent crowding, which is essential for Hindi script legibility where vowel signs (matras) appear above and below the base characters.

## Layout & Spacing

This design system uses a **Fluid Grid** model optimized for the vertical orientation of mobile devices. 
- **Touch Targets:** A minimum touch target of 56px (height and width) is enforced for all interactive elements to accommodate "fat-finger" errors and shaky-hand usage in field conditions.
- **Safety Margins:** A 20px outer margin ensures content does not get clipped by budget phone screen protectors or thick protective cases.
- **Vertical Stack:** Navigation is strictly vertical. Horizontal scrolling is avoided to prevent confusion regarding "hidden" content.
- **Progress Tracking:** Vertical steppers should occupy the full width of the screen, providing a clear top-to-bottom "path" for multi-step registration or booking processes.

## Elevation & Depth

To accommodate low-end hardware and maximize battery efficiency, this design system avoids complex drop shadows. 
- **Tonal Layers:** Depth is expressed through **Surface Tiers**. The base layer is white, while interactive cards use the Tertiary Mint White (#E8F5E9) with a thin 1px stroke in Primary Green (#004D40) at 20% opacity.
- **Zero-Shadow Content:** Instead of elevation shadows, active states are indicated by a **High-Contrast Border** (2px) in Secondary Yellow or a solid Primary Green background.
- **Modal Overlays:** Use a solid 60% black scrim to pull focus, ensuring the modal content has a sharp, solid white background.

## Shapes

The shape language uses **Level 2 (Rounded)** settings. 
- **Standard UI Elements:** Use 0.5rem (8px) corner radii. This provides a friendly, modern feel that aligns with Material 3 without looking too "playful" or childlike.
- **Pictorial Buttons:** Large action tiles use 1rem (16px) rounding to clearly distinguish them from smaller informational cards.
- **Input Fields:** Use "Sturdy" 8px rounding with a visible 1.5px border to clearly define the input area.

## Components

### Pictorial Buttons (Primary Interaction)
These are the core of the navigation. Each button features a large, simplified icon (2-color flat style) on the left or top, accompanied by a bold Label-LG text. They must have a minimum height of 80px.

### Vertical Stepper
The stepper uses the Secondary Yellow for the "Active" node and Primary Green for "Completed" nodes. Lines between nodes are 4px thick to ensure visibility.

### Action Cards
Cards containing procurement data or slot details should use a "Container-First" approach. Use the Primary Color for the header of the card and a high-contrast black on Tertiary White for the content body.

### Input Fields
Fields must include a persistent label above the input and a "Hint" text below it. Underline-only inputs are prohibited; use full-box inputs with clear borders.

### Progress Visualizers
Linear progress bars should be 12px thick (taller than standard) and use the Secondary Yellow for the progress fill against a Primary Green background, ensuring the bar is visible even in direct sunlight.

### Status Badges
Chips/Badges use high-contrast color fills: Green for "Paid/Success," Yellow for "Pending/Waiting," and Red for "Action Required."