# prop_11 — Street lights and emergency lights (objects)

| Field | Value |
|---|---|
| Priority | **P2** |
| Used in | Levels 1, 2 (night), 3 |
| Output folder | `juego/assets/sprites/props/lights/` |
| Note | These are the **objects**. The light they cast is the overlay `vfx_06` |

| File | Size | Frames | FPS | Description |
|---|---|---|---|---|
| `streetlamp_modern.png` | 16×64 | 2 (on / off) | — | Grey pole `N5`, lamp head; "on" bulb in `A2` |
| `streetlamp_flicker.png` | 16×64 | 4 | 10 | Broken lamp flickering (on, off, on, off with irregular timing — code randomizes) |
| `emergency_beacon.png` | 16×16 | 4 | 8 | Rotating amber beacon on a pole or wall (`A1`/`A2`) |
| `hospital_red_cross_sign.png` | 32×32 | 2 | 1 | Illuminated red cross sign, blinking slowly |
| `light_tower.png` | 32×64 | 1 | — | Portable military flood light (checkpoint in Level 3) |

## Acceptance checklist

- [ ] 5 PNGs
- [ ] Each light object has a bright pixel center that matches where code places the light overlay (document the center point in the PNG filename comment or here: lamp center = (8, 6) for streetlamps)
