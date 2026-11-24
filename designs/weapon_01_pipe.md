# weapon_01 — Tubo (Metal pipe)

| Field | Value |
|---|---|
| Priority | **P1** |
| Stats | Melee, damage U(8,12), p_crit 0.10, cooldown 0.5 s, infinite. Starting weapon |
| In-game name | "Tubo" |
| Output folder | `juego/assets/sprites/weapons/` |

## Files

| File | Size | Description |
|---|---|---|
| `pipe_hud.png` | **48×24** | HUD weapon panel icon, diagonal (bottom-left → top-right): rusty grey metal pipe (`N5`/`N7`, `A0` rust spots), wrapped with white medical tape on the grip (`N8`) |
| `pipe_world.png` | 32×16 | Lying on the floor (not needed for the starting weapon, but used for the controls screen and pickups) |

**The in-hand version is drawn inside Elena's attack frames** (`char_01`).

## Rules shared by every weapon

- HUD icon 48×24, object diagonal, 1 px `N0` outline, no background.
- The 4 weapons must have clearly different silhouettes: long bar / fat cylinder / pistol / thin syringe.

## Acceptance checklist

- [ ] 2 PNGs
