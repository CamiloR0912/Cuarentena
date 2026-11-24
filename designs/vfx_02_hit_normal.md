# vfx_02 — Normal hit impact

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | Every non-critical hit of the player on an enemy, and enemy hits on Elena |
| Simulation link | Monte Carlo damage sample D without critical |
| Output folder | `juego/assets/vfx/` |

## File

| File | Size per frame | Frames | FPS | Loop |
|---|---|---|---|---|
| `hit_normal.png` | 32×32 | 4 | 20 | no |

## Description

- Frame 0: small white star burst (`N8`), 8 px.
- Frame 1: star expands to 16 px, `N7` edges, 3–4 short grey sparks (`N6`) flying outward.
- Frame 2: ring of sparks at 22 px, center gone.
- Frame 3: 2–3 fading pixels.
- **No blood, no red.** Red is reserved for criticals.

The damage number (`ui_10`) floats up from the same point.

## Acceptance checklist

- [ ] 1 PNG (128×32)
- [ ] Visible on both dark asphalt and white hospital floor (thin `N0` outline on frame 0–1)
