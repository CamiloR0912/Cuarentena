# ui_15 — Simulation panel (F1 debug view)

| Field | Value |
|---|---|
| Priority | **P1** — the workshop gives 0.0 if the video doesn't clearly show the 5 models; this panel is the safety net |
| Toggle | F1 |
| Position | (0, 32), 320×444, over the left side of the playfield |
| Output folder | `juego/assets/ui/simpanel/` |

## Layout

`panel_dark` background at 90% alpha. Six collapsible sections, each with a header (icon 16×16 + model name) and up to 3 lines of live numbers + one code-drawn sparkline (140×24).

```
┌──────────────────────────────────────┐
│ PANEL DE SIMULACIÓN   seed 12345  F1 │
├──────────────────────────────────────┤
│ [👣] M1 Caminata aleatoria           │
│   activos 12   E[R²] 96,3 (teo 100)  │
│   sesgo b = 0,18   ~~~~sparkline~~~~ │
├──────────────────────────────────────┤
│ [🧍🧍🧍] M2 Cola M/M/c               │
│   λ 1,5  μ 1,0  c 2   ρ 0,75         │
│   W_q 1,31 (teo 1,29)  ~~~~~~~~~~~   │
├──────────────────────────────────────┤
│ [🎲] M3 Monte Carlo                   │
│   E[D] 11,04 (teo 11,0)  crít 10,2 % │
│   χ² drops 4,8 < 11,07 ✓             │
├──────────────────────────────────────┤
│ [➶➶] M4 Agentes                      │
│   φ 0,87   Corredores: P2 A1 C1 B0   │
│   pánico medio 0,32  ~~~~~~~~~~~~~   │
├──────────────────────────────────────┤
│ [📈] M5 SIR                           │
│   S 112k  I 41k  R 27k   ℛ₀ 2,4      │
│   β_ef 0,26  γ_ef 0,11   ~~~~~~~~~   │
├──────────────────────────────────────┤
│ [⇄] Markov  E→T 0,10  T→C 0,15       │
└──────────────────────────────────────┘
```

When F1 is on, the world also shows the debug overlays from `vfx_13` (hearing radius, vision cones, walk trails, boids links).

## Files

| File | Size | Description |
|---|---|---|
| `model_icons.png` | 7 × 16×16 = **112×16** | In order: M1 random walk (footprints with a zig-zag path, `G3`), M2 queue (3 people in a line + a bed, `C1`), M3 Monte Carlo (two dice, `N8`), M4 agents (3 dots with arrows, `A1`), M5 SIR (rising/falling curve, `G3`/`C1`), Markov (2 circles with arrows, `N7`), PRNG (seed/sprout or "0101", `N7`) |
| `check_ok.png` | 8×8 | `C1` check mark — result within theory |
| `check_fail.png` | 8×8 | `R1` cross — out of tolerance |
| `section_header.png` | 8×16 | 9-slice-able header strip (`B0` fill, `C0` bottom line) |
| `sparkline_bg.png` | 140×24 | Small graph background with 1 px grid every 8 px (`N2`/`N3`) |

## Acceptance checklist

- [ ] 5 PNGs
- [ ] Each model icon is understandable without its label
- [ ] Mockup with all 6 sections fits 444 px of height
