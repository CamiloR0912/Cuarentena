# ui_03 — Math glyphs (fallback sprite font for model symbols)

| Field | Value |
|---|---|
| Priority | **P2** (only if the chosen font lacks these glyphs) |
| Used in | Top bar (ℛ₀, I/N), F1 simulation panel, hospital panel (W_q, ρ, c), radio briefing (p̂, IC) |
| Output | `juego/assets/fonts/math_glyphs.png` |
| Cell | **8×12 px** per glyph, single row, transparent background |
| Color | Drawn in `N8` (code recolors with a color-key blend if needed) |

## Glyph order (left → right, the code indexes by this order)

| # | Glyph | Name | Used for |
|---|---|---|---|
| 0 | ℛ | Script R | ℛ₀ basic reproductive number |
| 1 | λ | lambda | Arrival rate |
| 2 | μ | mu | Service rate |
| 3 | ρ | rho | Utilization |
| 4 | β | beta | Contagion rate |
| 5 | γ | gamma | Recovery rate |
| 6 | φ | phi | Boids order parameter |
| 7 | p̂ | p-hat | Monte Carlo estimate |
| 8 | σ | sigma | Standard deviation |
| 9 | χ | chi | χ² test |
| 10 | ₀ | subscript 0 | |
| 11 | ₁ | subscript 1 | |
| 12 | q (subscript) | subscript q | W_q, L_q |
| 13 | ² | superscript 2 | χ², R² |
| 14 | ± | plus-minus | Confidence interval |
| 15 | √ | root | |
| 16 | ≈ | approx | Theory comparison |
| 17 | ∞ | infinity | Pipe has no ammo limit |
| 18 | ≥ | greater-equal | |
| 19 | → | arrow | Markov transitions |

Sheet size: 20 × 8 = **160×12**. Subscripts sit on rows 8–11; superscripts on rows 0–4. Baseline at row 9.

## Acceptance checklist

- [ ] 1 PNG
- [ ] Glyphs match the chosen font's stroke width (1 px) and x-height
