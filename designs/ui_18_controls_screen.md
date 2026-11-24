# ui_18 — Controls screen

| Field | Value |
|---|---|
| Priority | **P2** |
| Opened from | Main menu and pause menu |
| Canvas | 960×540 |
| New art needed | **None** — composed from existing assets |

## Composition

- Background: `menu_bg_sky.png` + `menu_bg_city.png` dimmed with `N0` at 60%.
- Central `panel_dark` 720×420, title "CONTROLES" (large font, `N8`).
- Two columns of rows, each row = key prompt sprite(s) from `ui_12` + Spanish action text:

| Keys | Action (in game) |
|---|---|
| W A S D / arrows | Moverse |
| Mouse move | Apuntar |
| Left click / Space | Atacar |
| Shift | Agacharse (sigilo) |
| E | Interactuar / cargar |
| Q / wheel / 1–4 | Cambiar arma |
| F | Usar consumible |
| + / − | Abrir / cerrar camilla (hospital) |
| F1 | Panel de simulación |
| Esc | Pausa |

- Button "Volver" at the bottom center.

## Acceptance checklist

- [ ] All key sprites from `ui_12` exist
- [ ] Rows match GDD §11
