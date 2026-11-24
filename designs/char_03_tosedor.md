# char_03 — Tosedor (Cougher, infected)

| Field | Value |
|---|---|
| Priority | **P1** |
| Category | Enemy (non-attacking hazard) |
| Used in | Levels 1–4 |
| Simulation model | Random walk (Model 1) + diffusion of contagion particles; Markov stage 2 |
| Output folder | `juego/assets/sprites/enemies/tosedor/` |
| Cell size | 32×32 px |
| Visible body | ~16×26 px (more bent over than the Errante) |
| Pivot (feet) | (16, 30) |
| Collision box | 12×8 px |
| Facings | down, up, right |

## Visual description

- More advanced stage of the fever: **bent forward, one hand over the mouth or chest**, constantly coughing.
- Skin `I1`/`I0`, with acid-green tint around the mouth (`G3`, 1–2 px) to read as "contagious source".
- Wears a **dirty, torn surgical mask hanging from one ear** (`N7` with `G2` stains) — visual irony and a hint for the player to use masks.
- Clothes: long coat or **ruana** (traditional Boyacá wool poncho) in `N5`/`N4` with `G1` shadow. The ruana gives a wide, recognizable silhouette and a local touch.
- Tiny green particles (1 px `G3`) drawn around the head in the cough frames only.

## Animations

| File | Frames | FPS | Loop | Rows | Notes |
|---|---|---|---|---|---|
| `tosedor_idle.png` | 2 | 3 | yes | 3 | Heavy breathing |
| `tosedor_walk.png` | 4 | 5 | yes | 3 | Slow (1.0 px/frame), bent |
| `tosedor_cough.png` | 4 | 8 | no | 3 | 0 inhale (straightens), 1 bend, **2 cough (emission frame)**, 3 recover. Code spawns the contagion cloud (`vfx_01`) at frame 2 |
| `tosedor_hurt.png` | 2 | 10 | no | 3 | |
| `tosedor_sedated.png` | 2 | 2 | yes | 1 | Lying on the side, coughing stops |
| `tosedor_wake_up.png` | 3 | 6 | no | 1 | |

### Cough emission point (relative to cell top-left)

| Facing | Point |
|---|---|
| down | (16, 14) |
| up | (16, 10) |
| right | (22, 13) |

### Sheet sizes

| File | Size |
|---|---|
| idle, hurt | 64×96 |
| walk, cough | 128×96 |
| sedated | 64×32 |
| wake_up | 96×32 |

## Acceptance checklist

- [ ] Sketch at `designs/evidence/sketches/tosedor.jpg`
- [ ] 6 PNGs
- [ ] Silhouette distinguishable from the Errante at a glance (bent + ruana)
- [ ] Mouth/emission point matches the table
