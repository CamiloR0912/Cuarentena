# vfx_10 — Fog layer

| Field | Value |
|---|---|
| Priority | **P2** |
| Used in | Levels 1 and 3 (Tunja's morning fog; atmosphere pillar of the art style) |
| Output folder | `juego/assets/vfx/` |
| Type | Overlay |

## Files

| File | Size | Description |
|---|---|---|
| `fog_layer_a.png` | **480×270** | **Seamless in both directions** (tiles horizontally and vertically). Soft cloud shapes in `N6` and `N7`, alpha 10–35%, **posterized in 3 alpha steps** with dither between them. Large shapes (60–150 px) |
| `fog_layer_b.png` | 480×270 | Same rules, different shapes, smaller (30–80 px). Code scrolls A and B at different speeds (parallax) — e.g. 4 px/s and 9 px/s |

Code draws them over the world but **under** the HUD and under characters' status markers.

## Acceptance checklist

- [ ] 2 PNGs
- [ ] No visible seam when tiled 3×3
- [ ] Characters remain readable under both layers combined
