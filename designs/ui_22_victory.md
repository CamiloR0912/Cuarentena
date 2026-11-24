# ui_22 — Victory screen (the cure)

| Field | Value |
|---|---|
| Priority | **P2** |
| Canvas | 960×540 |
| Output folder | `juego/assets/ui/victory/` |

## Sequence

1. **Cure illustration** (4–6 s): full-screen pixel art scene.
2. Then the results panel slides in on the right, over the illustration.

## Cure illustration

- Inside Dra. Mena's lab at dawn: the **cure synthesizer** (same design as `prop_09`) in the center glowing **white and clinical blue**; Elena (right) and Dra. Mena (left), in profile, looking at it. Elena's coat is dirty, she is exhausted but smiling.
- A large window behind shows **Tunja at sunrise**: the fog lifting, amber/white light (`A2`, `N8`) on the cathedral towers.
- Palette shifts from cold to warm: this is the only scene where warm light dominates.
- Faces simple (it is still pixel art at 1×), poses tell the story.

## Results panel

- `panel_dark` 360×460 at x = 580.
- Title "¡CURA SINTETIZADA!" (large font, `C1`).
- SIR final chart 320×140 (code), showing I going down at the end; the bar `ui_04` animated back to mostly R (white).
- Score lines with `stat_icons.png` (`ui_21`) + total score.
- Buttons "Créditos" and "Menú principal".

## Files

| File | Size | Frames | FPS | Description |
|---|---|---|---|---|
| `victory_scene.png` | 960×540 | 2 | 2 | Illustration; frame 2 changes only the synthesizer glow and a few light pixels |
| `victory_glow_overlay.png` | 960×540 | 1 | — | Soft white/blue light overlay (alpha) the code fades in at the start |

## Acceptance checklist

- [ ] Sketch at `designs/evidence/sketches/victory.jpg`
- [ ] 2 PNGs
- [ ] The scene reads as "hope" in contrast with the rest of the game
