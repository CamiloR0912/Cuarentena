# ui_01 — UI kit (panels, buttons, bar frames)

| Field | Value |
|---|---|
| Priority | **P1** — every screen and HUD element reuses these |
| Output folder | `juego/assets/ui/kit/` |
| Technique | **9-slice**: corners stay fixed, edges and center stretch (repeat) in code. Corner size given per file |

## Style

Clinical, "medical equipment" look: dark panels (`N1`) with a thin clinical-blue border (`C0`, highlight `C1` on the top edge), 1 px `N0` outer outline, square corners with 1 px cut (chamfer). Small screw dots (`N5`) in corners of radio-style panels.

## Files

| File | Size | 9-slice corner | States / frames | Description |
|---|---|---|---|---|
| `panel_dark.png` | 24×24 | 8 px | 1 | Default panel. Center `N1` at **90% alpha** (overlay allowed) |
| `panel_solid.png` | 24×24 | 8 px | 1 | Same, center 100% opaque (top/bottom HUD bars) |
| `panel_warning.png` | 24×24 | 8 px | 1 | Amber border (`A1`) — warnings, radio alerts |
| `panel_danger.png` | 24×24 | 8 px | 1 | Red border (`R1`) — game over, collapse warnings |
| `panel_radio.png` | 32×32 | 10 px | 1 | Radio device look: `B1` metal frame, 4 screw dots, speaker grille texture on the left edge |
| `button.png` | 24×24 (per state) | 8 px | **4 states** in a row: normal, hover, pressed, disabled → 96×24 | Normal: `N3` fill, `C0` border. Hover: `C0` fill, `C1` border, `N8` 1 px inner highlight. Pressed: content 1 px lower, `B0` fill. Disabled: `N2` fill, `N4` border |
| `button_danger.png` | 96×24 | 8 px | 4 states | Same in red tones (e.g. "Salir", "Rechazar") |
| `bar_frame.png` | 8×12 | 3 px | 1 | Frame for any progress bar (HP, viral load, patience), 1 px `N0` + 1 px `N4` |
| `slot.png` | 40×40 | — | 3: empty, filled, selected → 120×40 | Inventory slot. Selected: `C1` 2 px border + corner brackets |
| `divider_h.png` | 8×4 | — | 1 | Horizontal separator line (repeat) |
| `tooltip.png` | 16×16 | 5 px | 1 | Small text balloon for item names |

## Acceptance checklist

- [ ] 11 PNGs
- [ ] Test: a 300×120 panel built from 9-slice shows no stretched corners
- [ ] Button states distinguishable without color (pressed = offset)
