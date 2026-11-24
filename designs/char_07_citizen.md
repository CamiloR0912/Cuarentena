# char_07 — Ciudadano sano (Healthy citizen, rescuable NPC)

| Field | Value |
|---|---|
| Priority | **P1** (variants C and D can be P2) |
| Category | NPC |
| Used in | Levels 1, 3 (rescue and escort), Level 2 (arriving patients) |
| Simulation model | Agents with panic state P ∈ [0,1] (Model 4); street contagion with p_contagio |
| Output folder | `juego/assets/sprites/npc/citizen/` |
| Cell size | 32×32 px |
| Visible body | ~16×28 px |
| Pivot (feet) | (16, 30) |
| Collision box | 12×8 px |
| Facings | down, up, right |

## Visual description

- Healthy people: **normal skin tones** (`S0`–`S3`), **upright posture**, saturated (relative to the palette) clothes. They must contrast with the grey-green infected.
- 4 variants, each one a separate set of files (local characters from Tunja):

| Variant | Description | Key colors |
|---|---|---|
| A `student` | University student, backpack, jeans | `C0` jacket, `B1` jeans, `A0` backpack |
| B `vendor` | Market vendor with apron and **ruana** | `A1`/`A0` ruana, `N8` apron |
| C `elder` | Elderly woman with a shawl and a cane | `R0` shawl, `N6` grey hair |
| D `worker` | Office worker with a tie and a face mask | `N4` suit, `N8` shirt, `C2` mask |

- Panic is shown by posture (calm → upright; panicked → arms up, running). Code adds an amber "!" icon (`vfx_07`) above P ≥ 0.5.

## Animations (per variant)

| File | Frames | FPS | Loop | Rows | Notes |
|---|---|---|---|---|---|
| `citizen_<v>_idle.png` | 2 | 3 | yes | 3 | Calm, waiting (P < 0.5, following Elena) |
| `citizen_<v>_walk.png` | 4 | 8 | yes | 3 | Following Elena |
| `citizen_<v>_panic_run.png` | 6 | 12 | yes | 3 | Arms raised, fleeing (P ≥ 0.5) |
| `citizen_<v>_cower.png` | 2 | 4 | yes | 1 | Crouched, covering head (cornered, P ≈ 1) |
| `citizen_<v>_infected.png` | 4 | 6 | no | 1 | Transformation: coughs, skin turns grey. Last frame = Errante idle down. Code then replaces the entity with an Errante |

### Sheet sizes

| File | Size |
|---|---|
| idle | 64×96 |
| walk | 128×96 |
| panic_run | 192×96 |
| cower | 64×32 |
| infected | 128×32 |

## Acceptance checklist

- [ ] Sketches at `designs/evidence/sketches/citizen_<v>.jpg`
- [ ] 5 PNGs × 4 variants
- [ ] In a mixed screenshot, healthy vs infected is obvious from color alone
