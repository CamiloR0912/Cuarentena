# vfx_01 — Contagion cloud (Tosedor / boss cough)

| Field | Value |
|---|---|
| Priority | **P1** — the visible face of the diffusion model |
| Used in | Every Tosedor cough, boss Cough phase |
| Simulation model | Each particle does its own random walk (diffusion, Model 1); concentration fades over time |
| Output folder | `juego/assets/vfx/` |
| Type | **Overlay** (alpha allowed) |

## How it works in code

A cloud = 20–40 independent particles. Each particle is one small puff sprite that random-walks and fades out. The artist only draws **puffs**; the cloud shape emerges from the simulation (nice for the video: you literally see the diffusion).

## Files

| File | Size per frame | Frames | Description |
|---|---|---|---|
| `contagion_puff.png` | 16×16 | **4 variants** (not an animation; code picks one at random per particle) | Soft round blobs, irregular edge, 3 tones: `G2` body, `G3` top-left highlight, `G0` bottom-right. Base alpha 60%; code multiplies by the particle's concentration (fade) |
| `contagion_puff_small.png` | 8×8 | 2 variants | For the tail/edges of the cloud |

Boss clouds use the same puffs, drawn ×2 (integer scale, stays pixel-perfect).

## Acceptance checklist

- [ ] 2 PNGs (64×16 and 16×8)
- [ ] 30 overlapping puffs at 60% alpha look like a toxic cloud, not like solid green balls
- [ ] Clearly different from fog (`vfx_10`, grey) and extinguisher spray (`vfx_04`, white)
