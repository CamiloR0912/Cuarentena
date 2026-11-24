# ui_10 — Floating damage numbers (bitmap digits)

| Field | Value |
|---|---|
| Priority | **P1** — they show each Monte Carlo damage sample D in the video |
| Used in | Above enemies when hit; above Elena when she takes damage or heals |
| Output folder | `juego/assets/ui/numbers/` |

## Description

Bitmap digits (not the font) so they pop over the world. Code shows them rising 16 px and fading in 0.6 s. Damage is shown **rounded to an integer**.

| File | Glyph cell | Glyphs (in this order) | Look |
|---|---|---|---|
| `digits_normal.png` | 6×8 | `0 1 2 3 4 5 6 7 8 9 + - %` (13) → 78×8 | `N8` fill, 1 px `N0` outline (outline included in the cell) |
| `digits_critical.png` | **8×11** | `0 1 2 3 4 5 6 7 8 9 !` (11) → 88×11 | `R1` fill, `R2` top-left highlight, `N0` outline. Code appends "!" and scales the number 1→1.5→1 (pop) |
| `digits_heal.png` | 6×8 | same 13 glyphs as normal | `C2` fill (healing "+25") |
| `digits_viral.png` | 6×8 | same 13 glyphs | `G3` fill (viral load "+5%") |

## Acceptance checklist

- [ ] 4 PNGs
- [ ] A critical "22!" is clearly bigger/redder than a normal "11"
- [ ] Readable over both asphalt and white hospital floor
