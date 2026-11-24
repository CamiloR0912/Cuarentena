# prop_07 — Doors

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | All levels (interact with E; level exits) |
| Output folder | `juego/assets/sprites/props/doors/` |
| Collision | Full size when closed; none when open |

Doors in walls facing the camera (front wall, `_h`) are **32×64** (1 tile wide, 2 tall). Doors in side walls (`_v`) are **16×64** (seen edge-on).

| File | Frames | Description |
|---|---|---|
| `door_wood_h.png` | 3: closed, half open, open | Colonial wooden door, `W1`/`W0`, iron handle |
| `door_wood_v.png` | 3 | |
| `door_hospital_h.png` | 3 | Swing door with round window, `N7`/`C1` kick plate |
| `door_hospital_v.png` | 3 | |
| `door_glass_auto.png` | 4 (64×64 per frame): closed → sliding open | Hospital entrance and lab airlock, 2 tiles wide, `B2` glass with `N8` reflections |
| `door_locked_overlay.png` | 1, 16×16 | Padlock icon in `R1`, drawn by code over locked doors |
| `exit_marker.png` | 2 frames, 32×16, 2 fps | Floor arrow in `C1` pointing to the level exit |

The open frame is used for both directions (no animation back needed; code plays frames in reverse to close).

## Acceptance checklist

- [ ] 7 PNGs
- [ ] Doors align with wall-front tiles of each tileset (bottom edge on the floor line)
