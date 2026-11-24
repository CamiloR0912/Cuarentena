# ui_09 — Inventory bar (6 slots)

| Field | Value |
|---|---|
| Priority | **P1** |
| Position | (350, 484): 6 slots of 40×40, gap 4 px → 260×40 |
| Output folder | `juego/assets/ui/hud/` |

## Description

- Slots use `slot.png` (`ui_01`): empty / filled / selected.
- Each slot shows the item **icon 32×32** centered (`item_0X_*_icon.png`).
- **Stack count** at the bottom-right (font, `N8` with `N0` 1 px shadow), e.g. "×3" for viral samples.
- **Slot number** 1–6 at the top-left in `N6` (small).
- Selected consumable (used with F): `C1` border + small "F" key cap (`ui_12`) over the top-right corner.
- When full and the player tries to pick up: the whole bar flashes `R1` once.

## Files

| File | Size | Frames | Description |
|---|---|---|---|
| `inventory_full_flash.png` | 264×44 | 2 | Red outline around the whole bar |
| `slot_new_item.png` | 40×40 | 4 (12 fps) | White sparkle frame when an item lands in a slot |

(Slots themselves come from `ui_01`, icons from the item files.)

## Acceptance checklist

- [ ] 2 PNGs
- [ ] Mockup screenshot with 4 items filled is readable at 1×
