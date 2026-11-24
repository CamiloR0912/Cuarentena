# vfx_06 — Lighting (night overlay and light sprites)

| Field | Value |
|---|---|
| Priority | **P2** (P1 for the Level 2 night phase) |
| Used in | Level 2 nights, Level 3, emergency lights everywhere |
| Output folder | `juego/assets/vfx/light/` |
| Type | Overlay |

## How it works in code

1. Code fills a 960×540 "darkness" surface with `B0 #1E2E3D` (alpha 70% at night, 0% by day, ~35% in Level 3 fog).
2. Light sprites are drawn into it with subtractive blending, punching holes in the darkness.
3. Colored light sprites are then drawn additively on top for tint.

So the artist only draws **light shapes**.

## Files

| File | Size | Frames | Description |
|---|---|---|---|
| `light_radial_128.png` | 128×128 | 1 | White circle, **stepped (posterized) falloff in 5 bands** (100%, 80%, 55%, 30%, 10% alpha) with 1-px dither between bands. No smooth gradient (keeps pixel-art look) |
| `light_radial_256.png` | 256×256 | 1 | Same, bigger (street lamps, hospital entrance) |
| `light_player_96.png` | 96×96 | 1 | Small light around Elena so she is never lost in the dark |
| `light_cone_beam.png` | 128×64 | 1 | Flashlight/beacon cone pointing right, origin at (0, 32), stepped falloff |
| `light_tint_amber.png` | 128×128 | 1 | Same shape as radial_128 but in `A1` (emergency lights glow), max alpha 35% |
| `light_tint_blue.png` | 128×128 | 1 | `C1`, max alpha 30% (hospital, ambulance) |
| `light_tint_red.png` | 128×128 | 1 | `R1`, max alpha 30% (alarm, boss charge) |

The emergency beacon rotation is done by code rotating `light_cone_beam.png`.

## Acceptance checklist

- [ ] 7 PNGs
- [ ] Bands visible but not ugly (test on the hospital map with 70% darkness)
