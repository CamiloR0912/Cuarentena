# char_06 — Paciente Cero (Patient Zero, boss)

| Field | Value |
|---|---|
| Priority | **P2** (last thing to draw among the characters) |
| Category | Boss |
| Used in | Level 4, university auditorium |
| Simulation model | Markov chain over phases {Wander, Charge, Cough, Call the Swarm} |
| Output folder | `juego/assets/sprites/enemies/paciente_cero/` |
| Cell size | **96×96 px** |
| Visible body | ~48×72 px |
| Pivot (feet) | (48, 90) |
| Collision box | 40×20 px |
| Facings | down, up, right |

## Visual description

- The first infected: a large man (was a lab technician at the university). **Still human**, but the fever has gone furthest in him.
- Torn lab coat (`N6`/`N5`, dirty with `G1`) over a hospital gown — mirror of Elena's white coat, gone grey: "what Elena could become".
- Skin `I1`/`I0`, visible veins in acid green (`G3`, 1 px lines on arms and neck), eyes glowing according to the phase (see below).
- Broken university ID card on the chest, a hospital wristband (`C1`) on one wrist.
- Very large shoulders, slightly hunched. Must fill the screen space as a boss without looking like a monster.

## Phase tells (each Markov state must be identifiable instantly)

| Phase | Eye color | Aura overlay color | Body pose |
|---|---|---|---|
| Wander (Deambular) | `N7` dull | none | Upright, slow sway |
| Charge (Embestida) | `R1` | `R1` | Lowered head, shoulder forward |
| Cough (Toser) | `G3` | `G3` | Chest puffed, hand on throat |
| Call the Swarm (Llamar a la Masa) | `A1` | `A1` | Arms raised, head back, screaming |

The aura is a separate overlay file per phase drawn behind the boss (code blits it first).

## Animations

| File | Phase | Frames | FPS | Loop | Rows | Notes |
|---|---|---|---|---|---|---|
| `pc_wander.png` | Wander | 6 | 6 | yes | 3 | Heavy walk |
| `pc_charge_windup.png` | Charge | 3 | 8 | no | 3 | Telegraph: scraping foot, 0.4 s |
| `pc_charge_run.png` | Charge | 4 | 14 | yes | 3 | Fast straight dash |
| `pc_charge_stun.png` | Charge | 3 | 6 | no | 1 | Crashed into wall, dizzy (punish window) |
| `pc_cough.png` | Cough | 6 | 8 | no | 3 | Big cough; emission frame = 4 → code spawns 3 clouds |
| `pc_summon.png` | Call the Swarm | 5 | 8 | no | 1 (down) | Arms up, scream on frame 3 → code spawns Masa |
| `pc_hurt.png` | — | 2 | 10 | no | 3 | |
| `pc_defeated.png` | — | 6 | 6 | no | 1 | Kneels, then falls asleep (sedated) — he is cured, not killed |
| `pc_sedated.png` | — | 2 | 2 | yes | 1 | Lying, peaceful face, eyes closed |
| `pc_aura_{charge,cough,summon}.png` | — | 4 | 8 | yes | 1 | 96×96 overlay, semi-transparent glow ring around the body (overlay asset: alpha 30–60% allowed) |

### Sheet sizes

| File | Size |
|---|---|
| wander | 576×288 |
| charge_windup, charge_run (4f) | 288×288 / 384×288 |
| charge_stun | 288×96 |
| cough | 576×288 |
| summon | 480×96 |
| hurt | 192×288 |
| defeated | 576×96 |
| sedated | 192×96 |
| aura (each) | 384×96 |

### Emission points (cell top-left)

| Facing | Mouth (cough) |
|---|---|
| down | (48, 30) |
| up | (48, 24) |
| right | (62, 28) |

## Acceptance checklist

- [ ] Sketch at `designs/evidence/sketches/paciente_cero.jpg` (front + side)
- [ ] 10 animation PNGs + 3 auras
- [ ] The 4 phases are distinguishable in a grayscale screenshot (pose alone), and in color (eyes + aura)
- [ ] Defeated animation conveys "saved", not "killed"
