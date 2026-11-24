# ui_20 — Pause menu

| Field | Value |
|---|---|
| Priority | **P1** |
| Opened with | Esc |
| Canvas | 960×540 |
| New art needed | 1 small file |

## Composition

- The frozen game frame behind, dimmed with `N0` at 60% (code).
- Centered `panel_dark` 280×240.
- `logo_small.png` is **not** used here; title "PAUSA" (large font, `N8`).
- Buttons (`ui_01`, 200×28, 36 px apart): "Continuar", "Reiniciar nivel", "Controles", "Menú principal" (danger style).
- A small line under the title with the simulation state, proving the simulation is frozen (GDD test case 8): e.g. "Simulación en pausa · t = 12:34".

## Files

| File | Size | Frames | FPS | Description |
|---|---|---|---|---|
| `pause_icon.png` | 24×24 | 2 | 2 | Pause symbol "‖" in `N8`, blinking next to the title |

## Acceptance checklist

- [ ] 1 PNG
