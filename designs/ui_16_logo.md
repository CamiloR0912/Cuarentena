# ui_16 — Game logo "CUARENTENA"

| Field | Value |
|---|---|
| Priority | **P1** |
| Used in | Main menu, victory screen, video intro, report cover, app icon reference |
| Output folder | `juego/assets/ui/logo/` |

## Description

- Word **"CUARENTENA"** in custom pixel lettering (draw it, don't type it with a font): tall, condensed, slightly stencil-like letters (like quarantine signage), clinical white `N8` with `N7` lower half shading and a 1 px `N0` outline + 2 px `B0` drop shadow.
- A strip of **amber quarantine tape** (`A1`/`N0` diagonal stripes) crosses behind the word at a slight angle (−6°).
- The "T" (or the "A") incorporates a **medical cross** shape in `C1` — the cure motif.
- Subtitle below: **"LA FIEBRE GRIS"** in small caps, `N6`, letter-spaced.
- Optional subtle acid-green (`G3`) "infection" specks at the edges of 2–3 letters — tension, not horror. No drips, no blood.

## Files

| File | Size | Frames | FPS | Description |
|---|---|---|---|---|
| `logo.png` | **400×120** | 1 | — | Full logo with subtitle |
| `logo_anim.png` | 400×120 | 4 | 6 | Tape flutters 1 px; the medical cross glows (`C1` → `C2`) once per loop |
| `logo_small.png` | 200×60 | 1 | — | Hand-redrawn smaller version (not a downscale) for the pause menu and credits |

## Acceptance checklist

- [ ] Sketch at `designs/evidence/sketches/logo.jpg` (2–3 lettering ideas)
- [ ] 3 PNGs
- [ ] Readable on both dark and fog-grey backgrounds
