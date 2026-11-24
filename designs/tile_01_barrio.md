# tile_01 — Tileset: El Barrio (residential streets)

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | Level 1 (tutorial), parts of Level 3 |
| Output | `juego/assets/tilesets/barrio.png` + `barrio.tsx` (Tiled tileset) |
| Tile size | 32×32 px, no spacing, no margin |
| Sheet width | **8 tiles (256 px)**; height grows by rows as needed |
| Editor | Tiled map editor (free). Maps saved as `.tmx` with layers: `ground`, `decals`, `walls`, `overhead`, `collision` (object layer) |

## Mood

Quiet residential neighborhood of Tunja at dawn, in fog: **colonial-style houses** (white stucco walls, clay-tile roofs, wooden doors and balconies) mixed with modern brick buildings. Everything muted, cold, abandoned.

## Tile list

### A. Ground (layer `ground`)

| # | Tile | Variants | Colors |
|---|---|---|---|
| A1 | Asphalt base | 4 (plain, crack, oil stain, patched) | `N2`, `N3`, `N1` |
| A2 | Manhole cover | 1 | `N4`, `N1` |
| A3 | Storm drain (edge of road) | 2 (H, V) | `N1`, `N4` |
| A4 | Center line dashed | 2 (H, V) | `N7` faded |
| A5 | Crosswalk (zebra) | 2 (H, V) | `N7`/`N2` |
| A6 | Sidewalk slabs | 4 | `N5`, `N4` joints |
| A7 | Road ↔ sidewalk curb | **Autotile 13**: 4 edges, 4 outer corners, 4 inner corners, 1 full | `N4`, `N5` |
| A8 | Grass (small park, front yards) | 3 | `G1`, `G2` (desaturated, not acid) |
| A9 | Grass ↔ sidewalk edge | Autotile 13 | |
| A10 | Dirt / mud patch | 2 | `W0`, `W1` |

### B. Buildings (layers `walls` and `overhead`)

3/4 view: a building occupies its roof area (top) + **front wall 2 tiles tall** at the bottom edge.

| # | Tile | Variants |
|---|---|---|
| B1 | Clay-tile roof (terracotta, muted) | Autotile 9 (3×3 block: corners, edges, center) — `R0`, `S1`, `W1` |
| B2 | Flat concrete roof (modern buildings) | Autotile 9 — `N4`, `N5`, water tank prop on top optional |
| B3 | Roof edge/eave over the front wall | 3 (left, middle, right) |
| B4 | White stucco wall (colonial) | 2-tile tall pieces: plain, window dark, window lit (amber `A1`), window boarded (`W1` planks), wooden door, garage door |
| B5 | Red brick wall (modern) | Same 6 pieces as B4 — `R0`, `S1` |
| B6 | Wooden balcony (green-painted wood is typical in Tunja; use `G1`/`W1`) | 2 (left, right end) + 1 middle |
| B7 | Wall bottom shadow strip (on sidewalk) | 1 horizontal (overlay `N0` 30%) |

### C. Decals (layer `decals`, transparent background)

| # | Tile | Variants |
|---|---|---|
| C1 | Scattered paper / flyers ("CUARENTENA" flyer, 1 px text implied) | 3 |
| C2 | Broken glass | 2 |
| C3 | Puddle (reflective, `B1`/`B2`) | 2 |
| C4 | Spray-painted quarantine "X" on a door (amber) | 1 |
| C5 | Spray "AYUDA" on the ground (amber, large, 2×1 tiles) | 1 |
| C6 | Leaves / trash | 2 |

### D. Collision

No visual tiles. Collision is drawn as rectangles in the `collision` object layer.

## Acceptance checklist

- [ ] Every autotile set tiles seamlessly (test a 10×10 random patch in Tiled)
- [ ] Ground is darker and less saturated than characters (characters must pop)
- [ ] A 30×17 test map renders without obvious repetition
- [ ] `barrio.tsx` created in Tiled with the PNG
