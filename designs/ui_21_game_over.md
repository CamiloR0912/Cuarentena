# ui_21 — Game over screen

| Field | Value |
|---|---|
| Priority | **P1** |
| Canvas | 960×540 |
| Output folder | `juego/assets/ui/gameover/` |

## Composition

- The last game frame, desaturated by code and dimmed `N0` 70%.
- `panel_danger` (`ui_01`) 640×420 centered.
- **Cause icon** 64×64 at top center + cause title (large font, `R1`) + one line of explanation (`N7`):

| Cause | Title (in game) | Icon |
|---|---|---|
| HP = 0 | "Elena ha caído" | Flatline monitor: ECG line going flat, `R1` |
| Viral load = 100% | "La Fiebre Gris te alcanzó" | Virus covering a heart, `G3` |
| I/N > 0.60 | "La ciudad colapsó" | City skyline with a red overlay, `R1`/`N4` |
| Queue > 20 for 60 s | "El hospital colapsó" | Hospital building with a long line of people, `A1` |

- **Stats block** (left half): rows with a 16×16 icon + label + value: Sedados, Rescatados, Muestras, Tiempo, Pacientes atendidos, Abandonos.
- **SIR chart area** (right half): 280×140, code-drawn S/I/R curves (colors as in `ui_04`) with the 60% line.
- Buttons: "Reintentar nivel" and "Menú principal".

## Files

| File | Size | Frames | FPS | Description |
|---|---|---|---|---|
| `cause_hp.png` | 64×64 | 4 | 6 | ECG line goes flat (plays once, holds last frame) |
| `cause_viral.png` | 64×64 | 4 | 6 | Virus pulses over the heart |
| `cause_city.png` | 64×64 | 2 | 2 | Skyline, red light blinking |
| `cause_hospital.png` | 64×64 | 2 | 2 | Line of people, warning light |
| `stat_icons.png` | 6 × 16×16 = 96×16 | 1 | — | Sedated (z), rescued (person + check), sample (tube), time (clock), treated (bed), abandoned (person + red arrow) |
| `chart_bg.png` | 280×140 | 1 | — | Chart background with axes and grid (`N2`, `N4` grid, `N6` axes), labels added by code |

## Acceptance checklist

- [ ] 6 PNGs
- [ ] Each cause is understandable from its icon alone
