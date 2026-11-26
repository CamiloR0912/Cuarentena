# 00 — Art Style Guide (global rules for every asset)

Every other file in `designs/` assumes these rules. If a file contradicts this one, that file wins for that asset only.

## 1. Resolution and scaling

| Item | Value |
|---|---|
| Target display | **1920×1080 (1080p)**, 16:9 |
| Internal (virtual) canvas | **960×540 px**; the whole game is drawn here |
| Upscale | **×2 integer, nearest-neighbor** → 1920×1080. Other window sizes are letterboxed with black bars (never non-integer stretch) |
| Godot setup | Project Settings → Display → Window: viewport 960×540, window 1920×1080, stretch mode `viewport`, scale mode `integer`. Rendering → Textures → default filter `Nearest` |
| Art is authored at | **1× (960×540 scale)**. Never draw at 1080p. One art pixel = 2×2 screen pixels |
| World tile | **32×32 px** |
| Visible world | 30×17 tiles minus HUD (≈30×13.5 tiles of playfield) |

## 2. Style

- **Pixel art**, hard edges, no anti-aliasing, no sub-pixel blur, no gradients except where a file says "overlay".
- **Perspective: 3/4 top-down** (classic top-down RPG view, about 30° tilt): you see the top of the heads and the front of walls. Characters have 3 drawn facings: **down, up, right**. **Left = horizontal flip of right** (done in code; do not draw it).
- **Light source:** top-left. Highlights on top/left edges, shadows bottom/right.
- **Outline:** 1 px selective outline on characters, items and props using `N0 #121417` on the outer silhouette (may be lightened to the darkest ramp color of the inside on lit edges). Tiles have no outline.
- **No baked ground shadows** on characters/props that move. Code draws an ellipse shadow (`#121417`, 50% alpha) under each entity.
- **Tone:** tension, not horror. **No blood, no gore.** Hits produce grey/white sparks; infection is shown with greenish-grey skin, sweat and dark circles under the eyes, not wounds.
- **Color is information** (keep this strictly):
  - Red = danger / critical / Corredor / low HP.
  - Sick green & acid green = infection, contagion, viral samples.
  - Amber = noise, alerts, emergency lights, warnings.
  - Clinical blue & white = safety, healing, hospital, Elena, the cure.
- Visual references: *Project Zomboid* (abandoned city, top-down), *Hotline Miami* (readable fast top-down combat), *This War of Mine* (muted, human tone).

## 3. Palette — "Cuarentena-36"

Only these 36 colors are allowed in opaque pixels. The importable palette is [palette/cuarentena36.gpl](palette/cuarentena36.gpl) (works in Aseprite, LibreSprite, GIMP, Krita). **Core** = the 10 colors defined in the GDD; the rest are ramps derived from them.

| ID | Hex | Name | Main use |
|---|---|---|---|
| N0 | `#121417` | Ink | Outlines, deepest shadows |
| N1 | `#1C1F22` | Night asphalt | Shadows on asphalt, UI background |
| N2 | `#2B2F33` | **Asphalt (core)** | Streets, ground |
| N3 | `#3A3F45` | Asphalt light | Road wear, lit asphalt |
| N4 | `#4A5058` | **Concrete (core)** | Buildings, walls |
| N5 | `#5F666E` | Concrete light | Sidewalks, wall highlights |
| N6 | `#8A9199` | **Fog (core)** | Fog, distant objects, disabled UI |
| N7 | `#B4BAC0` | Fog light | Metal highlights, secondary text |
| N8 | `#EAF2F5` | **Clinical white (core)** | Main text, Elena's coat, the cure |
| B0 | `#1E2E3D` | Deep night | Night tint, deep shadows |
| B1 | `#3B5A75` | **Cold blue (core)** | Shadows, night, glass |
| B2 | `#5C7F9C` | Cold blue light | Glass highlights |
| C0 | `#2C6F96` | Clinical blue dark | Scrubs shadow, UI borders |
| C1 | `#4FA3D1` | **Clinical blue (core)** | Hospital, UI accent, healing |
| C2 | `#9ACFEA` | Clinical blue light | Healing sparkles, UI highlight |
| G0 | `#3E4A28` | Sick green deepest | Cloud shadow |
| G1 | `#5C6B3A` | Sick green dark | Infected clothing shadows |
| G2 | `#7A8F4E` | **Sick green (core)** | Infected, contagion clouds |
| G3 | `#B5C95A` | **Acid green (core)** | Viral samples, contagion alerts |
| G4 | `#DDE89A` | Acid green light | Sample glow, cloud highlights |
| R0 | `#6E1F18` | Danger red dark | Red shadows, roof tiles |
| R1 | `#C0392B` | **Danger red (core)** | Damage, critical, Corredor, low HP |
| R2 | `#E5675A` | Danger red light | Critical highlights |
| A0 | `#8A5A17` | Amber dark | Amber shadows, wood |
| A1 | `#E0A030` | **Emergency amber (core)** | Emergency lights, noise, warnings |
| A2 | `#F5D07A` | Amber light | Lamp glow, alert "!" |
| S0 | `#4A2F25` | Skin 0 | Darkest skin tone / shadow |
| S1 | `#7A5040` | Skin 1 | Mid-dark skin |
| S2 | `#B07E5F` | Skin 2 | Mid skin |
| S3 | `#DDB08E` | Skin 3 | Light skin / highlight |
| I0 | `#6B7360` | Infected skin dark | Infected skin shadow |
| I1 | `#8E9878` | Infected skin | Infected skin base (grey fever) |
| I2 | `#B3B9A0` | Infected skin light | Infected skin highlight |
| W0 | `#3D2B22` | Wood/hair dark | Hair, dark wood |
| W1 | `#6A4A35` | Wood | Doors, furniture |
| W2 | `#8F6A4C` | Wood light | Wood highlights |

Semi-transparent pixels are allowed **only** in assets marked as *overlay* (fog, lights, clouds, vignettes, UI panel backgrounds). They must still use palette colors.

## 4. Sizes by asset class

**Characters are built with the Universal LPC Spritesheet Generator** (see section 9), so every human character uses the LPC cell. The per-character files still list 32×32/48×48 sheet sizes from the first version; where they differ, **this table wins**. See section 8.

| Class | Cell (canvas per frame) | Visible body | Pivot (anchor = feet) |
|---|---|---|---|
| Elena, enemies, citizens, staff, Masa | **64×64** (LPC) | ~20×46 | (32, 62) |
| Boss (Paciente Cero) | 64×64 LPC muscular body, or 96×96 if hand-drawn | — | (32, 62) |
| World item pickup | 16×16 | ~12×12 | (8, 14) |
| Inventory/HUD item icon | 32×32 | ~26×26 | — |
| Weapon HUD icon | 48×24 | — | — |
| Dialogue portrait | 96×96 | bust | — |
| Tile | 32×32 | — | top-left |

## 5. Animation

- Frame rate is per animation (stated in each file). The game loop runs at 60 FPS; frame duration = 60 / fps game frames.
- Sprite sheets: **one PNG per animation**, frames left→right, **rows = facings in this order: down, up, right**. Same cell size for every frame, **no padding, no trimming**. Code slices by grid.
- Direction-less animations (e.g. death, sedated lying) have a single row.

## 6. File naming and export

- Format: **PNG-32 (RGBA)**, transparent background, no color profile, no compression artifacts.
- Names: `snake_case`, English, `<entity>_<animation>.png` (e.g. `elena_walk.png`, `errante_sedated.png`).
- Output root: `juego/assets/`. Each design file states its exact folder.
- Source files (`.aseprite` / `.piskel`) are kept next to the PNG in `juego/assets/_source/` with the same name.
- Tools: Aseprite (recommended), LibreSprite or Piskel (free). Export with "Sheet type: By rows", "Border padding: 0", "Spacing: 0", "Trim: off".

## 7. Grading evidence (workshop item 3.2)

The workshop requires evidence of origin. For **every** asset:

1. Draw a paper sketch first. Photograph or scan it to `designs/evidence/sketches/<asset_file_name>.jpg`.
2. If an internet asset is used as a base, it **must** be substantially modified (repainted with this palette, new silhouette, new animations). Save `designs/evidence/before_after/<asset>_before.png` and `<asset>_after.png`, and add a row to the attribution table (author, license, link, changes made). Unmodified copy-paste costs −0.3.
3. Tick the asset's acceptance checklist when it is done.

## 8. Character pipeline (LPC)

Approved by the course teacher: characters may be built from the open-source Universal LPC Spritesheet Generator, crediting the authors.

- Generator cloned at `tools/lpc/` (LPC layers + licenses).
- `python tools/lpc_build.py <character>` composites the layers, **recolors every ramp straight into Cuarentena-36**, applies our own modifications (e.g. Elena's coat tails), reorders rows to down/up/right and writes `CREDITS.txt` next to the sheets. This is an offline art tool only (like Aseprite); the game itself is Godot and contains no Python.
- Output for every character: `juego/assets/sprites/characters/<name>/<name>_<anim>.png` (this replaces the per-file folders in `char_02`–`char_08`). Generated animation names: `idle`, `walk`, `run`/`panic_run`/`chase`/`charge`, `attack`, `cough`, `alert`, `cower`, `sit`, `cheer`, `treat`, `summon`, `stun`, `fall`, `wheelchair`, and Elena's `attack_*`, `crouch`, `interact`, `use_item`, `hurt`, `death`. All cells are 64×64 except `elena_attack_pipe` (96×96, pivot (48, 78)). Weapons are LPC props recolored by brightness: club → pipe, dagger → syringe, slingshot → dart pistol, watering can → extinguisher. Portraits (`juego/assets/portraits/`) are LPC heads scaled ×3 with LPC facial expressions. **Sedated = hold the last `fall` frame; wake up = play `fall` reversed.**
- `python tools/preview_sheet.py out.png 3 <sheet.png>...` renders the sheets on asphalt, scaled, for review.
- In Godot, each sheet is used as an `AnimatedSprite2D` / `SpriteFrames` animation: `hframes` = frame count, `vframes` = 3 (down, up, right), `flip_h` for left.
- Things LPC does not have (carry, cough, crouch, extinguisher, stethoscope/badge details, weapons) are added by hand in Aseprite on top of the generated sheet. Keep the generated PNG as the "before" and the edited one as the "after" for the evidence folder.
- Licenses: LPC layers are CC-BY-SA 3.0 / GPL 3.0 / OGA-BY 3.0. Derived sprites keep those licenses; every `CREDITS.txt` must be copied into the credits screen (`ui_19`).

## 9. In-game language

Design files are in English, but **all player-visible text is in Spanish** (menus, HUD labels, item names). The font must support `á é í ó ú ñ Ñ ü ¿ ¡ ° % ±`.
