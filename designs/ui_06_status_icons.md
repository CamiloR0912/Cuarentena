# ui_06 — Active effect / status icons

| Field | Value |
|---|---|
| Priority | **P1** (mask, crouch, carrying) / P2 (rest) |
| Position | Row at (8, 520), 18 px apart (see `ui_00`) |
| Output | `juego/assets/ui/hud/status_icons.png` |
| Cell | **16×16** per icon, single row |

Each icon is drawn on a small dark rounded square (`N1` + 1 px colored border). Code draws the remaining time as a number to the right, and a 1 px border that depletes clockwise.

| # | Icon | Border color | Meaning |
|---|---|---|---|
| 0 | Face mask | `C1` | Mask active (90 s, −50% viral intake) |
| 1 | Lightning | `A1` | Adrenaline (20 s, +10% p_crit, +30% speed) |
| 2 | Crouching figure / closed eye | `N7` | Stealth (crouched) — back attacks get +0.25 p_crit |
| 3 | Open eye | `R1` | Detected by an enemy (no stealth bonus) |
| 4 | Figure carrying a body | `C1` | Carrying a sedated patient (can't attack) |
| 5 | Ear with waves | `A1` | Noise heard by enemies (flashes) |
| 6 | Virus with "+" | `G3` | Inside a contagion cloud (+2%/s) |

Sheet: 7 × 16 = **112×16**.

## Acceptance checklist

- [ ] 1 PNG
- [ ] Each icon recognizable at 1× without the label
