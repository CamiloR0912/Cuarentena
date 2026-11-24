# tile_04 — Tileset: University and laboratory

| Field | Value |
|---|---|
| Priority | **P2** |
| Used in | Level 4 (corridors, courtyards with Masa, auditorium boss arena, Dra. Mena's lab) |
| Output | `juego/assets/tilesets/universidad.png` + `universidad.tsx` |
| Tile size | 32×32, sheet width 8 tiles (256 px) |

## Mood

Modern public university building (concrete + brick, typical of UPTC), evacuated in a hurry. Narrow corridors (tension), open courtyards (swarms), a big auditorium (boss), and a clean, bright lab (hope: white and clinical blue).

## Tile list

### A. Corridors

| # | Tile | Variants |
|---|---|---|
| A1 | Corridor floor, polished concrete `N4`/`N5` | 3 |
| A2 | Wall top | Autotile 13 |
| A3 | Wall front (2 tall): plain brick, with lockers (`B1`), bulletin board with papers, classroom door frame, fire-extinguisher cabinet (red `R1`, hint for the weapon) | 5 |
| A4 | Decals: scattered papers, overturned chair (1 tile), biohazard sign on floor | 3 |

### B. Courtyards (patios)

| # | Tile | Variants |
|---|---|---|
| B1 | Grass | reuse barrio A8 |
| B2 | Brick path | 2 |
| B3 | Path ↔ grass border | Autotile 13 |
| B4 | Tree (top view canopy) | 2×2 tiles, canopy in `G1`/`G2` with `N0` trunk shadow (overhead layer so characters walk under) |

### C. Auditorium (boss arena, ~20×14 tiles)

| # | Tile | Variants |
|---|---|---|
| C1 | Wooden stage floor `W1`/`W2` | 3 |
| C2 | Stepped seating rows (each row 1 tile tall, seats `R0` fabric) | left end, middle, right end, aisle step |
| C3 | Stage edge (front face, 1 tile tall) | 3 |
| C4 | Projection screen on back wall | 4×2 tiles, shows a faded SIR chart (nice nod to the simulation) |

### D. Laboratory (final room)

| # | Tile | Variants |
|---|---|---|
| D1 | White lab floor `N8`/`N7` | 3 |
| D2 | Glass partition wall (`B2` with `N8` reflections) | Autotile 13 |
| D3 | Wall front: white panel, with shelves of reagents, with biohazard sign, airlock door frame | 4 |
| D4 | Floor safety line (yellow/black hazard stripe, `A1`/`N0`) | straight H/V + corners |

## Acceptance checklist

- [ ] Corridors 2–3 tiles wide feel narrow but readable
- [ ] Auditorium leaves at least 14×8 tiles of free floor for the boss
- [ ] Lab is the brightest, cleanest place in the game
