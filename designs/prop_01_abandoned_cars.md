# prop_01 — Abandoned cars

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | Levels 1, 3 (cover for stealth, blocks line of sight) |
| Output folder | `juego/assets/sprites/props/cars/` |
| Sizes | Horizontal: **64×40 px** (2 tiles long + roof height). Vertical: **40×64 px** |
| Collision | Horizontal 60×24 at the bottom of the sprite; vertical 32×56 |
| Outline | Yes, 1 px `N0` |

## Description

Top-down 3/4 view: you see the roof, the hood/trunk and one side. Dusty, windows dark (`B0` with a `B2` reflection line), some doors open.

| File | Description | Colors |
|---|---|---|
| `car_sedan_h.png` / `car_sedan_v.png` | Small sedan, typical Colombian city car | Body `B1`/`B2` |
| `car_taxi_h.png` / `car_taxi_v.png` | **Yellow taxi** (iconic in Colombia), desaturated | `A1`/`A0`, `N0` checker stripe |
| `car_suv_h.png` / `car_suv_v.png` | SUV, door open, suitcase on the roof | `N5`/`N4` |
| `car_wrecked_h.png` | Crashed sedan, front crumpled, broken glass around | `R0`/`N4` |
| `car_police_h.png` / `car_police_v.png` | Police car, lights off (green/white Colombian police colors, muted: `G1`/`N8`) | |

Each file is a **single frame**, except the police car: 2 frames (`64×40` → `128×40`) with the roof light alternating red/blue for a "battery still on" blink at 2 fps (optional, P3).

## Acceptance checklist

- [ ] 9 PNGs
- [ ] Bottom 8 px leaves room for the code-drawn shadow
- [ ] Elena crouched behind a car is fully hidden in the up-facing view (car height ≥ 24 px of visible body)
