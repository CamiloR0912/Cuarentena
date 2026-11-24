# char_08 — Hospital staff (queue servers)

| Field | Value |
|---|---|
| Priority | **P1** |
| Category | NPC |
| Used in | Level 2 (Hospital San Rafael) |
| Simulation model | M/M/c queue — each open stretcher = one server *c* attended by one staff member |
| Output folder | `juego/assets/sprites/npc/staff/` |
| Cell size | 32×32 px |
| Pivot (feet) | (16, 30) |
| Facings | down, up, right |

## Visual description

- 2 variants, so a row of open stretchers doesn't look cloned:

| Variant | Description | Key colors |
|---|---|---|
| A `nurse` | Nurse in clinical-blue scrubs, cap, N95 mask | `C1`/`C0`, `N8` mask |
| B `doctor` | Older doctor with grey hair, white coat, glasses | `N8`/`N7` coat, `N6` hair, `C1` scrubs |

- Tired but working. They stand **next to a stretcher**, facing it.
- Both wear full masks (they are the "safe" color group: blue/white).

## Animations (per variant)

| File | Frames | FPS | Loop | Rows | Notes |
|---|---|---|---|---|---|
| `staff_<v>_idle.png` | 2 | 3 | yes | 3 | Stretcher open but empty (server idle) |
| `staff_<v>_treat.png` | 4 | 6 | yes | 2 (up, right) | Working over the patient: checking, bandaging, injecting. Server busy |
| `staff_<v>_walk.png` | 4 | 8 | yes | 3 | Only for walking to a newly opened stretcher |

When a stretcher is **closed** the staff member is not drawn (or stands in the break area using idle).

### Sheet sizes

| File | Size |
|---|---|
| idle | 64×96 |
| treat | 128×64 |
| walk | 128×96 |

## Acceptance checklist

- [ ] Sketches at `designs/evidence/sketches/staff_<v>.jpg`
- [ ] 3 PNGs × 2 variants
- [ ] "Idle" vs "treating" is clear from a distance (shows server utilization ρ visually)
