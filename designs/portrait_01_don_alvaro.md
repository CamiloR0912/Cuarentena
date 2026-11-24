# portrait_01 — Don Álvaro (radio guide)

| Field | Value |
|---|---|
| Priority | **P1** |
| Category | Dialogue portrait |
| Used in | Radio briefing before every mission (`ui_14`), Level 3 especially |
| Simulation model | He "announces" the Monte Carlo estimate p̂ and its 95% CI |
| Output folder | `juego/assets/portraits/` |
| Canvas | **96×96 px** per frame |
| Framing | Bust (head + shoulders), facing ¾ to the right (the dialogue box shows him on the left) |

## Visual description

- Retired radio amateur, ~65 years old, lives in a building near the hospital. He's the voice of reason and statistics: calm, a bit grumpy, kind.
- Grey moustache and short grey hair (`N6`/`N7`), glasses with thick frames (`W0`), skin `S1`/`S2`.
- Wears a **headset with microphone** (`N2`/`N4`) and a brown wool sweater (`W1`/`W2`).
- Background (inside the 96×96): his radio room, dark (`B0`/`N1`), with a green VU meter light (`G3`, 2×2 px) and amber dial lights (`A1`) — the background must stay dark so the portrait frame and text stay readable.

## Expressions (one frame each)

| File | Frames | Use |
|---|---|---|
| `alvaro_neutral.png` | 2 (mouth closed / open, 8 fps while text types) | Default |
| `alvaro_worried.png` | 2 | p̂ < 0.40 ("la zona está muy caliente") |
| `alvaro_confident.png` | 2 | p̂ ≥ 0.70 |

Each file: 192×96 (2 frames). The radio static overlay is shared (`portrait_04`).

## Acceptance checklist

- [ ] Sketch at `designs/evidence/sketches/don_alvaro.jpg`
- [ ] 3 PNGs
- [ ] Recognizable as "the radio guy" (headset) at 1×
