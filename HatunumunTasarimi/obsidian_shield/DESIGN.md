---
name: Obsidian Shield
colors:
  surface: '#10141a'
  surface-dim: '#10141a'
  surface-bright: '#353940'
  surface-container-lowest: '#0a0e14'
  surface-container-low: '#181c22'
  surface-container: '#1c2026'
  surface-container-high: '#262a31'
  surface-container-highest: '#31353c'
  on-surface: '#dfe2eb'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#dfe2eb'
  inverse-on-surface: '#2d3137'
  outline: '#849495'
  outline-variant: '#3b494b'
  surface-tint: '#00dbe9'
  primary: '#dbfcff'
  on-primary: '#00363a'
  primary-container: '#00f0ff'
  on-primary-container: '#006970'
  inverse-primary: '#006970'
  secondary: '#c2c7d0'
  on-secondary: '#2c3138'
  secondary-container: '#42474f'
  on-secondary-container: '#b1b5bf'
  tertiary: '#fff3f2'
  on-tertiary: '#68000b'
  tertiary-container: '#ffceca'
  on-tertiary-container: '#bb1824'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#7df4ff'
  primary-fixed-dim: '#00dbe9'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#dee2ec'
  secondary-fixed-dim: '#c2c7d0'
  on-secondary-fixed: '#171c23'
  on-secondary-fixed-variant: '#42474f'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3ae'
  on-tertiary-fixed: '#410004'
  on-tertiary-fixed-variant: '#930014'
  background: '#10141a'
  on-background: '#dfe2eb'
  surface-variant: '#31353c'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-sm:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 20px
  gutter-mobile: 12px
---

## Brand & Style
The design system is engineered for a high-security mobile environment, prioritizing clarity, authority, and technical precision. The aesthetic is rooted in **Modern Minimalism** with a **Cyber-Technical** edge, utilizing a deep obsidian foundation to reduce eye strain and focus the user's attention on critical security states.

The target audience consists of privacy-conscious individuals and professionals who require a tool that feels like a sophisticated digital vault rather than a toy. The UI should evoke a sense of impenetrable protection and calm control. Visual cues are derived from glassmorphism for layered security contexts and high-contrast accents to signal system status instantly.

## Colors
The palette is dominated by a "Deep Obsidian" environment that provides a non-distracting backdrop for security tasks. 

- **Primary (Electric Cyan):** Used exclusively for active security states, primary actions, and "unlocked" indicators. It should feel luminescent against the dark background.
- **Secondary (Dark Card):** Used for container surfaces to create subtle hierarchy without breaking the dark immersion.
- **Tertiary (Alert Red):** Reserved for "locked" states, restricted access, and critical system warnings.
- **Neutral:** A range of deep grays and off-whites used for secondary text and structural borders.

## Typography
The design system utilizes **Inter** for its exceptional legibility in dark modes and its neutral, professional tone. For technical data, mono-spaced leaning fonts like **Geist** are used in label roles to emphasize the app's utility and precision.

Large headlines should use tight letter spacing to appear more "locked-in" and authoritative. Body text maintains standard tracking to ensure readability during long configuration tasks. Secondary information is often presented in uppercase labels to create a clear distinction between content and UI metadata.

## Layout & Spacing
This design system follows a strictly technical 4px baseline grid. Layouts are primarily fluid within the mobile viewport, utilizing a 4-column grid for compact handheld devices. 

Margins are kept generous at 20px to ensure touch targets for security toggles are easily reachable. Vertical rhythm is driven by the "md" (16px) unit, creating a dense but breathable information architecture. Components should align to the grid to reinforce the feeling of a structured, secure environment.

## Elevation & Depth
In this dark-themed design system, depth is communicated through **Tonal Layering** rather than heavy shadows. 

1. **Floor (0dp):** The `#0D1117` background.
2. **Surface (1dp):** `#161B22` for standard cards and list items.
3. **Overlay (2dp):** `#1C2128` for elevated modals or floating actions.

To enhance the technical feel, use **Inner Glows** on primary buttons (0.5px white at 10% opacity) and **Thin Outlines** (#30363D) for containers. A subtle **Backdrop Blur** (12px) is used for fixed navigation bars to maintain context while the user scrolls.

## Shapes
The shape language is **Soft** but structured. A base radius of 4px (`rounded-sm`) is used for smaller elements like checkboxes and input fields, while larger containers and buttons use 8px (`rounded-lg`). 

This subtle rounding avoids the "friendliness" of fully rounded corners, maintaining a serious and professional industrial aesthetic while remaining comfortable for modern mobile hardware.

## Components

- **Buttons:** Primary buttons use the Electric Cyan background with black text for maximum contrast. Secondary buttons are outlined with a 1px border. Use a "Pulse" animation for active security scanning buttons.
- **App Cards:** Use a horizontal layout with the app icon on the left, name and status in the center, and a toggle switch on the right.
- **Toggles:** Custom oversized toggles. When "ON" (Locked), the track should be Alert Red. When "OFF" (Unlocked), the track should be a muted Neutral Gray.
- **Input Fields:** Flat styling with a bottom-only border that glows Electric Cyan when focused. Use a monospaced font for PIN and Password entry.
- **Security Chips:** Small, low-profile indicators for "Biometrics Active" or "Guest Mode" using the Label-sm typography style and a subtle background tint.
- **Lock Overlay:** A full-screen frosted glass effect (`blur-20`) that appears over protected apps, featuring a central biometric icon and an "Emergency Exit" text link at the bottom.