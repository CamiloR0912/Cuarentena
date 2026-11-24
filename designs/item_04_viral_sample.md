# item_04 — Muestra viral (Viral sample)

| Field | Value |
|---|---|
| Priority | **P1** |
| Effect | Quest item: 5 needed in Level 3, 10 delivered in Level 4. Stacks in one inventory slot |
| Source | Random drop (Errante 0.04, Tosedor 0.08, Corredor 0.12, Masa 0.20) |
| In-game name | "Muestra viral" |
| Output folder | `juego/assets/sprites/items/` |

## Files

| File | Size | Frames | FPS | Description |
|---|---|---|---|---|
| `sample_world.png` | 16×16 | **4** | 6 | Small sealed test tube with a cap (`N8` cap, `B2` glass) containing **glowing acid-green liquid** (`G3`, `G4` highlight). Frames: the glow pixel moves / pulses — the most eye-catching drop |
| `sample_icon.png` | 32×32 | 1 | — | Tube in a small holder with a biohazard label (`A1` tiny triangle) |

The world sprite also gets the rare-drop sparkle (`vfx_08`) on top.

See item rules in `item_01`.

## Acceptance checklist

- [ ] 2 PNGs (64×16 and 32×32)
- [ ] The brightest item on the ground; unmistakable
