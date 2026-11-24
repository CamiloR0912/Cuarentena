# vfx_13 — Code-drawn overlays (no PNG needed)

| Field | Value |
|---|---|
| Priority | **P1** |
| Note | **Nothing to draw.** This file fixes colors and line widths so code matches the art style |

These are simple shapes drawn in Godot with `CanvasItem._draw()` (`draw_circle`, `draw_arc`, `draw_line`, `draw_polygon`) inside the 960×540 viewport, so they stay pixel-aligned. Use `antialiased = false`.

| Overlay | Shape | Color | When visible |
|---|---|---|---|
| Noise ring | Circle outline, 1 px, radius = current noise radius, expands then fades over 0.4 s | `A1` | Each time Elena makes noise (walk 30, run 70, crouch 10, combat 90) |
| Enemy hearing radius r_a | Circle outline, 1 px dashed | `A0` 50% | F1 panel only |
| Enemy vision cone | Filled triangle fan | `R1` 15% + `R1` 1 px edge | F1 panel only (Corredor) |
| Random-walk trail | Polyline of the last 30 grid steps, 1 px | `G3` 60% | F1 panel only (Errante, Tosedor) |
| Boids neighbor links | Lines between neighbors within r_v, 1 px | `C1` 25% | F1 panel only (Masa) |
| Boids velocity vector | Line from body, 1 px, length ∝ speed | `N8` | F1 panel only |
| Panic bar over citizen | 16×2 bar | `C1` → `A1` → `R1` by P | F1 panel only |
| Sedation timer arc | Arc 2 px around sleep marker | `C1` | Always (sedated enemies) |
| Entity shadow | Ellipse (width = body width, height = 1/3) | `N0` 50% | Always |
| Aim line | Dotted line from Elena to cursor, 1 px, 4 px dash | `N8` 30% | Dart pistol equipped |

## Acceptance checklist

- [ ] Programmer uses exactly these values (palette IDs from `00_art_style_guide.md`)
