# ui_00 — HUD master layout (reference for all HUD pieces)

| Field | Value |
|---|---|
| Priority | **P1** |
| Canvas | 960×540 (scaled ×2 to 1080p) |
| Output | No PNG of its own. Defines **where** every HUD element (`ui_04`–`ui_09`) goes |

## Layout (pixel coordinates on the 960×540 canvas)

```
y=0   ┌──────────────────────────────────────────────────────────────────────────────┐
      │ PULSO DE LA CIUDAD                                              R₀ = 2,4     │  top bar
      │ [██████ I ██████|░░░░░░░░ S ░░░░░░░░░░░░░░|▒▒▒ R ▒▒▒]   ▲60%    I/N = 32 %   │  960×32
y=32  ├──────────────────────────────────────────────────────────────────────────────┤
      │                                                              ┌───────────┐   │
      │                         PLAYFIELD 960×444                    │ hospital  │   │
      │                       (≈30×14 tiles visible)                 │ panel     │   │
      │                                                              │ (Lvl 2)   │   │
      │                                                              └───────────┘   │
y=476 ├──────────────────────────────────────────────────────────────────────────────┤
      │ ♥[██████████░░] ▮▯▯▯▯     [1][2][3][4][5][6]                 [icon] Tubo     │  bottom bar
      │ ☣[████░░░░░░░░] RUIDO                                                ∞       │  960×64
      │ [mask 72s][adr 12s]                                              ● ○ ○ ○     │
y=540 └──────────────────────────────────────────────────────────────────────────────┘
```

| Element | File | Position (x, y) | Size |
|---|---|---|---|
| Top bar background | `ui_01` panel | (0, 0) | 960×32 |
| City pulse bar | `ui_04` | (8, 17) | 760×10 |
| City pulse title | text | (8, 3) | — |
| R₀ and I/N readout | text + `ui_03` glyphs | (788, 3) and (788, 17) | 164×28 |
| Bottom bar background | `ui_01` panel | (0, 476) | 960×64 |
| HP bar | `ui_05` | icon (8, 484), bar (24, 485) | 160×10 |
| Viral load bar | `ui_05` | icon (8, 502), bar (24, 503) | 160×10 |
| Active effects | `ui_06` | (8, 520), 18 px apart | 16×16 each |
| Noise meter | `ui_07` | (200, 484) | 40×24 + label |
| Inventory | `ui_09` | (350, 484) | 6 × 40×40, gap 4 → 260×40 |
| Weapon panel | `ui_08` | (760, 480) | 192×56 |
| Hospital panel (Level 2 only) | `ui_13` | (760, 40) | 192×428 |
| F1 simulation panel | `ui_15` | (0, 32) | 320×444 |
| Interaction prompt | `ui_12` | above the target, centered | 16×16 + text |

## Rules

- Top and bottom bars are solid (not over the world), so the playfield is exactly 960×444.
- All HUD text in Spanish, `N8` on dark panels, secondary text `N7`.
- Minimum text size: the font's native size (never scaled down).
- HUD never uses semi-transparent text.
