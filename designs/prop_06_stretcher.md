# prop_06 — Stretcher (camilla) — queue server

| Field | Value |
|---|---|
| Priority | **P1** — key element to show the M/M/c model in the video |
| Used in | Level 2 (triage hall), and decoration in Level 1 / 3 |
| Simulation link | Each **open** stretcher = 1 server *c*. Player opens/closes them with + / − |
| Output folder | `juego/assets/sprites/props/hospital/` |
| Size | **32×64 px** (vertical: patient's head at the top), single tile wide |
| Collision | 28×56 |

## States (one PNG each)

The state must be readable from across the room, because the viewer must "see" c and ρ.

| File | Frames | FPS | State | Look |
|---|---|---|---|---|
| `stretcher_closed.png` | 1 | — | Closed (not a server) | Folded, pushed against the wall, grey (`N6`/`N5`), no sheet |
| `stretcher_open_empty.png` | 2 | 2 | Open, idle server | White sheet (`N8`), pillow, small **blue light on the bed's monitor** blinking (`C1` / `C2`) |
| `stretcher_occupied.png` | 2 | 2 | Busy server | Patient lying under the sheet: generic patient, head visible (`I1` skin for sedated infected; code may use variant below for citizens), IV bag stand (`N7` pole, `C2` bag), monitor shows an amber heartbeat blip |
| `stretcher_occupied_citizen.png` | 2 | 2 | Busy server (healthy citizen) | Same, patient skin `S2` |
| `stretcher_discharge.png` | 3 | 6 | Patient recovered (service completed) | Patient sits up, sheet pulled back; ends empty. Plays once, then `open_empty` |

Also needed:

| File | Size | Description |
|---|---|---|
| `wheelchair.png` | 32×32 | Decorative, `N6`/`B1` |
| `waiting_chairs.png` | 96×32 | Row of 3 plastic waiting-room seats (`C0`) — the queue area. Code places waiting patients on/in front of these |

## Acceptance checklist

- [ ] 7 PNGs
- [ ] Closed vs open-empty vs occupied distinguishable in a 50% scaled screenshot
- [ ] Staff (`char_08`) standing next to the right side of the stretcher looks natural
