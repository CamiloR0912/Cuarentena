# ui_05 — Vitals: HP bar and viral load bar

| Field | Value |
|---|---|
| Priority | **P1** |
| Position | HP: icon (8,484), bar (24,485). Viral load: icon (8,502), bar (24,503). Bars 160×10 |
| Output folder | `juego/assets/ui/hud/` |

## Bars

Bars use `bar_frame.png` from `ui_01`; code fills the inside. The artist provides icons and fill textures.

| Bar | Fill color | Low/high state |
|---|---|---|
| HP (0–100) | `C1` with `C2` top row | < 25 HP: fill turns `R1`, icon blinks |
| Viral load (0–100%) | `G2` with `G3` top row, `G1` stripes | > 75%: fill pulses `G3`/`G4` |

Damage "ghost": when HP drops, a `N8` segment shows the lost amount and shrinks over 0.4 s (code).

## Files

| File | Size | Frames | Description |
|---|---|---|---|
| `icon_hp.png` | 12×12 | 2 (normal, low-HP blink) | Heart with a medical cross (`R1` heart, `N8` cross) |
| `icon_viral.png` | 12×12 | 2 (normal, high blink) | Virus particle: round body with 6 spikes (`G3`, `G1` shadow) |
| `bar_fill_hp.png` | 4×8 | 1 | Tileable fill slice |
| `bar_fill_viral.png` | 4×8 | 1 | Tileable fill slice with stripe |
| `bar_fill_low.png` | 4×8 | 1 | Red fill slice (low HP) |
| `mask_shield_overlay.png` | 160×10 | 1 | Blue dotted outline drawn over the viral bar while the mask is active (−50% intake) |

## Acceptance checklist

- [ ] 6 PNGs
- [ ] HP (blue) and viral load (green) never confused
