# prop_09 — Laboratory furniture and cure synthesizer

| Field | Value |
|---|---|
| Priority | **P2** |
| Used in | Level 4 (lab, delivery point for the 10 viral samples) and victory scene |
| Output folder | `juego/assets/sprites/props/lab/` |

| File | Size | Collision | Frames | Description |
|---|---|---|---|---|
| `lab_bench.png` | 64×48 | 64×24 | 1 | White bench `N8`/`N7`, beakers, microscope |
| `lab_bench_messy.png` | 64×48 | 64×24 | 1 | Same, papers and knocked-over beakers (for corridors/evacuated rooms) |
| `fume_hood.png` | 64×64 | 64×24 | 1 | Glass hood, `B2` glass, orange warning label |
| `centrifuge.png` | 32×32 | 24×16 | 2 (6 fps) | Spinning indicator light |
| `sample_fridge.png` | 32×64 | 32×20 | 2 (2 fps) | Tall fridge with glass door, acid-green vials inside (`G3`), blinking temp display |
| `cure_synthesizer.png` | **96×96** | 80×40 | **11 frames** | The key machine. A tall device with a central glass column. **Frame k = k samples delivered (0–10)**: the column fills with acid-green liquid (`G3`) step by step; frame 10 turns the liquid **clinical white/blue** (`N8`/`C2`) = cure ready. Code shows frame = samples delivered |
| `cure_synthesizer_glow.png` | 96×96 | — | 4 (8 fps) | Overlay glow (alpha allowed) played when the cure is complete |
| `whiteboard.png` | 64×48 | none | 1 | Wall decal with a hand-drawn SIR curve and "R₀" scribbles |

## Acceptance checklist

- [ ] 8 PNGs
- [ ] Synthesizer progress is readable at 1× (each sample = visible step, ~5 px of liquid)
