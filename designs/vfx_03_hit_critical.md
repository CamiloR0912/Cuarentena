# vfx_03 — Critical hit impact

| Field | Value |
|---|---|
| Priority | **P1** — must be very visible: it shows the Bernoulli(p_crit) outcome |
| Used in | Every critical hit (k = 2), especially stealth back-attacks |
| Output folder | `juego/assets/vfx/` |

## File

| File | Size per frame | Frames | FPS | Loop |
|---|---|---|---|---|
| `hit_critical.png` | **48×48** | 5 | 20 | no |

## Description

- Frame 0: bright white flash (`N8`) 16 px with a **red** core cross (`R1`).
- Frame 1: big 8-point star, `R1` body, `R2` highlights, `N8` center, 32 px.
- Frame 2: star + ring shockwave (`R2`, 1 px) at 40 px, red sparks flying.
- Frame 3: ring at 46 px, star breaking into 6 sparks.
- Frame 4: sparks fading.

Code adds: 2-frame hit-stop (freeze), 2 px screen shake, red damage number with "!" (`ui_10`).

Optional (P3) `hit_critical_stealth.png` 48×48, 5 frames: same with a small amber "eye" symbol in frame 1–2 to tell the player the bonus came from stealth.

## Acceptance checklist

- [ ] 1 PNG (240×48)
- [ ] Impossible to confuse with a normal hit in the gameplay video
