# ui_14 — Radio briefing screen (Monte Carlo estimate)

| Field | Value |
|---|---|
| Priority | **P1** — main view of the Monte Carlo mission model |
| Used in | Before each sortie (Levels 1, 3, 4) and level intros |
| Simulation model | Monte Carlo (Model 3): p̂ = probability of coming back, 95% CI, N replicas |
| Output folder | `juego/assets/ui/radio/` |

## Layout (960×540; the paused world dimmed to 30% behind)

```
           x=120                                                   x=840
y=110  ┌────────────────────────────────────────────────────────────────┐
       │ ◉ RADIO — DON ÁLVARO                         ▂▃▅▇ señal        │ header (panel_radio)
       ├────────────┬───────────────────────────────────────────────────┤
       │ ┌────────┐ │ "Doctora, en la farmacia del centro hay           │
       │ │portrait│ │  antibióticos, pero la zona está caliente."        │ typewriter text
       │ │ 96×96  │ │                                                   │
       │ └────────┘ │ MISIÓN: Farmacia del centro                       │
       │            │ Botín: [icon][icon][icon]   Amenaza: ☣☣☣○○        │
       ├────────────┴───────────────────────────────────────────────────┤
       │  PROBABILIDAD DE REGRESAR                                      │
       │      58 %              0%|─────────[■■■|■■■]─────────|100%    │ big number + CI bar
       │  IC 95 %: 55 % – 61 %      N = 5 000 simulaciones             │
       ├────────────────────────────────────────────────────────────────┤
       │                  [ ACEPTAR ]        [ RECHAZAR ]               │ buttons (ui_01)
y=430  └────────────────────────────────────────────────────────────────┘
```

- Big percentage color: `R1` if p̂ < 40%, `A1` 40–70%, `C1` ≥ 70%. Use the large font ×2 or `digits_big.png` below.
- CI bar: track 240×12; code draws the point estimate and the interval whisker.
- While the simulation runs (N replicas), the number "rolls" and a small progress spinner shows (this makes the computation visible in the video).

## Files

| File | Size | Frames | Description |
|---|---|---|---|
| `radio_signal_icon.png` | 24×12 | 4 (6 fps) | Signal-strength bars animating |
| `radio_led.png` | 8×8 | 2 (2 fps) | Red/amber "on air" LED (`R1` / `R0`) |
| `digits_big.png` | **16×24** per glyph, `0-9 %` (11) → 176×24 | 1 | Big bitmap digits for p̂, `N8` with `N0` outline (code tints) |
| `ci_bar_track.png` | 240×12 | 1 | Track with 0/25/50/75/100 ticks, `N3` fill, `N5` ticks |
| `ci_whisker.png` | 8×12 | 1 | End cap of the CI interval, `N8` |
| `ci_point.png` | 6×12 | 1 | Point-estimate marker, `N8` with `A1` center |
| `threat_icon.png` | 12×12 | 2 (on, off) | Biohazard icon for threat level 1–5 |
| `sim_spinner.png` | 16×16 | 8 (12 fps) | Rotating dice / dots while the Monte Carlo runs |

Portraits come from `portrait_01`–`03`; static overlay from `portrait_04`; panels and buttons from `ui_01`.

## Acceptance checklist

- [ ] 8 PNGs
- [ ] p̂ and the CI are the most prominent elements of the screen
- [ ] Mockup with long text (3 lines) fits
