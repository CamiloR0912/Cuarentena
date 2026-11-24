# vfx_05 — Dart projectile

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | Dart pistol shots (flies in the exact mouse direction, not just 4 directions) |
| Output folder | `juego/assets/vfx/` |

## Files

| File | Size per frame | Frames | Description |
|---|---|---|---|
| `dart_projectile.png` | 8×8 | **8 directions** (0°, 45°, 90°, …, 315°, counter-clockwise starting pointing right) | Tiny dart: 1 px steel needle (`N7`), 2 px barrel (`G3`), amber tail (`A1`). Code picks the frame closest to the travel angle |
| `dart_trail.png` | 4×4 | 2 | Fading trail puff (`N7` 50% → 20%) left behind every 4 px |

## Acceptance checklist

- [ ] 2 PNGs (64×8 and 8×4)
- [ ] Visible at full speed on dark ground (amber tail does this)
