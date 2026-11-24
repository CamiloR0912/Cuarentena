# ui_08 — Weapon panel

| Field | Value |
|---|---|
| Priority | **P1** |
| Position | (760, 480), 192×56 (see `ui_00`) |
| Output folder | `juego/assets/ui/hud/` |

## Layout

```
┌────────────────────────────────────┐
│ ┌──────────┐  TUBO                 │  name: font, N8
│ │  48×24   │  ∞ / Dardos: 6 / 7/10 │  ammo: N7 (R1 when 0)
│ └──────────┘  ● ○ ○ ○   [Q]        │  4 slot dots + key hint
└────────────────────────────────────┘
```

- Background: `panel_dark` (`ui_01`).
- Weapon icon frame at (8, 8) inside the panel: 52×28 with the weapon HUD icon (`weapon_0X_*_hud.png`) centered.
- Dots: one per weapon slot 1–4. Owned & equipped `C1` filled, owned `N7` outline, not owned `N3`.
- When the weapon is on cooldown, code draws a darkening sweep over the icon frame (`N0` 50%).

## Files

| File | Size | Frames | Description |
|---|---|---|---|
| `weapon_icon_frame.png` | 52×28 | 2 (normal, cooldown flash) | Inner frame `N0` + `C0` border |
| `weapon_slot_dots.png` | 8×8 | 3 (equipped, owned, not owned) → 24×8 | Round dot |
| `ammo_empty_flash.png` | 52×28 | 2 | Red outline blink when trying to fire with 0 ammo |

## Acceptance checklist

- [ ] 3 PNGs
- [ ] Switching weapon is obvious at a glance
