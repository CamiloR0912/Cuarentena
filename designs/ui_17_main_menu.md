# ui_17 — Main menu screen

| Field | Value |
|---|---|
| Priority | **P1** (simple version) / P2 (animated parallax) |
| Canvas | 960×540 |
| Output folder | `juego/assets/ui/menu/` |

## Composition

A pixel-art illustration of **Tunja in quarantine at dawn**, seen from a slightly elevated street:

- **Back layer (sky + mountains):** cold dawn sky `B0` → `B1` → `N6` in stepped bands (no smooth gradient), silhouettes of the Boyacá hills (`B1`).
- **Middle layer (city):** silhouettes of colonial roofs and the **cathedral towers**, a few lit windows (`A2`), a hospital building with a red-cross sign on the right.
- **Fog layer:** reuse `vfx_10` scrolling.
- **Front layer:** chain-link fence + quarantine tape in the foreground, an ambulance with blinking lights at the bottom-right, a lone figure in a white coat (Elena, ~40 px tall, back to the camera) looking at the city.

Layout on top:

| Element | Position | Size |
|---|---|---|
| Logo (`ui_16`) | centered, y = 40 | 400×120 |
| Buttons "Jugar", "Controles", "Créditos", "Salir" | x = 80, y = 260, 40 px apart | 200×28 each (`ui_01` button) |
| Version / team text | bottom-left (8, 524) | font, `N6` |
| "ExpoSimu 2026 · UPTC" | bottom-right | font, `N6` |

The left 320 px of the illustration must be calm (sky/fog) so buttons are readable.

## Files

| File | Size | Frames | FPS | Description |
|---|---|---|---|---|
| `menu_bg_sky.png` | 960×540 | 1 | — | Back layer, opaque |
| `menu_bg_city.png` | 1024×540 | 2 | 1 | Middle layer, transparent; frame 2 has different lit windows. 64 px wider for slow parallax drift |
| `menu_bg_front.png` | 960×540 | 2 | 3 | Front layer, transparent; ambulance lights alternate amber/blue, tape flutter |

## Acceptance checklist

- [ ] Sketch at `designs/evidence/sketches/main_menu.jpg`
- [ ] 3 PNGs
- [ ] Composite screenshot with the logo and buttons looks clean at 1080p
