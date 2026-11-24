# tile_02 — Tileset: Hospital San Rafael

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | Level 2 (day = management, night = defense) |
| Output | `juego/assets/tilesets/hospital.png` + `hospital.tsx` |
| Tile size | 32×32, sheet width 8 tiles (256 px) |

## Mood

Overcrowded but clean emergency wing. Day: cold white/blue fluorescent light. Night: the same tiles under the night overlay (`vfx_06`) with amber emergency lights. **No separate night tileset** — night is done with lighting.

## Map zones the tiles must support

1. **Exterior**: ambulance bay and entrance (where night waves attack and sedated patients are delivered).
2. **Triage hall**: waiting area (the visible queue), stretchers area (servers).
3. **Supply room**, small.

## Tile list

### A. Exterior

| # | Tile | Variants |
|---|---|---|
| A1 | Parking asphalt | reuse barrio A1 |
| A2 | Ambulance bay floor with painted yellow hatch lines (`A1` faded) | Autotile 9 |
| A3 | "AMBULANCIAS" painted text on the floor | 3×1 tiles |
| A4 | Hospital façade wall (white panels `N8`/`N7`, blue stripe `C1`) | 2-tile tall: plain, window, **automatic glass door (2 tiles wide)**, sign "URGENCIAS" (red cross + text, 3 tiles wide) |
| A5 | Barricade spots at the entrance | see `prop_10` (prop, not tile) |

### B. Interior floors

| # | Tile | Variants |
|---|---|---|
| B1 | Linoleum floor (light grey-blue squares `N7`/`B2`) | 4 |
| B2 | Floor guide lines (colored strips, 4 px wide): red, amber, green, blue | straight H/V + corners for each color = 4 colors × 6 pieces |
| B3 | Triage zone floor markings: big colored area tiles (red / amber / green triage levels) | Autotile 9 for each of 3 colors (overlay at 25% on linoleum) |
| B4 | Waiting-area floor (darker carpet tile `B1`) | 2 |
| B5 | Floor dirt / footprints decal | 2 |

### C. Interior walls

| # | Tile | Variants |
|---|---|---|
| C1 | Wall top (seen from above, thickness 8 px) | Autotile 13 |
| C2 | Wall front face (2 tiles tall): plain `N7`, with handrail `N5`, with window to outside, with poster "LÁVESE LAS MANOS", with clock | 5 |
| C3 | Door frames (doors are props, `prop_07`) | H and V |
| C4 | Hospital curtain partitions (`C2` fabric), between stretchers | straight H/V, end caps, 2 frames for slight sway |

## Acceptance checklist

- [ ] Day look: readable, bright, clinical
- [ ] Under a 70% `B0` night overlay the layout is still readable
- [ ] The queue area visually reads as a "line" (floor guide lines + waiting seats)
