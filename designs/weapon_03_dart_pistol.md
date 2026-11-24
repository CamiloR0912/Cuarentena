# weapon_03 — Pistola de dardos (Veterinary dart pistol)

| Field | Value |
|---|---|
| Priority | **P1** |
| Stats | Ranged, damage N(15,3), p_crit 0.15, cooldown 1.2 s, limited ammo |
| In-game name | "Pistola de dardos" |
| Output folder | `juego/assets/sprites/weapons/` |

## Files

| File | Size | Description |
|---|---|---|
| `dart_pistol_hud.png` | 48×24 | CO₂ veterinary tranquilizer pistol: long thin barrel, grey body (`N5`/`N4`), **amber/orange grip and tip** (`A1`) so it never reads as a firearm. Small CO₂ cartridge |
| `dart_pistol_world.png` | 32×16 | Lying on the floor |

Projectile = `vfx_05`. In-hand version inside `char_01`.

## Acceptance checklist

- [ ] 2 PNGs
- [ ] Does not look like a real handgun (amber colors, veterinary shape)
