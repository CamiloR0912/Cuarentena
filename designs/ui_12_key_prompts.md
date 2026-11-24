# ui_12 — Key and mouse prompts

| Field | Value |
|---|---|
| Priority | **P1** (tutorial in Level 1 relies on them) |
| Used in | Interaction prompts in the world ("E Cargar"), tutorial hints, controls screen (`ui_18`), inventory "F" |
| Output | `juego/assets/ui/keys/` |

## Style

Keyboard key caps seen from the front: `N7` top face, `N5` bottom edge 2 px (depth), `N0` outline, letter in `N1`. **2 frames per key**: up and pressed (pressed = 1 px lower, no bottom edge) — tutorial animates them.

## Files (each file = 2 frames side by side)

| File | Size per frame | Label |
|---|---|---|
| `key_w.png`, `key_a.png`, `key_s.png`, `key_d.png` | 16×16 | W A S D |
| `key_arrows.png` | 16×16 × 4 directions (separate frames: up, down, left, right, each ×2) → 128×16 | ↑ ↓ ← → |
| `key_e.png` | 16×16 | E |
| `key_f.png` | 16×16 | F |
| `key_q.png` | 16×16 | Q |
| `key_1.png` … `key_4.png` | 16×16 | 1 2 3 4 |
| `key_plus.png`, `key_minus.png` | 16×16 | + − |
| `key_shift.png` | 32×16 | Shift (or "⇧") |
| `key_space.png` | 48×16 | Espacio |
| `key_esc.png` | 24×16 | Esc |
| `key_f1.png` | 24×16 | F1 |
| `mouse_left.png` | 12×16 | Mouse with left button highlighted `C1` |
| `mouse_wheel.png` | 12×16 | Mouse with wheel highlighted |
| `mouse_move.png` | 12×16 | Mouse with 4 small arrows (aim) |

In-world prompt: key cap + Spanish verb in the font, on a `tooltip` panel: "E Recoger", "E Cargar", "E Abrir", "E Hablar", "F Usar".

## Acceptance checklist

- [ ] All files with 2 frames
- [ ] Letters readable at 1×
