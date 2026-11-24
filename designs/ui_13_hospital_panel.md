# ui_13 — Hospital panel (M/M/c queue)

| Field | Value |
|---|---|
| Priority | **P1** — main view of the queue model in the video |
| Used in | Level 2 (day and night) |
| Simulation model | M/M/c queue (Model 2): λ, μ, c, ρ, L_q, W_q (measured vs theoretical), reneging after T_pac |
| Position | (760, 40), 192×428 |
| Output folder | `juego/assets/ui/hospital/` |

## Layout (inside the 192×428 panel, `panel_dark` background)

```
┌──────────────────────────┐
│ ☀ DÍA 2   Noche 1/3  ⏱   │ header 192×24 (sun/moon icon + phase + countdown)
├──────────────────────────┤
│ COLA (7)                 │ queue title + current length
│ [👤][████░░] 0:42        │ up to 10 rows, 16 px each:
│ [💤][██░░░░] 1:05        │   patient type icon 12×12 + patience bar 60×4
│ [👤][█░░░░░] 1:31  ⚠     │   + waiting time; ⚠ when near T_pac
│  ... +3 más              │
├──────────────────────────┤
│ CAMILLAS  c = 3          │
│ [▣][▣][▣][▢][▢][▢]       │ 6 stretcher icons 16×16 (open/busy/closed)
│  [−]          [+]        │ buttons 16×16 (keys − / +)
├──────────────────────────┤
│ 📦 Suministros  38       │ supply icon + count
│   −1,5 /min              │ consumption (N7, R1 when < 10 min left)
├──────────────────────────┤
│ λ = 1,5/min  μ = 1,0/min │
│ ρ = 0,75                 │ ρ ≥ 1 → R1 and warning icon
│ W_q medido   1,31 min    │
│ W_q teórico  1,29 min    │ (the comparison the workshop asks to show)
└──────────────────────────┘
```

## Files

| File | Size | Frames | Description |
|---|---|---|---|
| `icon_day.png` | 16×16 | 1 | Sun, `A2`/`A1` |
| `icon_night.png` | 16×16 | 1 | Moon, `C2`/`B2` |
| `icon_patient_citizen.png` | 12×12 | 1 | Head silhouette, skin tone `S2`, blue shirt — rescued citizen |
| `icon_patient_sedated.png` | 12×12 | 1 | Head, grey-green skin `I1`, closed eyes + tiny "z" — sedated infected |
| `icon_patient_leaving.png` | 12×12 | 2 (4 fps) | Patient walking away with `R1` arrow — reneging (abandons, +1 I) |
| `icon_stretcher_open.png` | 16×16 | 1 | Bed icon, `N8` sheet, `C1` frame — idle server |
| `icon_stretcher_busy.png` | 16×16 | 2 (2 fps) | Bed with patient, `A1` blinking dot — busy server |
| `icon_stretcher_closed.png` | 16×16 | 1 | Folded bed, `N4` — not a server |
| `button_minus.png` / `button_plus.png` | 16×16 | 3 (normal, hover, pressed) | Small square buttons, `C0`/`C1` |
| `patience_bar_fill.png` | 4×4 | 3 (blue `C1`, amber `A1`, red `R1`) | Fill slices; color by remaining patience (> 50%, 20–50%, < 20%) |
| `icon_warning.png` | 12×12 | 2 (4 fps) | Amber triangle "!" (near T_pac, ρ ≥ 1, low supplies) |
| `hospital_collapse_banner.png` | 192×32 | 2 (4 fps) | Red banner "COLAPSO INMINENTE" with countdown space — queue > 20 for more than 60 s |

## Acceptance checklist

- [ ] 13 PNGs
- [ ] Mockup at 1× with 10 queued patients and c = 3 fits in the panel
- [ ] Measured vs theoretical W_q lines are visually paired
