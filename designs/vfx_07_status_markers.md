# vfx_07 — Status markers above characters

| Field | Value |
|---|---|
| Priority | **P1** — they make the agent states (FSM, panic, sedation, Markov progression) visible in the video |
| Used in | Above enemies and citizens, 4 px above the head |
| Output folder | `juego/assets/vfx/markers/` |

## Files

| File | Size per frame | Frames | FPS | Meaning | Look |
|---|---|---|---|---|---|
| `marker_alert.png` | 8×12 | 2 | 8 | Corredor ALERT; citizen panic P ≥ 0.5 | Exclamation "!" in `A1` with `A2` highlight, `N0` outline; frame 2 = 1 px up (bounce) |
| `marker_chase.png` | 12×12 | 2 | 8 | Corredor CHASE | "!!" in `R1` |
| `marker_search.png` | 8×12 | 2 | 4 | Corredor SEARCH | "?" in `A1` |
| `marker_sleep.png` | 16×16 | 3 | 3 | Sedated (60 s countdown) | "z", "zZ", "zZz" in `C2` |
| `marker_follow.png` | 8×8 | 2 | 4 | Citizen following Elena | Small heart or blue chevron `C1` |
| `marker_carry_prompt.png` | 16×16 | 2 | 4 | Sedated body can be carried | Hand/arrow icon `N8` (paired with "E" key prompt, `ui_12`) |
| `mutation_pulse.png` | 32×32 | 4 | 10 | **Markov transition** (Errante → Tosedor → Corredor) | Green ring (`G3`) expanding around the body + a few rising particles. Plays once, then the sprite is swapped |
| `infection_flash.png` | 32×32 | 3 | 12 | Citizen gets infected on the street (ABM contagion) | Short acid-green burst |

The **sedation timer** (ring that empties in 60 s) is drawn by code as an arc (`C1`, 2 px) around `marker_sleep`.

## Acceptance checklist

- [ ] 8 PNGs
- [ ] Every marker readable over both dark and light floors (1 px outline)
