# portrait_04 — Radio static overlay

| Field | Value |
|---|---|
| Priority | **P2** |
| Category | Overlay (semi-transparency allowed) |
| Used in | Over Don Álvaro's portrait in the radio briefing |
| Output folder | `juego/assets/portraits/` |
| File | `radio_static.png` — 4 frames × 96×96 = **384×96** |
| FPS | 12, loop |

## Description

- Horizontal scanlines every 2 px (`N0` at 25% alpha) — static on every frame.
- 1–2 bright horizontal "interference" bands (`N7` at 40%, 2–4 px tall) at a different height in each frame.
- Random noise pixels (`N6`/`N8`, ~3% of the area, 50% alpha), different in each frame.
- Code plays it at full strength for 0.3 s when the transmission starts, then fades it to 30% alpha while he talks.

## Acceptance checklist

- [ ] Portrait under it remains readable at 30% overlay alpha
- [ ] 4 frames loop without a visible "jump"
