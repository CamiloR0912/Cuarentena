# item_01 — Vendas (Bandage)

| Field | Value |
|---|---|
| Priority | **P1** |
| Effect | +25 HP |
| Source | Random drop (Errante 0.25, Tosedor 0.20, Corredor 0.20, Masa 0.25) |
| In-game name | "Vendas" |
| Output folder | `juego/assets/sprites/items/` |

## Files

| File | Size | Description |
|---|---|---|
| `bandage_world.png` | 16×16 | Pickup on the ground: rolled white bandage (`N8`/`N7`) with a loose end, small `R1` cross clip. 1 px `N0` outline. Code makes it bob 1 px and draws a soft shadow |
| `bandage_icon.png` | 32×32 | Inventory/HUD icon: same object bigger and more detailed (two rolls + safety pin). No background (the slot provides it) |

## Rules shared by every item

- World sprite: object fits in **12×12** centered, bottom at row 14, 1 px outline.
- Icon: object fits in **26×26** centered, 1 px outline, top-left highlight.
- Items must be recognizable **by silhouette alone** (the player decides fast during combat).

## Acceptance checklist

- [ ] 2 PNGs
- [ ] Distinguishable from the medkit (`item_06`) at 1×
