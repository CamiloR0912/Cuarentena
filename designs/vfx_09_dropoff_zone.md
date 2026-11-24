# vfx_09 — Safe drop-off zone

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | Behind ambulances and at the hospital entrance (deliver sedated infected / escorted citizens) |
| Simulation link | Entering it = a new arrival in the M/M/c queue |
| Output folder | `juego/assets/vfx/` |
| Type | Overlay, drawn on the ground layer (under characters) |

## Files

| File | Size per frame | Frames | FPS | Loop | Description |
|---|---|---|---|---|---|
| `dropoff_zone.png` | **64×64** | 4 | 6 | yes | Ground ring (ellipse 64×40 in 3/4 view) in `C1`, dashed, rotating dashes; inner fill `C1` at 15% alpha; small cross symbol in the center `N8` |
| `dropoff_confirm.png` | 64×64 | 5 | 15 | no | Burst when a patient is delivered: ring expands, a "+1" shape rises (`C2`) |

## Acceptance checklist

- [ ] 2 PNGs
- [ ] Visible from across the screen in Level 3 fog
