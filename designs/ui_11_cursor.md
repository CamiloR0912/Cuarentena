# ui_11 — Mouse cursors

| Field | Value |
|---|---|
| Priority | **P1** |
| Output folder | `juego/assets/ui/cursor/` |
| Note | The system cursor is hidden; code draws these on the 960×540 canvas so they scale with the pixel art |

| File | Size | Hot spot | Frames | Use |
|---|---|---|---|---|
| `cursor_crosshair.png` | 16×16 | (8, 8) | 1 | Default in-game aim: 4 short lines + center gap, `N8` with `N0` outline |
| `cursor_crosshair_enemy.png` | 16×16 | (8, 8) | 1 | Over an enemy within range: lines close in, `A1` |
| `cursor_crosshair_backstab.png` | 16×16 | (8, 8) | 2 (6 fps) | Over an enemy's back while undetected (stealth crit bonus available): `R1` with small eye in the center |
| `cursor_crosshair_cooldown.png` | 16×16 | (8, 8) | 1 | Weapon on cooldown: `N6` (greyed) |
| `cursor_pointer.png` | 12×12 | (0, 0) | 1 | Menus: arrow, `N8`, `N0` outline |
| `cursor_pointer_hover.png` | 12×12 | (0, 0) | 1 | Over a button: `C1` |

## Acceptance checklist

- [ ] 6 PNGs
- [ ] Hot spots documented exactly as above
