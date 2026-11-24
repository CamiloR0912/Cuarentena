# prop_13 — Fixed pickup stations (first-aid box, pharmacy shelf)

| Field | Value |
|---|---|
| Priority | **P1** (first-aid box) / P2 (pharmacy) |
| Used in | All levels — the non-random scenery items of GDD §6.2 |
| Output folder | `juego/assets/sprites/props/stations/` |

These mark where fixed items are found (medkits +50 HP, antivirals −40% viral load). Interact with E.

| File | Size | Frames | Description |
|---|---|---|---|
| `firstaid_wall_box.png` | 32×32 | 2: full / empty | Wall-mounted white box (`N8`) with a red cross (`R1`). Empty = open door, nothing inside |
| `pharmacy_shelf.png` | 64×64 | 2: stocked / looted | Pharmacy shelf with pill bottles. "Stocked" has 1 glowing antiviral box (`C2`) |
| `pharmacy_sign.png` | 32×32 | 2 (2 fps) | Green neon pharmacy cross sign (`G3` / `G2` blink) — common on Colombian pharmacies; visible from far so the player finds antivirals |

## Acceptance checklist

- [ ] 3 PNGs
- [ ] Full vs empty state obvious (no need to walk up to check)
