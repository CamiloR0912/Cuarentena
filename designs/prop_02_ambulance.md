# prop_02 — Ambulance (delivery zone)

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | Levels 1, 3 (drop-off point for sedated infected and rescued citizens), Level 2 (bay) |
| Simulation link | Delivering here adds a patient to the M/M/c queue (arrivals λ) |
| Output folder | `juego/assets/sprites/props/ambulance/` |
| Sizes | Horizontal **96×48 px** (3 tiles), vertical **48×96 px** |
| Collision | Horizontal 92×28 at the bottom; vertical 40×88 |

## Description

- Colombian-style ambulance van: white body (`N8`/`N7`), **clinical-blue stripe** (`C1`), red cross/star of life on the roof (`R1`), "AMBULANCIA" mirrored on the hood implied with 1 px marks.
- **Rear doors open** facing the street (where Elena loads patients).
- Roof light bar.

## Frames

| File | Frames | FPS | Notes |
|---|---|---|---|
| `ambulance_h.png` | 2 | 3 | Light bar alternates amber/blue (`A1` / `C1`) |
| `ambulance_v.png` | 2 | 3 | Same, vertical orientation |

The pulsing **drop-off zone** on the ground behind the doors is a separate VFX (`vfx_09`).

## Acceptance checklist

- [ ] 2 PNGs (192×48 and 96×96)
- [ ] Reads instantly as "safe zone" (white + blue), visible from far away
