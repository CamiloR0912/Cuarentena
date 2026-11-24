# item_03 — Cubrebocas (Face mask)

| Field | Value |
|---|---|
| Priority | **P1** |
| Effect | −50% viral load received for 90 s. Distributing masks also lowers β in the SIR model |
| Source | Random drop (Errante 0.10, Tosedor 0.20, Corredor 0.10, Masa 0.15) |
| In-game name | "Cubrebocas" |
| Output folder | `juego/assets/sprites/items/` |

## Files

| File | Size | Description |
|---|---|---|
| `facemask_world.png` | 16×16 | Folded surgical mask, clinical blue (`C1`/`C0`), white ear loops (`N8`) |
| `facemask_icon.png` | 32×32 | Unfolded mask with pleats visible, `C2` highlights |

The **active effect icon** (shown in the HUD while the 90 s run) is in `ui_06`.

See item rules in `item_01`.

## Acceptance checklist

- [ ] 2 PNGs
- [ ] Blue = protection, consistent with the palette rules
