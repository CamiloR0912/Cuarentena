# prop_10 — Barricades (hospital night defense)

| Field | Value |
|---|---|
| Priority | **P2** |
| Used in | Level 2, night phase (waves attack the entrance) |
| Output folder | `juego/assets/sprites/props/barricades/` |
| Size | **64×48 px** per frame |
| Collision | 64×20 while not destroyed |

## Description

Improvised barricade at the hospital entrance: overturned stretchers, wooden planks, mattresses, a vending machine.

| File | Frames | Description |
|---|---|---|
| `barricade.png` | **4** damage states: intact, damaged, heavily damaged, destroyed (rubble, no collision) | Code picks the frame from barricade HP (100 / 66 / 33 / 0 %) |
| `barricade_hit.png` | 2 (16 fps) | Shake frames: barricade offset 1 px left/right, plays when hit |

## Acceptance checklist

- [ ] 2 PNGs (256×48 and 128×48)
- [ ] Damage states readable at a glance
