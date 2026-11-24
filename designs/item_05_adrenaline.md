# item_05 — Adrenalina (Adrenaline, rare)

| Field | Value |
|---|---|
| Priority | **P2** |
| Effect | +10% p_crit and +30% speed for 20 s |
| Source | Rare random drop (Errante 0.01, Tosedor 0.02, Corredor 0.03, Masa 0.05) |
| In-game name | "Adrenalina" |
| Output folder | `juego/assets/sprites/items/` |

## Files

| File | Size | Frames | FPS | Description |
|---|---|---|---|---|
| `adrenaline_world.png` | 16×16 | 2 | 4 | Auto-injector pen: yellow-amber body (`A1`/`A0`), red cap (`R1`), small lightning mark (`A2`). Frame 2 = highlight shift |
| `adrenaline_icon.png` | 32×32 | 1 | — | Pen bigger, lightning symbol readable |

Gets the rare-drop sparkle (`vfx_08`). Active effect icon in `ui_06`.

## Acceptance checklist

- [ ] 2 PNGs
- [ ] Distinguishable from the sedative syringe weapon (`weapon_04`) — pen shape vs syringe shape
