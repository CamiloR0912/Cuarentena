# vfx_04 — Extinguisher spray cone

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | Extinguisher attack (90° cone, 3 tiles long) |
| Output folder | `juego/assets/vfx/` |
| Type | Overlay (alpha allowed) |

## File

| File | Size per frame | Frames | FPS | Loop |
|---|---|---|---|---|
| `extinguisher_spray.png` | **96×96** | 4 | 12 | yes (while held) |

## Description

- Drawn **pointing right**, the nozzle at the left-middle (0, 48). Code rotates in 90° steps (pixel-perfect) and flips for left.
- A 90° cone (±45° from the axis) of white powder: dense `N8` near the nozzle, `N7`/`C2` billows further, transparent edges (alpha 40–80%).
- Frames: billows shift outward to suggest flow. Frame 0 is the shortest (start), frames 1–3 full length (loop 1→3 while held; code may play 0 once).
- The visible cone must match the hit area: 96 px long = 3 tiles.

## Acceptance checklist

- [ ] 1 PNG (384×96)
- [ ] Rotated 90°, 180°, 270° it still looks right (no lighting baked that breaks when rotated)
