# prop_08 — Hospital furniture

| Field | Value |
|---|---|
| Priority | **P1** (supply shelf, reception) / P2 (rest) |
| Used in | Level 2 |
| Output folder | `juego/assets/sprites/props/hospital/` |

| File | Size | Collision | Frames | Description |
|---|---|---|---|---|
| `reception_desk.png` | 96×48 | 96×24 | 1 | Triage desk, `N7` top, `C1` front panel, computer monitor + papers |
| `supply_shelf.png` | 64×64 | 64×24 | **4** (stock levels: full, 66%, 33%, empty) | Metal shelf with medical supply boxes (`N8` boxes with `C1`/`R1` cross). Shows the hospital supplies resource; code picks the frame by remaining supplies |
| `iv_stand.png` | 16×48 | 8×8 | 1 | IV pole with bag |
| `monitor_cart.png` | 32×48 | 24×12 | 2 (2 fps) | Vital-signs monitor on wheels, green ECG line blinking (`G3`) |
| `medicine_cabinet.png` | 32×64 | 32×16 | 1 | Wall cabinet, glass doors, bottles |
| `biohazard_bin.png` | 16×24 | 12×8 | 1 | Red container `R1` with biohazard symbol |
| `oxygen_tanks.png` | 32×32 | 24×12 | 1 | 2–3 green-grey tanks `G1`/`N5` |
| `hospital_sign_triage.png` | 64×32 | none | 1 | Hanging sign "TRIAGE" (wall decal) |

## Acceptance checklist

- [ ] 8 PNGs
- [ ] Supply shelf frames are clearly different (it's a resource indicator)
