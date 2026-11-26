# Cuarentena — Graphic asset specifications

One file per graphic element. **Read [00_art_style_guide.md](00_art_style_guide.md) first**: it defines the resolution (960×540 pixel art scaled ×2 to 1080p), the 36-color palette, cell sizes, animation sheet format and the evidence required by the workshop (sketches, before/after).

Progress tracker (tick each image as you make it): [CHECKLIST.md](CHECKLIST.md).

Palette for your pixel editor: [palette/cuarentena36.gpl](palette/cuarentena36.gpl).

## Generators (re-run after changing a spec)

| Script | Produces |
|---|---|
| `python tools/lpc_build.py` | All characters (LPC layers recolored to the palette) and dialogue portraits |
| `python tools/tiled_build.py` | Tilesets (`city.tsx`, `props.tsx`) and the 4 Tiled maps (`juego/assets/maps/*.tmx`) |
| `python tools/ui_vfx_build.py` | HUD, UI kit, cursors, keys, simulation panels, VFX |
| `python tools/props_build.py` | Props, items, weapons, logo, menu, victory, level cards, app icon, Elena carrying |
| `python tools/evidence_build.py` | Before/after evidence images |

Order: lpc_build → tiled_build → ui_vfx_build → props_build → tiled_build (again, to place the new props) → evidence_build.
Hand editing: `tools/libresprite/libresprite.exe` (load `palette/cuarentena36.gpl`).

## Priorities

- **P1**: needed for Levels 1–2 playable (GDD week 4).
- **P2**: Levels 3–4, boss, polish of core screens (week 5).
- **P3**: nice to have (week 6).

Suggested drawing order: style guide → `char_01` Elena → `char_02` Errante → `tile_01` → `ui_01` kit → HUD (`ui_04`–`ui_09`) → items → the rest of P1 → P2 → P3.

## Index

### Characters

| File | Asset | Priority |
|---|---|---|
| [char_01_elena.md](char_01_elena.md) | Dr. Elena Ruiz (player), 12 animations | P1 |
| [char_02_errante.md](char_02_errante.md) | Errante (random walk) | P1 |
| [char_03_tosedor.md](char_03_tosedor.md) | Tosedor (diffusion clouds) | P1 |
| [char_04_corredor.md](char_04_corredor.md) | Corredor (FSM agent) | P2 |
| [char_05_masa.md](char_05_masa.md) | Masa member (boids), 3 variants | P2 |
| [char_06_paciente_cero.md](char_06_paciente_cero.md) | Paciente Cero boss (Markov phases) | P2 |
| [char_07_citizen.md](char_07_citizen.md) | Healthy citizens (panic agents), 4 variants | P1 |
| [char_08_hospital_staff.md](char_08_hospital_staff.md) | Hospital staff (queue servers) | P1 |

### Portraits

| File | Asset | Priority |
|---|---|---|
| [portrait_01_don_alvaro.md](portrait_01_don_alvaro.md) | Don Álvaro (radio) | P1 |
| [portrait_02_dra_mena.md](portrait_02_dra_mena.md) | Dra. Mena | P2 |
| [portrait_03_elena.md](portrait_03_elena.md) | Elena | P1 |
| [portrait_04_radio_static_overlay.md](portrait_04_radio_static_overlay.md) | Radio static overlay | P2 |

### Tilesets

| File | Asset | Priority |
|---|---|---|
| [tile_01_barrio.md](tile_01_barrio.md) | Residential streets (Level 1) | P1 |
| [tile_02_hospital.md](tile_02_hospital.md) | Hospital San Rafael (Level 2) | P1 |
| [tile_03_plaza_bolivar.md](tile_03_plaza_bolivar.md) | Plaza de Bolívar (Level 3) | P2 |
| [tile_04_university_lab.md](tile_04_university_lab.md) | University and lab (Level 4) | P2 |

### Props

| File | Asset | Priority |
|---|---|---|
| [prop_01_abandoned_cars.md](prop_01_abandoned_cars.md) | Abandoned cars (5 types) | P1 |
| [prop_02_ambulance.md](prop_02_ambulance.md) | Ambulance (drop-off) | P1 |
| [prop_03_dumpsters_trash.md](prop_03_dumpsters_trash.md) | Dumpsters and trash | P1 |
| [prop_04_barriers_fences.md](prop_04_barriers_fences.md) | Barriers, fences, cones | P1 |
| [prop_05_quarantine_tape.md](prop_05_quarantine_tape.md) | Quarantine tape | P1 |
| [prop_06_stretcher.md](prop_06_stretcher.md) | Stretcher states (queue servers) | P1 |
| [prop_07_doors.md](prop_07_doors.md) | Doors | P1 |
| [prop_08_hospital_furniture.md](prop_08_hospital_furniture.md) | Hospital furniture, supply shelf | P1/P2 |
| [prop_09_lab_furniture.md](prop_09_lab_furniture.md) | Lab furniture, cure synthesizer | P2 |
| [prop_10_barricades.md](prop_10_barricades.md) | Night-defense barricade | P2 |
| [prop_11_lights.md](prop_11_lights.md) | Street and emergency lights | P2 |
| [prop_12_checkpoint_tents.md](prop_12_checkpoint_tents.md) | Checkpoint tents, sandbags | P2 |
| [prop_13_pickup_stations.md](prop_13_pickup_stations.md) | First-aid box, pharmacy shelf | P1/P2 |

### Items and weapons

| File | Asset | Priority |
|---|---|---|
| [item_01_bandage.md](item_01_bandage.md) | Vendas | P1 |
| [item_02_darts.md](item_02_darts.md) | Dardos ×3 | P1 |
| [item_03_facemask.md](item_03_facemask.md) | Cubrebocas | P1 |
| [item_04_viral_sample.md](item_04_viral_sample.md) | Muestra viral | P1 |
| [item_05_adrenaline.md](item_05_adrenaline.md) | Adrenalina | P2 |
| [item_06_medkit.md](item_06_medkit.md) | Botiquín | P1 |
| [item_07_antiviral.md](item_07_antiviral.md) | Antiviral | P2 |
| [item_08_medical_supplies.md](item_08_medical_supplies.md) | Suministros | P1 |
| [weapon_01_pipe.md](weapon_01_pipe.md) | Tubo | P1 |
| [weapon_02_extinguisher.md](weapon_02_extinguisher.md) | Extintor | P1 |
| [weapon_03_dart_pistol.md](weapon_03_dart_pistol.md) | Pistola de dardos | P1 |
| [weapon_04_sedative_syringe.md](weapon_04_sedative_syringe.md) | Jeringa sedante | P1 |

### Visual effects

| File | Asset | Priority |
|---|---|---|
| [vfx_01_contagion_cloud.md](vfx_01_contagion_cloud.md) | Contagion cloud puffs | P1 |
| [vfx_02_hit_normal.md](vfx_02_hit_normal.md) | Normal hit | P1 |
| [vfx_03_hit_critical.md](vfx_03_hit_critical.md) | Critical hit | P1 |
| [vfx_04_extinguisher_spray.md](vfx_04_extinguisher_spray.md) | Extinguisher cone | P1 |
| [vfx_05_dart_projectile.md](vfx_05_dart_projectile.md) | Dart projectile | P1 |
| [vfx_06_lighting.md](vfx_06_lighting.md) | Night overlay and lights | P2 |
| [vfx_07_status_markers.md](vfx_07_status_markers.md) | ! ? zZz, Markov mutation | P1 |
| [vfx_08_pickup_sparkle.md](vfx_08_pickup_sparkle.md) | Drop and pickup effects | P2 |
| [vfx_09_dropoff_zone.md](vfx_09_dropoff_zone.md) | Safe drop-off zone | P1 |
| [vfx_10_fog.md](vfx_10_fog.md) | Fog layers | P2 |
| [vfx_11_screen_vignettes.md](vfx_11_screen_vignettes.md) | Damage and viral vignettes | P2 |
| [vfx_12_heal_and_buffs.md](vfx_12_heal_and_buffs.md) | Heal and buff effects | P2 |
| [vfx_13_code_drawn_overlays.md](vfx_13_code_drawn_overlays.md) | Code-drawn overlays (nothing to draw) | P1 |

### UI

| File | Asset | Priority |
|---|---|---|
| [ui_00_hud_layout.md](ui_00_hud_layout.md) | HUD master layout (positions) | P1 |
| [ui_01_ui_kit.md](ui_01_ui_kit.md) | Panels, buttons, slots (9-slice) | P1 |
| [ui_02_fonts.md](ui_02_fonts.md) | Pixel fonts (sourced) | P1 |
| [ui_03_math_glyphs.md](ui_03_math_glyphs.md) | λ μ ρ ℛ₀ … fallback glyphs | P2 |
| [ui_04_city_pulse_bar.md](ui_04_city_pulse_bar.md) | SIR city pulse bar | P1 |
| [ui_05_vitals_bars.md](ui_05_vitals_bars.md) | HP and viral load | P1 |
| [ui_06_status_icons.md](ui_06_status_icons.md) | Active effect icons | P1 |
| [ui_07_noise_meter.md](ui_07_noise_meter.md) | Noise meter | P1 |
| [ui_08_weapon_panel.md](ui_08_weapon_panel.md) | Weapon panel | P1 |
| [ui_09_inventory.md](ui_09_inventory.md) | Inventory bar | P1 |
| [ui_10_damage_numbers.md](ui_10_damage_numbers.md) | Floating damage digits | P1 |
| [ui_11_cursor.md](ui_11_cursor.md) | Cursors | P1 |
| [ui_12_key_prompts.md](ui_12_key_prompts.md) | Key and mouse prompts | P1 |
| [ui_13_hospital_panel.md](ui_13_hospital_panel.md) | Hospital M/M/c panel | P1 |
| [ui_14_radio_briefing.md](ui_14_radio_briefing.md) | Radio briefing (Monte Carlo p̂) | P1 |
| [ui_15_simulation_panel_f1.md](ui_15_simulation_panel_f1.md) | F1 simulation panel | P1 |
| [ui_16_logo.md](ui_16_logo.md) | Game logo | P1 |
| [ui_17_main_menu.md](ui_17_main_menu.md) | Main menu | P1/P2 |
| [ui_18_controls_screen.md](ui_18_controls_screen.md) | Controls screen (reuses assets) | P2 |
| [ui_19_credits_screen.md](ui_19_credits_screen.md) | Credits and attributions | P2 |
| [ui_20_pause_menu.md](ui_20_pause_menu.md) | Pause menu | P1 |
| [ui_21_game_over.md](ui_21_game_over.md) | Game over (4 causes) | P1 |
| [ui_22_victory.md](ui_22_victory.md) | Victory / cure scene | P2 |
| [ui_23_level_cards.md](ui_23_level_cards.md) | Level title cards | P3 |
| [ui_24_app_icon.md](ui_24_app_icon.md) | App icon (.exe) | P2 |

## Evidence folders (create as you work)

```
designs/evidence/
├── sketches/        # paper sketch photo for each asset
├── before_after/    # only for assets based on internet art
├── references/      # reference photos (Tunja, games)
└── attributions.md  # author, license, link, changes
```
