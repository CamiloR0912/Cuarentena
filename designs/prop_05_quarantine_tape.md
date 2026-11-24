# prop_05 — Quarantine tape

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | All levels — the visual signature of the game |
| Output folder | `juego/assets/sprites/props/tape/` |
| Collision | **None** (decorative). Optionally used as "soft" level border with an invisible wall |

## Description

Amber-and-black diagonal striped plastic tape (`A1` / `N0`), stretched between posts, with the word "CUARENTENA" implied by small dark marks every ~24 px. Slightly sagging. Fluttering in the wind.

| File | Size per frame | Frames | FPS | Notes |
|---|---|---|---|---|
| `tape_h.png` | 32×16 | 2 | 3 | Tileable horizontal segment; frame 2 = tape shifted 1 px (flutter) |
| `tape_v.png` | 16×32 | 2 | 3 | Tileable vertical segment |
| `tape_post.png` | 8×24 | 1 | — | Post/pole the tape is tied to |
| `tape_broken_end.png` | 32×16 | 2 | 3 | Torn end hanging loose (for gaps the player passes through) |
| `tape_on_door.png` | 32×64 | 1 | — | Two crossed tapes over a door (decal over wall front) |

## Acceptance checklist

- [ ] 5 PNGs
- [ ] Tileable segments show no seam when repeated 10×
