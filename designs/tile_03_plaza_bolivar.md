# tile_03 — Tileset: El Centro (Plaza de Bolívar, Tunja)

| Field | Value |
|---|---|
| Priority | **P2** |
| Used in | Level 3 |
| Output | `juego/assets/tilesets/centro.png` + `centro.tsx` |
| Tile size | 32×32, sheet width 8 tiles (256 px) |

## Mood

The historic center of Tunja, heavily infected: big open stone plaza (good for watching **Masa swarms** move as a flock), colonial arcades around it, the cathedral façade on one side, a military/health checkpoint abandoned in the middle. Use **real photos of Tunja's Plaza de Bolívar** as reference (save them in `designs/evidence/references/`).

## Tile list

### A. Ground

| # | Tile | Variants |
|---|---|---|
| A1 | Large stone paving slabs (plaza) `N5`/`N4`/`N6` | 4 |
| A2 | Cobblestone street | 3 |
| A3 | Slabs ↔ cobblestone border | Autotile 13 |
| A4 | Decorative stone pattern lines (plaza geometry) | straight H/V + 4 corners |
| A5 | Steps (cathedral atrium), 3 steps | 3-tile wide piece × 1 tall, + left/right ends |
| A6 | Decals: paper, flyers, abandoned masks, pigeons feathers | 4 |

### B. Colonial architecture

| # | Tile | Variants |
|---|---|---|
| B1 | Clay-tile roof | reuse barrio B1 |
| B2 | Colonial white wall, 2 tiles tall | plain, window with iron bars, wooden door (big), wooden door (closed shop) |
| B3 | **Arcade (soportales)**: arches on columns, walkable underneath | arch left / middle / right (2 tiles tall) + arcade floor tile |
| B4 | Wooden balcony (2nd floor) | reuse barrio B6 |

### C. Set pieces (multi-tile, still part of the tileset)

| # | Piece | Size in tiles | Notes |
|---|---|---|---|
| C1 | Cathedral façade | **6 wide × 5 tall** (192×160 px) | Stone `N5`/`N6`, two-level façade, big wooden door, bell tower stub on one side. Split into 30 tiles in the sheet |
| C2 | Central monument on pedestal | 2×3 (64×96) | Statue silhouette on a stone pedestal, fog-grey `N6`. Collision on the pedestal only |
| C3 | Stone bench | 2×1 | |
| C4 | Old street lamp (colonial style) | 1×2 | Has a lit variant (amber `A2` bulb) |

## Acceptance checklist

- [ ] Open plaza area at least 20×12 tiles looks good without repetition
- [ ] Arcades clearly walkable (floor visible under the arches)
- [ ] Reference photos saved for the style document
