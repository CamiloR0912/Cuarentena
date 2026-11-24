# prop_04 — Barriers and fences (quarantine perimeter)

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | All outdoor levels — define level limits and funnel the player |
| Output folder | `juego/assets/sprites/props/barriers/` |

| File | Size | Collision | Description |
|---|---|---|---|
| `jersey_barrier_h.png` | 64×32 | 64×16 | Concrete road barrier, `N5`/`N4`, amber reflective stripe (`A1`) |
| `jersey_barrier_v.png` | 24×64 | 16×64 | Same, vertical |
| `sawhorse_quarantine.png` | 32×32 | 28×8 | Police sawhorse with sign "CUARENTENA — NO PASAR" (red/white stripes `R1`/`N8`; text implied by 1 px marks, readable word not needed) |
| `fence_chainlink_h.png` | 32×48 | 32×8 | **Tileable** horizontal chain-link fence segment (mesh pattern `N6` 50% visible through: draw mesh as 1 px diagonal grid with transparency gaps) |
| `fence_chainlink_v.png` | 16×64 | 8×64 | Tileable vertical segment |
| `fence_chainlink_post.png` | 16×48 | 8×8 | End post |
| `traffic_cone.png` | 16×16 | 10×6 | Orange cone (`A1`, `N8` band) |

Chain-link segments must connect seamlessly when placed side by side.

## Acceptance checklist

- [ ] 7 PNGs
- [ ] Fence segments tile without seams
- [ ] Characters behind the chain-link fence remain visible (mesh, not solid)
