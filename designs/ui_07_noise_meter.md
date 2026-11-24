# ui_07 — Noise meter

| Field | Value |
|---|---|
| Priority | **P1** |
| Mechanic | M6 stealth & noise; biases enemies' random walk (Model 1) and alerts Corredores (Model 4) |
| Position | (200, 484) on the bottom bar |
| Output folder | `juego/assets/ui/hud/` |

## Description

5 vertical bars like a signal meter, growing in height left → right (heights 4, 7, 10, 13, 16 px; width 6 px; gap 2 px → total 38×16). Below: label "RUIDO" (font).

| Noise | Lit bars | Color of lit bars |
|---|---|---|
| 0–10 (crouched) | 1 | `N7` |
| 11–30 (walking) | 2 | `A2` |
| 31–50 | 3 | `A1` |
| 51–70 (running) | 4 | `A1` |
| 71–100 (combat) | 5 | `R1` |

## Files

| File | Size | Frames | Description |
|---|---|---|---|
| `noise_meter.png` | 40×16 | **6** (0 to 5 bars lit) → 240×16 | Unlit bars `N3` with `N0` outline; lit bars colored as in the table |
| `noise_meter_pulse.png` | 40×16 | 2 | Overlay flash when the noise spikes (combat) |

## Acceptance checklist

- [ ] 2 PNGs
- [ ] Amber = noise rule respected
