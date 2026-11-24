# ui_24 — Application icon

| Field | Value |
|---|---|
| Priority | **P2** (needed for the Godot Windows export .exe and the browser tab of the web build) |
| Output folder | `juego/assets/ui/icon/` |

## Description

A medical cross (`N8`, `C1` shading) over a round virus shape (`G2`/`G3` spikes) on a dark square background (`N1`, 1 px `C0` border). Must read at 16×16.

## Files

| File | Size | Notes |
|---|---|---|
| `icon_16.png` | 16×16 | Hand-drawn (simplified, no spikes detail) |
| `icon_32.png` | 32×32 | Hand-drawn master — Godot Project Settings → Application → Config → Icon, and web favicon |
| `icon_256.png` | 256×256 | `icon_32.png` upscaled ×8 nearest-neighbor (no redraw) |
| `cuarentena.ico` | 16, 32, 256 | Multi-size .ico built from the 3 PNGs (Windows export preset → Application → Icon) |

## Acceptance checklist

- [ ] 4 files
- [ ] Recognizable in the Windows taskbar at 16 px
