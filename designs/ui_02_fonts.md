# ui_02 — Fonts

| Field | Value |
|---|---|
| Priority | **P1** |
| Output folder | `juego/assets/fonts/` |
| Type | **Sourced** (a free pixel font), not drawn — but must be recorded in the attribution table |

## Requirements

| Need | Value |
|---|---|
| Style | Pixel font, monospaced or proportional, clean, readable |
| Native size | Small font with cap height ~7 px (body/HUD) + one larger (title) |
| Glyph coverage | Full Spanish: `á é í ó ú Á É Í Ó Ú ñ Ñ ü ¿ ¡`, plus `° % ± × · –` |
| License | Free for commercial and non-commercial use (CC0, OFL or CC-BY). Save the license file next to the font |
| Rendering | In Godot: import the font with Antialiasing = None, Hinting = None, Subpixel positioning = Disabled; use it only at the native size or integer multiples |

## Candidates (verify license and glyphs before choosing)

| Font | Use | Notes |
|---|---|---|
| **Pixel Operator** (Jayvee Enaguas) | Body/HUD (8 px) and titles (16 px) | Reported as CC0; check Spanish glyphs |
| **m5x7 / m6x11** (Daniel Linssen) | Body/HUD | Very readable; check license text and accents |
| **Silver** (Poppy Works) | Fallback for Greek letters (λ μ ρ β γ φ) | Very wide Unicode coverage; CC-BY 4.0 |

Test string (render it in the chosen font before deciding):
`¿Aceptas la misión? Año 2031 — Ñandú, 58 % ± 3,2 · λ μ ρ β γ φ ℛ₀`

## Sizes used in the game

| Role | Size | Color |
|---|---|---|
| HUD labels, numbers | native (≈8 px) | `N8`, secondary `N7` |
| Panel titles | native ×2 or the large variant | `N8` / `C1` |
| Screen titles (Game over, Pausa) | large ×2 | `N8`, `R1` for game over |
| Damage numbers | bitmap digits (`ui_10`), not the font | |

## Acceptance checklist

- [ ] Font file(s) in `juego/assets/fonts/` with the license file
- [ ] Row added to the attribution table
- [ ] If Greek/math glyphs are missing → draw `ui_03`
