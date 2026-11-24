# Asset checklist

Tick each image as you finish it: change `- [ ]` to `- [x]` (VS Code and GitHub render them as checkboxes).
Sizes are the **full sheet size** (all frames). Details for each one are in the linked spec file.
"Done" = exported PNG in its `juego/assets/` folder **and** its paper sketch in `designs/evidence/sketches/`.

Priorities: **P1** Levels 1–2 · **P2** Levels 3–4 · **P3** polish.

---

## 1. Characters

> **Characters use the LPC pipeline** (64×64 cells, rows down/up/right). Regenerate any of them with `python tools/lpc_build.py <name>`. Output: `juego/assets/sprites/characters/<name>/<name>_<anim>.png`.

### Elena — [char_01](char_01_elena.md) · P1 · folder `elena/`
- [x] `idle` 128×192 · `walk` 512×192 · `run` 512×192 · `hurt` 128×64 · `death` 384×64
- [x] `attack_pipe` **576×288 (96×96 cells, pivot (48, 78))** — LPC club recolored as a metal pipe
- [x] `attack_syringe` 512×192 — LPC dagger recolored as a syringe
- [x] `attack_dart` 832×192 — LPC slingshot recolored amber as the dart pistol
- [x] `attack_extinguisher` 256×192 — LPC watering can recolored red
- [x] `crouch` 64×192 (1 kneeling frame; code slides it while crouch-walking) · `interact` 192×192 · `use_item` 256×64 · `cheer` 192×64 (victory)
- [x] `carry_walk` — not in LPC: hand-edit, or adapt (e.g. walk + sedated body drawn on top in code) — generated: elena_carry_walk.png (walk + sedated body over the shoulders)
- [x] Details by hand (optional): stethoscope, ID badge — dropped (team decision)

### Story NPCs (map sprites) · P2 · folders `don_alvaro/`, `dra_mena/`
- [x] Don Álvaro: `idle`, `walk`, `sit` (at his radio) — grey hair, moustache, glasses, brown sweater
- [x] Dra. Mena: `idle`, `walk`, `treat` (working at the bench), `cheer` (victory) — lab coat, glasses

### Patients · P2 · folder `patient_wheelchair/`
- [x] `patient_wheelchair_wheelchair.png` 64×192 — patient in a wheelchair for the hospital waiting room

### Errante — [char_02](char_02_errante.md) · P1 · folders `errante/`, `errante_b/`
- [x] `errante_idle.png` 128×192 · `errante_walk.png` 512×192 · `errante_attack.png` 384×192 · `errante_fall.png` 384×64
- [x] Variant B: same 4 sheets in `errante_b/` (woman, blue sweater)
- [x] Sedated / wake up: no new art — code holds the last `fall` frame, and plays `fall` reversed to wake up — done in code: hold the last `fall` frame / play `fall` reversed

### Tosedor — [char_03](char_03_tosedor.md) · P1 · folder `tosedor/`
- [x] `tosedor_idle.png` 128×192 · `tosedor_walk.png` 512×192 · `tosedor_cough.png` 256×192 · `tosedor_fall.png` 384×64
- [x] Hand-edit: torn surgical mask hanging from one ear, acid-green tint around the mouth (the LPC mask covers the whole face, so it was left out) — dropped (team decision)

### Corredor — [char_04](char_04_corredor.md) · P2 · folder `corredor/`
- [x] `corredor_idle.png` 128×192 (SEARCH: code turns the facing) · `corredor_patrol.png` 512×192 · `corredor_alert.png` 128×192 · `corredor_chase.png` 512×192 · `corredor_attack.png` 512×192 · `corredor_fall.png` 384×64

### Masa — [char_05](char_05_masa.md) · P2 · folders `masa_a/`, `masa_b/`, `masa_c/`
- [x] Per variant: `walk` 512×192 · `attack` 384×192 · `fall` 384×64 (teen body = smaller figure)

### Paciente Cero — [char_06](char_06_paciente_cero.md) · P2 · folder `paciente_cero/`
- [x] `wander` 512×192 · `charge` 512×192 · `cough` 256×192 · `summon` 448×64 · `stun` 128×64 · `attack` 384×192 · `fall` 384×64 (muscular body, hospital-gown trousers)
- [x] Hand-edit: torn grey lab coat, acid-green veins — dropped (team decision)
- [x] `pc_aura_charge.png`, `pc_aura_cough.png`, `pc_aura_summon.png` — 256×64 each (4 frames of 64×64, drawn by hand) (generated)
- [x] Decide size in Godot: same 64×64 as everyone (muscular silhouette + aura) or node `scale = 2` — decided: 64×64 like everyone, muscular body + phase aura

### Citizens — [char_07](char_07_citizen.md) · P1 · folders `citizen_student/`, `citizen_vendor/`, `citizen_elder/`, `citizen_worker/`
- [x] Per variant: `idle` 128×192 · `walk` 512×192 · `panic_run` 512×192 · `cower` 128×64 · `sit` 64×192 (waiting room) · `cheer` 192×64 (rescued) · `fall` 384×64. Scared face on `panic_run`/`sit`; the elder walks with a cane
- [x] `infected` transformation: no new art — code flashes `infection_flash` (vfx_07) and swaps to an Errante — done in code with `infection_flash` (vfx_07)
- [x] Hand-edit (optional): worker's surgical mask, student's backpack (the LPC versions lack idle/run frames) — dropped (team decision)

### Hospital staff — [char_08](char_08_hospital_staff.md) · P1 · folders `staff_nurse/`, `staff_doctor/`
- [x] Per variant: `idle` 128×192 · `walk` 512×192 · `treat` 256×192
- [x] Hand-edit: nurse's surgical mask and cap — dropped (team decision)

### All characters
- [x] Copy every `CREDITS.txt` into `designs/evidence/attributions.md` — done: designs/evidence/attributions.md
- [x] Save the "before" (LPC default colors from the web generator) and "after" (our sheets) images for the evidence folder

---

## 2. Portraits

Generated from the LPC heads (cropped 32×32, scaled ×3 to 96×96) with LPC facial expressions; frame 2 = blink. Folder `juego/assets/portraits/`.

- [x] `alvaro_neutral.png`, `alvaro_worried.png`, `alvaro_confident.png` — 192×96 · [portrait_01](portrait_01_don_alvaro.md)
- [x] `mena_neutral.png`, `mena_urgent.png`, `mena_hopeful.png` — 192×96 · [portrait_02](portrait_02_dra_mena.md)
- [x] `elena_portrait_neutral.png`, `elena_portrait_determined.png` — 192×96, `elena_portrait_hurt.png` — 96×96 · [portrait_03](portrait_03_elena.md)
- [x] `radio_static.png` — 384×96 · P2 · [portrait_04](portrait_04_radio_static_overlay.md) (not LPC; draw or generate in code) (generated)

---

## 3. Tilesets

> **Maps are built with Tiled** from free LPC tilesets (CC0 / CC-BY-SA / GPL, see `juego/assets/tilesets/CREDITS.txt`), recolored to Cuarentena-36. Regenerate with `python tools/tiled_build.py`. Output: `juego/assets/tilesets/city.tsx` (32×32 tiles), `props.tsx` (cars, trees, lamps, bins, cones, statues), `juego/assets/maps/<level>.tmx` + `_preview.png`. Open the `.tmx` in Tiled to edit by hand; import into Godot with the YATI plugin.

### Barrio — [tile_01](tile_01_barrio.md) · P1
- [x] `level1_barrio.tmx` — 64×40 tiles: 6 blocks, Elena's building, colonial houses, pharmacy, park, cars, checkpoint to the hospital
- [x] Collision layer + markers (`player_spawn`, `level_exit`, `dropoff_zone`, `pharmacy`, `medkit`, `supplies`, `spawn_errante`, `spawn_tosedor`)
- [x] Quarantine tape, sawhorses, ambulance (not in LPC: draw from prop_02 / prop_04 / prop_05) — generated and placed in level1_barrio.tmx

### Hospital — [tile_02](tile_02_hospital.md) · P1
- [x] `level2_hospital.tmx` — 48×34 tiles: waiting room (queue), triage hall with 6 stretchers + IV stands, supply room, doctors' office, entrance, ambulance bay and street
- [x] Markers (`queue_slot` ×10, `stretcher` ×6, `staff_spot` ×6, `reception`, `supply_shelf`, `barricade_slot` ×4, `dropoff_zone`, `spawn_night_wave`, `convoy_arrival`, `level_exit`)
- [x] Stretcher states (closed / occupied / discharge) and barricades: the map uses one LPC bed; the game swaps the prop by state or draws prop_06 / prop_10 — generated; occupied/closed placed in level2_hospital.tmx

### Centro / Plaza de Bolívar — [tile_03](tile_03_plaza_bolivar.md) · P2
- [x] `level3_centro.tmx` — 60×44 tiles: cathedral with towers, colonial buildings, stone plaza with monument, lamps, trees, abandoned checkpoint
- [x] Markers (`spawn_masa`, `spawn_corredor`, `spawn_citizen`, `dropoff_zone`, `level_exit`)
- [x] Arcades (soportales) and a more faithful cathedral façade (not in LPC) — dropped (team decision)

### Universidad / Lab — [tile_04](tile_04_university_lab.md) · P2
- [x] `level4_laboratorio.tmx` — 60×44 tiles: lobby, narrow corridor, courtyard with trees, auditorium (boss arena), Dra. Mena's lab
- [x] Markers (`boss_spawn`, `boss_arena`, `spawn_masa`, `spawn_corredor`, `spawn_errante`, `dra_mena`, `cure_synthesizer`, `sample_delivery`)
- [x] Cure synthesizer (prop_09) — not in LPC — generated and placed in level4_laboratorio.tmx

---

## 4. Props

### Cars — [prop_01](prop_01_abandoned_cars.md) · P1
- [x] `car_sedan_h.png` — 64×40 → LPC substitute: `car_red_h / car_blue_h`
- [x] `car_sedan_v.png` — 40×64 → LPC substitute: `car_red_v / car_blue_v`
- [x] `car_taxi_h.png` — 64×40 → LPC substitute: `car_taxi_h`
- [x] `car_taxi_v.png` — 40×64 → LPC substitute: `car_taxi_v`
- [x] `car_suv_h.png` — 64×40 → LPC substitute: `car_grey_h (pickup)`
- [x] `car_suv_v.png` — 40×64 → LPC substitute: `car_grey_v`
- [x] `car_wrecked_h.png` — 64×40 (generated)
- [x] `car_police_h.png` — 128×40 → LPC substitute: `car_police_h`
- [x] `car_police_v.png` — 80×64 → LPC substitute: `car_police_v`

### Ambulance — [prop_02](prop_02_ambulance.md) · P1
- [x] `ambulance_h.png` — 192×48 (generated)
- [x] `ambulance_v.png` — 96×96 (generated)

### Dumpsters and trash — [prop_03](prop_03_dumpsters_trash.md) · P1
- [x] `dumpster_green.png` — 48×40 (generated)
- [x] `dumpster_open.png` — 48×40 (generated)
- [x] `trash_bags.png` — 32×24 (generated)
- [x] `trash_can.png` — 16×24 → LPC substitute: `bin_red / bin_green`
- [x] `cardboard_boxes.png` — 32×32 (generated)
- [x] `shopping_cart.png` — 32×24 (generated)

### Barriers and fences — [prop_04](prop_04_barriers_fences.md) · P1
- [x] `jersey_barrier_h.png` — 64×32 (generated)
- [x] `jersey_barrier_v.png` — 24×64 (generated)
- [x] `sawhorse_quarantine.png` — 32×32 (generated)
- [x] `fence_chainlink_h.png` — 32×48 (generated)
- [x] `fence_chainlink_v.png` — 16×64 (generated)
- [x] `fence_chainlink_post.png` — 16×48 (generated)
- [x] `traffic_cone.png` — 16×16 → LPC substitute: `cone`

### Quarantine tape — [prop_05](prop_05_quarantine_tape.md) · P1
- [x] `tape_h.png` — 64×16 (generated)
- [x] `tape_v.png` — 32×32 (generated)
- [x] `tape_post.png` — 8×24 (generated)
- [x] `tape_broken_end.png` — 64×16 (generated)
- [x] `tape_on_door.png` — 32×64 (generated)

### Stretchers — [prop_06](prop_06_stretcher.md) · P1
- [x] `stretcher_closed.png` — 32×64 (generated)
- [x] `stretcher_open_empty.png` — 64×64 → LPC substitute: `stretcher`
- [x] `stretcher_occupied.png` — 64×64 (generated)
- [x] `stretcher_occupied_citizen.png` — 64×64 (generated)
- [x] `stretcher_discharge.png` — 96×64 (generated)
- [x] `wheelchair.png` — 32×32 → LPC substitute: `patient_wheelchair (character)`
- [x] `waiting_chairs.png` — 96×32 → LPC substitute: `chair`

### Doors — [prop_07](prop_07_doors.md) · P1
- [x] `door_wood_h.png` — 96×64 → LPC substitute: `door / door_in (tiles)`
- [x] `door_wood_v.png` — 48×64 (generated)
- [x] `door_hospital_h.png` — 96×64 (generated)
- [x] `door_hospital_v.png` — 48×64 (generated)
- [x] `door_glass_auto.png` — 256×64 (generated)
- [x] `door_locked_overlay.png` — 16×16 (generated)
- [x] `exit_marker.png` — 64×16 (generated)

### Hospital furniture — [prop_08](prop_08_hospital_furniture.md) · P1/P2
- [x] `reception_desk.png` — 96×48 → LPC substitute: `counter`
- [x] `supply_shelf.png` — 256×64 (generated)
- [x] `iv_stand.png` — 16×48 → LPC substitute: `iv`
- [x] `monitor_cart.png` — 64×48 (generated)
- [x] `medicine_cabinet.png` — 32×64 → LPC substitute: `cabinet_tall`
- [x] `biohazard_bin.png` — 16×24 (generated)
- [x] `oxygen_tanks.png` — 32×32 (generated)
- [x] `hospital_sign_triage.png` — 64×32 (generated)

### Lab furniture — [prop_09](prop_09_lab_furniture.md) · P2
- [x] `lab_bench.png` — 64×48 → LPC substitute: `table`
- [x] `lab_bench_messy.png` — 64×48 (generated)
- [x] `fume_hood.png` — 64×64 (generated)
- [x] `centrifuge.png` — 64×32 (generated)
- [x] `sample_fridge.png` — 64×64 → LPC substitute: `fridge`
- [x] `cure_synthesizer.png` — 1056×96 (11 frames) (generated)
- [x] `cure_synthesizer_glow.png` — 384×96 (generated)
- [x] `whiteboard.png` — 64×48 (generated)

### Barricades — [prop_10](prop_10_barricades.md) · P2
- [x] `barricade.png` — 256×48 (generated)
- [x] `barricade_hit.png` — 128×48 (generated)

### Lights — [prop_11](prop_11_lights.md) · P2
- [x] `streetlamp_modern.png` — 32×64 → LPC substitute: `lamp`
- [x] `streetlamp_flicker.png` — 64×64 (generated)
- [x] `emergency_beacon.png` — 64×16 (generated)
- [x] `hospital_red_cross_sign.png` — 64×32 (generated)
- [x] `light_tower.png` — 32×64 (generated)

### Checkpoint — [prop_12](prop_12_checkpoint_tents.md) · P2
- [x] `tent_medical.png` — 96×80 (generated)
- [x] `tent_military.png` — 96×80 (generated)
- [x] `sandbags.png` — 64×32 (generated)
- [x] `folding_table.png` — 48×32 (generated)
- [x] `supply_crate_big.png` — 32×32 (generated)

### Pickup stations — [prop_13](prop_13_pickup_stations.md) · P1/P2
- [x] `firstaid_wall_box.png` — 64×32 (generated)
- [x] `pharmacy_shelf.png` — 128×64 (generated)
- [x] `pharmacy_sign.png` — 64×32 (generated)

---

## 5. Items and weapons

### Items
- [x] `bandage_world.png` — 16×16 · P1 · [item_01](item_01_bandage.md) (generated)
- [x] `bandage_icon.png` — 32×32 · P1 (generated)
- [x] `darts_world.png` — 16×16 · P1 · [item_02](item_02_darts.md) (generated)
- [x] `darts_icon.png` — 32×32 · P1 (generated)
- [x] `facemask_world.png` — 16×16 · P1 · [item_03](item_03_facemask.md) (generated)
- [x] `facemask_icon.png` — 32×32 · P1 (generated)
- [x] `sample_world.png` — 64×16 · P1 · [item_04](item_04_viral_sample.md) (generated)
- [x] `sample_icon.png` — 32×32 · P1 (generated)
- [x] `adrenaline_world.png` — 32×16 · P2 · [item_05](item_05_adrenaline.md) (generated)
- [x] `adrenaline_icon.png` — 32×32 · P2 (generated)
- [x] `medkit_world.png` — 16×16 · P1 · [item_06](item_06_medkit.md) (generated)
- [x] `medkit_icon.png` — 32×32 · P1 (generated)
- [x] `antiviral_world.png` — 16×16 · P2 · [item_07](item_07_antiviral.md) (generated)
- [x] `antiviral_icon.png` — 32×32 · P2 (generated)
- [x] `supplies_world.png` — 24×24 · P1 · [item_08](item_08_medical_supplies.md) (generated)
- [x] `supplies_icon.png` — 16×16 · P1 (generated)

### Weapons · P1
- [x] `pipe_hud.png` — 48×24 · [weapon_01](weapon_01_pipe.md) (generated)
- [x] `pipe_world.png` — 32×16 (generated)
- [x] `extinguisher_hud.png` — 48×24 · [weapon_02](weapon_02_extinguisher.md) (generated)
- [x] `extinguisher_world.png` — 16×32 (generated)
- [x] `dart_pistol_hud.png` — 48×24 · [weapon_03](weapon_03_dart_pistol.md) (generated)
- [x] `dart_pistol_world.png` — 32×16 (generated)
- [x] `syringe_hud.png` — 48×24 · [weapon_04](weapon_04_sedative_syringe.md) (generated)
- [x] `syringe_world.png` — 16×16 (generated)

---

## 6. Visual effects

- [x] `contagion_puff.png` — 64×16 · P1 · [vfx_01](vfx_01_contagion_cloud.md) (generated)
- [x] `contagion_puff_small.png` — 16×8 · P1 (generated)
- [x] `hit_normal.png` — 128×32 · P1 · [vfx_02](vfx_02_hit_normal.md) (generated)
- [x] `hit_critical.png` — 240×48 · P1 · [vfx_03](vfx_03_hit_critical.md) (generated)
- [x] `hit_critical_stealth.png` — 240×48 · P3 (optional) (generated)
- [x] `extinguisher_spray.png` — 384×96 · P1 · [vfx_04](vfx_04_extinguisher_spray.md) (generated)
- [x] `dart_projectile.png` — 64×8 · P1 · [vfx_05](vfx_05_dart_projectile.md) (generated)
- [x] `dart_trail.png` — 8×4 · P1 (generated)

### Lighting — [vfx_06](vfx_06_lighting.md) · P2
- [x] `light_radial_128.png` — 128×128 (generated)
- [x] `light_radial_256.png` — 256×256 (generated)
- [x] `light_player_96.png` — 96×96 (generated)
- [x] `light_cone_beam.png` — 128×64 (generated)
- [x] `light_tint_amber.png` — 128×128 (generated)
- [x] `light_tint_blue.png` — 128×128 (generated)
- [x] `light_tint_red.png` — 128×128 (generated)

### Status markers — [vfx_07](vfx_07_status_markers.md) · P1
- [x] `marker_alert.png` — 16×12 (generated)
- [x] `marker_chase.png` — 24×12 (generated)
- [x] `marker_search.png` — 16×12 (generated)
- [x] `marker_sleep.png` — 48×16 (generated)
- [x] `marker_follow.png` — 16×8 (generated)
- [x] `marker_carry_prompt.png` — 32×16 (generated)
- [x] `mutation_pulse.png` — 128×32 (generated)
- [x] `infection_flash.png` — 96×32 (generated)

### Drops — [vfx_08](vfx_08_pickup_sparkle.md) · P2
- [x] `drop_pop.png` — 64×16 (generated)
- [x] `rare_sparkle.png` — 96×24 (generated)
- [x] `rare_sparkle_amber.png` — 96×24 (generated)
- [x] `pickup_collect.png` — 64×16 (generated)
- [x] `nothing_dropped.png` — 48×16 (generated)

### Others
- [x] `dropoff_zone.png` — 256×64 · P1 · [vfx_09](vfx_09_dropoff_zone.md) (generated)
- [x] `dropoff_confirm.png` — 320×64 · P1 (generated)
- [x] `fog_layer_a.png` — 480×270 · P2 · [vfx_10](vfx_10_fog.md) (generated)
- [x] `fog_layer_b.png` — 480×270 · P2 (generated)
- [x] `vignette_damage.png` — 960×540 · P2 · [vfx_11](vfx_11_screen_vignettes.md) (generated)
- [x] `vignette_viral.png` — 960×540 · P2 (generated)
- [x] `vignette_lowhp.png` — 960×540 · P2 (generated)
- [x] `vignette_stealth.png` — 960×540 · P2 (generated)
- [x] `heal_plus.png` — 192×32 · P2 · [vfx_12](vfx_12_heal_and_buffs.md) (generated)
- [x] `antiviral_cleanse.png` — 192×32 · P2 (generated)
- [x] `mask_on.png` — 128×32 · P2 (generated)
- [x] `adrenaline_aura.png` — 192×48 · P2 (generated)

---

## 7. UI

### UI kit — [ui_01](ui_01_ui_kit.md) · P1
- [x] `panel_dark.png` — 24×24 (generated)
- [x] `panel_solid.png` — 24×24 (generated)
- [x] `panel_warning.png` — 24×24 (generated)
- [x] `panel_danger.png` — 24×24 (generated)
- [x] `panel_radio.png` — 32×32 (generated)
- [x] `button.png` — 96×24 (generated)
- [x] `button_danger.png` — 96×24 (generated)
- [x] `bar_frame.png` — 8×12 (generated)
- [x] `slot.png` — 120×40 (generated)
- [x] `divider_h.png` — 8×4 (generated)
- [x] `tooltip.png` — 16×16 (generated)

### Fonts and glyphs
- [x] Pixel font chosen, in `juego/assets/fonts/` with its license · P1 · [ui_02](ui_02_fonts.md) — Pixel Operator (CC0) in juego/assets/fonts/
- [x] `math_glyphs.png` — 160×12 · P2 (only if the font lacks them) · [ui_03](ui_03_math_glyphs.md) (generated)

### HUD · P1
- [x] `sir_bar_frame.png` — 764×14 · [ui_04](ui_04_city_pulse_bar.md) (generated)
- [x] `sir_infected_texture.png` — 8×10 (generated)
- [x] `sir_threshold_marker.png` — 14×18 (generated)
- [x] `sir_legend_icons.png` — 24×8 (generated)
- [x] `sir_danger_glow.png` — 1528×14 (generated)
- [x] `icon_hp.png` — 24×12 · [ui_05](ui_05_vitals_bars.md) (generated)
- [x] `icon_viral.png` — 24×12 (generated)
- [x] `bar_fill_hp.png` — 4×8 (generated)
- [x] `bar_fill_viral.png` — 4×8 (generated)
- [x] `bar_fill_low.png` — 4×8 (generated)
- [x] `mask_shield_overlay.png` — 160×10 (generated)
- [x] `status_icons.png` — 112×16 · [ui_06](ui_06_status_icons.md) (generated)
- [x] `noise_meter.png` — 240×16 · [ui_07](ui_07_noise_meter.md) (generated)
- [x] `noise_meter_pulse.png` — 80×16 (generated)
- [x] `weapon_icon_frame.png` — 104×28 · [ui_08](ui_08_weapon_panel.md) (generated)
- [x] `weapon_slot_dots.png` — 24×8 (generated)
- [x] `ammo_empty_flash.png` — 104×28 (generated)
- [x] `inventory_full_flash.png` — 528×44 · [ui_09](ui_09_inventory.md) (generated)
- [x] `slot_new_item.png` — 160×40 (generated)
- [x] `digits_normal.png` — 78×8 · [ui_10](ui_10_damage_numbers.md) (generated)
- [x] `digits_critical.png` — 88×11 (generated)
- [x] `digits_heal.png` — 78×8 (generated)
- [x] `digits_viral.png` — 78×8 (generated)

### Cursors — [ui_11](ui_11_cursor.md) · P1
- [x] `cursor_crosshair.png` — 16×16 (generated)
- [x] `cursor_crosshair_enemy.png` — 16×16 (generated)
- [x] `cursor_crosshair_backstab.png` — 32×16 (generated)
- [x] `cursor_crosshair_cooldown.png` — 16×16 (generated)
- [x] `cursor_pointer.png` — 12×12 (generated)
- [x] `cursor_pointer_hover.png` — 12×12 (generated)

### Key prompts — [ui_12](ui_12_key_prompts.md) · P1 (2 frames each)
- [x] `key_w.png` — 32×16 (generated)
- [x] `key_a.png` — 32×16 (generated)
- [x] `key_s.png` — 32×16 (generated)
- [x] `key_d.png` — 32×16 (generated)
- [x] `key_arrows.png` — 128×16 (generated)
- [x] `key_e.png` — 32×16 (generated)
- [x] `key_f.png` — 32×16 (generated)
- [x] `key_q.png` — 32×16 (generated)
- [x] `key_1.png` — 32×16 (generated)
- [x] `key_2.png` — 32×16 (generated)
- [x] `key_3.png` — 32×16 (generated)
- [x] `key_4.png` — 32×16 (generated)
- [x] `key_plus.png` — 32×16 (generated)
- [x] `key_minus.png` — 32×16 (generated)
- [x] `key_shift.png` — 64×16 (generated)
- [x] `key_space.png` — 96×16 (generated)
- [x] `key_esc.png` — 48×16 (generated)
- [x] `key_f1.png` — 48×16 (generated)
- [x] `mouse_left.png` — 24×16 (generated)
- [x] `mouse_wheel.png` — 24×16 (generated)
- [x] `mouse_move.png` — 24×16 (generated)

### Hospital panel — [ui_13](ui_13_hospital_panel.md) · P1
- [x] `icon_day.png` — 16×16 (generated)
- [x] `icon_night.png` — 16×16 (generated)
- [x] `icon_patient_citizen.png` — 12×12 (generated)
- [x] `icon_patient_sedated.png` — 12×12 (generated)
- [x] `icon_patient_leaving.png` — 24×12 (generated)
- [x] `icon_stretcher_open.png` — 16×16 (generated)
- [x] `icon_stretcher_busy.png` — 32×16 (generated)
- [x] `icon_stretcher_closed.png` — 16×16 (generated)
- [x] `button_minus.png` — 48×16 (generated)
- [x] `button_plus.png` — 48×16 (generated)
- [x] `patience_bar_fill.png` — 12×4 (generated)
- [x] `icon_warning.png` — 24×12 (generated)
- [x] `hospital_collapse_banner.png` — 384×32 (generated)

### Radio briefing — [ui_14](ui_14_radio_briefing.md) · P1
- [x] `radio_signal_icon.png` — 96×12 (generated)
- [x] `radio_led.png` — 16×8 (generated)
- [x] `digits_big.png` — 176×24 (generated)
- [x] `ci_bar_track.png` — 240×12 (generated)
- [x] `ci_whisker.png` — 8×12 (generated)
- [x] `ci_point.png` — 6×12 (generated)
- [x] `threat_icon.png` — 24×12 (generated)
- [x] `sim_spinner.png` — 128×16 (generated)

### F1 simulation panel — [ui_15](ui_15_simulation_panel_f1.md) · P1
- [x] `model_icons.png` — 112×16 (generated)
- [x] `check_ok.png` — 8×8 (generated)
- [x] `check_fail.png` — 8×8 (generated)
- [x] `section_header.png` — 8×16 (generated)
- [x] `sparkline_bg.png` — 140×24 (generated)

### Screens
- [x] `logo.png` — 400×120 · P1 · [ui_16](ui_16_logo.md) (generated)
- [x] `logo_anim.png` — 1600×120 · P1 (generated)
- [x] `logo_small.png` — 200×60 · P1 (generated)
- [x] `menu_bg_sky.png` — 960×540 · P1 · [ui_17](ui_17_main_menu.md) (generated)
- [x] `menu_bg_city.png` — 2048×540 · P1 (generated)
- [x] `menu_bg_front.png` — 1920×540 · P2 (generated)
- [x] `pause_icon.png` — 48×24 · P1 · [ui_20](ui_20_pause_menu.md) (generated)
- [x] `cause_hp.png` — 256×64 · P1 · [ui_21](ui_21_game_over.md) (generated)
- [x] `cause_viral.png` — 256×64 · P1 (generated)
- [x] `cause_city.png` — 128×64 · P1 (generated)
- [x] `cause_hospital.png` — 128×64 · P1 (generated)
- [x] `stat_icons.png` — 96×16 · P1 (generated)
- [x] `chart_bg.png` — 280×140 · P1 (generated)
- [x] `victory_scene.png` — 1920×540 · P2 · [ui_22](ui_22_victory.md) (generated)
- [x] `victory_glow_overlay.png` — 960×540 · P2 (generated)
- [x] `level_1_barrio.png` — 240×135 · P3 · [ui_23](ui_23_level_cards.md) (generated)
- [x] `level_2_hospital.png` — 240×135 · P3 (generated)
- [x] `level_3_centro.png` — 240×135 · P3 (generated)
- [x] `level_4_laboratorio.png` — 240×135 · P3 (generated)
- [x] `icon_16.png` — 16×16 · P2 · [ui_24](ui_24_app_icon.md) (generated)
- [x] `icon_32.png` — 32×32 · P2 (generated)
- [x] `icon_256.png` — 256×256 · P2 (generated)
- [x] `cuarentena.ico` — 16/32/256 · P2 (generated)

Controls ([ui_18](ui_18_controls_screen.md)) and credits ([ui_19](ui_19_credits_screen.md)) reuse existing assets: nothing to draw.

---

## 8. Workshop evidence (item 3.2)

- [ ] Paper sketches photographed in `designs/evidence/sketches/`
- [x] Before/after images for every asset based on internet art (`designs/evidence/before_after/`) — generated by tools/evidence_build.py (19 images)
- [ ] Reference photos (Tunja, similar games) in `designs/evidence/references/`
- [x] `designs/evidence/attributions.md` filled in (fonts, art bases) — audio still to add when chosen
