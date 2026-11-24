# ui_04 — City pulse bar (SIR model)

| Field | Value |
|---|---|
| Priority | **P1** — the most important simulation UI; it must be clear in the video |
| Simulation model | System dynamics SIR (Model 5): S, I, R stocks of 180,000 inhabitants |
| Position | (8, 17), 760×10 on the top bar (see `ui_00`) |
| Output folder | `juego/assets/ui/hud/` |

## How it works

A horizontal stacked bar, segments proportional to I/N, S/N, R/N. **Order left → right: Infected | Susceptible | Recovered** — infected first so the **collapse threshold (I/N = 60%)** is a fixed marker on the bar. (Design decision: the GDD lists S, I, R; this order is chosen for readability of the threshold.)

Code draws the segments as filled rectangles; the artist provides the frame, textures and markers.

| Segment | Fill | Texture |
|---|---|---|
| Infected I | `G2`, top row `G3` | Diagonal 1 px stripes of `G1` moving slowly (texture scroll) |
| Susceptible S | `B1`, top row `B2` | Plain |
| Recovered R | `N8`/`C2`, top row `N8` | Plain |

## Files

| File | Size | Frames | Description |
|---|---|---|---|
| `sir_bar_frame.png` | 764×14 | 1 | Frame with 2 px border around the 760×10 area (`N0` outer, `N4` inner), tick marks every 10% (1 px `N5`, 3 px tall below the bar) |
| `sir_infected_texture.png` | 8×10 | 1 | Tileable stripe pattern for the I segment |
| `sir_threshold_marker.png` | 7×18 | 2 (2 fps) | Red triangle + 1 px vertical line (`R1`) at x = 60%. Frame 2 brighter (`R2`). Blinks when I/N > 45% |
| `sir_legend_icons.png` | 3 × 8×8 = 24×8 | 1 | Small square icons for the legend / F1 panel: virus (I, `G3`), person (S, `B2`), heart-cross (R, `N8`) |
| `sir_danger_glow.png` | 764×14 | 2 (4 fps) | Red outline glow (overlay) when I/N > 50% |

## Acceptance checklist

- [ ] 5 PNGs
- [ ] At 1× the three segments and the 60% marker are clear
- [ ] Works when a segment is 0 px wide (no broken borders)
