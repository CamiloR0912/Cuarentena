# char_04 — Corredor (Runner, infected)

| Field | Value |
|---|---|
| Priority | **P2** (appears from Level 2 night waves / Level 3) |
| Category | Enemy |
| Used in | Levels 2 (nights), 3, 4 |
| Simulation model | Agent with finite-state machine (Model 4): PATROL → ALERT → CHASE → SEARCH; Markov stage 3 (absorbing) |
| Output folder | `juego/assets/sprites/enemies/corredor/` |
| Cell size | 32×32 px |
| Visible body | ~16×27 px, leaning forward |
| Pivot (feet) | (16, 30) |
| Collision box | 12×8 px |
| Facings | down, up, right |

## Visual description

- Final stage of the fever: **feverish and aggressive**. Lean, tense, leaning forward, fists clenched.
- Skin `I1`/`I0` with **red flush on cheeks and eyes** (`R1`, 1 px each eye) — red = danger rule.
- Torn sporty clothes: hoodie in `R0` with `R1` highlights (the only enemy with red clothing, so the player identifies it instantly), dark trousers `N2`.
- Sweat drops 1 px `N7` in run frames.
- The **FSM state must be readable from the pose alone** (important for the gameplay video, which must show the agent model clearly). Status icons above the head (`vfx_07`) reinforce it.

## Animations (one per FSM state + combat)

| File | FSM state | Frames | FPS | Loop | Rows | Notes |
|---|---|---|---|---|---|---|
| `corredor_patrol.png` | PATROL | 4 | 8 | yes | 3 | Restless walk, head turning |
| `corredor_alert.png` | ALERT | 3 | 6 | no | 3 | Stops, head snaps toward sound, body tenses (hold last frame) |
| `corredor_chase.png` | CHASE | 6 | 14 | yes | 3 | Full sprint, leaning 20°, arms pumping (3.5 px/frame) |
| `corredor_search.png` | SEARCH | 4 | 5 | yes | 1 (down) | Looks left, center, right, center — standing still |
| `corredor_attack.png` | — | 4 | 12 | no | 3 | Lunge + two-hand grab. Hit frame = 2 |
| `corredor_hurt.png` | — | 2 | 10 | no | 3 | |
| `corredor_sedated.png` | — | 2 | 2 | yes | 1 | Lying face down, twitching 1 px on frame 2 |
| `corredor_wake_up.png` | — | 3 | 8 | no | 1 | Faster than other enemies |

### Sheet sizes

| File | Size |
|---|---|
| patrol, attack | 128×96 |
| alert | 96×96 |
| chase | 192×96 |
| search | 128×32 |
| hurt | 64×96 |
| sedated | 64×32 |
| wake_up | 96×32 |

## Acceptance checklist

- [ ] Sketch at `designs/evidence/sketches/corredor.jpg`
- [ ] 8 PNGs
- [ ] Red hoodie makes it the most visible enemy
- [ ] A viewer can tell PATROL / ALERT / CHASE / SEARCH apart without the icons
