# vfx_08 — Drop and pickup effects

| Field | Value |
|---|---|
| Priority | **P2** |
| Used in | Drops from neutralized enemies (categorical distribution), picking items up |
| Output folder | `juego/assets/vfx/` |

## Files

| File | Size per frame | Frames | FPS | Loop | Description |
|---|---|---|---|---|---|
| `drop_pop.png` | 16×16 | 4 | 15 | no | Small white puff when an item drops from an enemy |
| `rare_sparkle.png` | 24×24 | 4 | 8 | yes | 4-point twinkle stars around rare items (viral sample, adrenaline). `G4` for sample (code can use `rare_sparkle_amber.png` for adrenaline) |
| `rare_sparkle_amber.png` | 24×24 | 4 | 8 | yes | Same in `A2` |
| `pickup_collect.png` | 16×16 | 4 | 15 | no | Item shrinks into a ring of 4 `N8` pixels moving up |
| `nothing_dropped.png` | 16×16 | 3 | 8 | no | Tiny grey dust puff (`N6`) — "nothing" outcome (p = 0.30–0.45). Shows that the roll happened |

## Acceptance checklist

- [ ] 5 PNGs
