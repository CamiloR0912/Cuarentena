# vfx_11 — Screen vignettes (damage, viral load, low HP)

| Field | Value |
|---|---|
| Priority | **P2** |
| Used in | Full-screen feedback during gameplay |
| Output folder | `juego/assets/vfx/screen/` |
| Type | Overlay, full canvas **960×540** |

## Files

| File | Description | When |
|---|---|---|
| `vignette_damage.png` | Red (`R1`) border, thick at the corners (~120 px), thin at the edges (~40 px), stepped alpha 50% → 0 with dither, transparent center | Flash 0.25 s when Elena takes damage |
| `vignette_viral.png` | Same shape in sick green (`G2`), with **small irregular "infection" blobs** creeping in from the corners | Alpha follows viral load: 0 at < 50%, up to 70% near 100% |
| `vignette_lowhp.png` | Darker red (`R0`) | Pulses at 1 Hz when HP < 25 |
| `vignette_stealth.png` | Very subtle dark border (`N0` 30%) | While crouched (stealth mode feedback) |

## Acceptance checklist

- [ ] 4 PNGs at 960×540
- [ ] Center 600×300 area fully transparent (never covers the action)
