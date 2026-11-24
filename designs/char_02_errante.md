# char_02 — Errante (Wanderer, infected)

| Field | Value |
|---|---|
| Priority | **P1** |
| Category | Enemy |
| Used in | Levels 1–4 |
| Simulation model | Random walk 2D with noise bias (Model 1); Markov stage 1 |
| Output folder | `juego/assets/sprites/enemies/errante/` |
| Cell size | 32×32 px |
| Visible body | ~16×28 px |
| Pivot (feet) | (16, 30) |
| Collision box | 12×8 px on pivot |
| Facings | down, up, right |

## Visual description

- An ordinary citizen of Tunja, sick with the Grey Fever: **disoriented, not monstrous**.
- Skin in infected ramp (`I1` base, `I0` shadow, `I2` highlight), dark circles under the eyes (`I0`), slightly open mouth.
- Everyday clothes, desaturated: grey-green jacket (`G1`/`G2`), dark trousers (`N3`). Hunched shoulders, head tilted, arms hanging.
- The silhouette must be **different from the Corredor** (upright vs. leaning forward) and from citizens (citizens stand straight, saturated clothes).
- Make **2 color variants** of the clothes so groups don't look cloned: variant A jacket `G1/G2`, variant B sweater `B1/B2` with `N4` trousers. Skin and pose identical.

## Animations

| File | Frames | FPS | Loop | Rows | Notes |
|---|---|---|---|---|---|
| `errante_idle.png` | 2 | 3 | yes | 3 | Swaying 1 px left-right |
| `errante_walk.png` | 4 | 6 | yes | 3 | Shuffling, dragging one foot. Slow (1.2 px/frame) |
| `errante_attack.png` | 4 | 10 | no | 3 | Clumsy arm swipe. Hit frame = 2 |
| `errante_hurt.png` | 2 | 10 | no | 3 | Recoil + white flash by code |
| `errante_sedated.png` | 2 | 2 | yes | 1 | Lying on the ground, sleeping, slow breathing (chest moves 1 px). Calm face. Cell still 32×32 (body horizontal) |
| `errante_wake_up.png` | 3 | 6 | no | 1 | Gets up from the sedated pose; ends in `idle` down pose |

Variant B: same files with suffix `_b` (e.g. `errante_walk_b.png`).

### Sheet sizes

| File | Size |
|---|---|
| idle, hurt | 64×96 |
| walk, attack | 128×96 |
| sedated | 64×32 |
| wake_up | 96×32 |

## Acceptance checklist

- [ ] Sketch at `designs/evidence/sketches/errante.jpg`
- [ ] 6 PNGs × 2 variants
- [ ] Readable as "sick person", not zombie (no wounds, no blood)
- [ ] Sedated pose clearly different from standing (needed for the "carry with E" mechanic)
