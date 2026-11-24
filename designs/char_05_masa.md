# char_05 — Masa individual (Swarm member)

| Field | Value |
|---|---|
| Priority | **P2** |
| Category | Enemy (spawned in groups of 8–15) |
| Used in | Levels 3, 4 (and boss summon) |
| Simulation model | Agents with boids rules (Model 4): separation, alignment, cohesion; order parameter φ |
| Output folder | `juego/assets/sprites/enemies/masa/` |
| Cell size | 32×32 px |
| Visible body | **~14×22 px** (smaller than other enemies so 15 of them fit and the flock shape is visible) |
| Pivot (feet) | (16, 30) |
| Collision box | 10×6 px |
| Facings | down, up, right (code picks the facing from the velocity vector's dominant axis) |

## Visual description

- Many sick people moving together: **simpler, less detailed figures**, the group shape matters more than the individual.
- Skin `I1`/`I0`. Clothes in muted tones. Arms slightly forward, heads down.
- **3 color variants** (separate files) so the flock looks like a crowd, not clones:
  - A: jacket `G1`/`G2`, trousers `N3`
  - B: jacket `N4`/`N5`, trousers `B1`
  - C: jacket `W1`/`W2`, trousers `N2`
- Keep the head and shoulders area identical across variants so the alignment of the flock (all pointing the same way) is easy to read → that is what visually shows φ ≈ 1.

## Animations

| File | Frames | FPS | Loop | Rows | Notes |
|---|---|---|---|---|---|
| `masa_walk_{a,b,c}.png` | 4 | 8 | yes | 3 | Also used for fleeing after dispersal at 12 fps |
| `masa_attack_{a,b,c}.png` | 2 | 6 | yes | 3 | Contact pushing/grabbing (damage per second while touching) |
| `masa_hurt_{a,b,c}.png` | 1 | — | no | 3 | Single recoil frame + white flash by code |
| `masa_sedated_{a,b,c}.png` | 2 | 2 | yes | 1 | Lying, small |

### Sheet sizes

| File | Size |
|---|---|
| walk | 128×96 |
| attack | 64×96 |
| hurt | 32×96 |
| sedated | 64×32 |

## Acceptance checklist

- [ ] Sketch at `designs/evidence/sketches/masa.jpg`
- [ ] 4 animations × 3 variants = 12 PNGs
- [ ] Test: place 15 sprites on asphalt in a screenshot; the flock reads as one group and the heading direction is obvious
