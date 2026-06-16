# Project Brief — VS Survivor

## What we are building
A top-down "vampire-survivors"-style survival action game in Godot 4. The player
moves with WASD, auto-attacks the nearest enemies, gains XP from kills, levels up to
pick weapon/stat upgrades, and survives escalating waves of enemies for as long as
possible. Pixel-art sprites are AI-generated (Flux 2 via ComfyUI).

## Tech stack
- Engine/runtime: Godot 4.6.x (gl_compatibility renderer for iOS/Xogot compatibility)
- Language: GDScript (typed)
- Assets: pixel-art PNGs under assets/sprites/ (nearest texture filter)
- Target: desktop + iOS via Xogot (project.godot at repo root, git, no LFS for small assets)

## Project tree (intended)
```
project.godot
scenes/    # *.tscn  (main, player, enemies, ui, upgrade_menu, projectiles)
scripts/   # *.gd    (one script per scene/entity; weapons; managers)
assets/sprites/
docs/      # project_brief.md, dev_guidelines.md
```

## Data & state
- Player stats live on the Player node (exported + runtime multipliers).
- Run state (wave/time/kills) lives on WaveManager; best score persisted to user://.
- Weapons are child nodes under Player/WeaponManager, created at runtime.
- Cross-node access via groups ("player", "enemy", "main_camera", "wave_manager")
  and signals, never hard absolute paths from unrelated nodes.

## Design direction (UI/UX)
- Dark field with grid background; HUD top-left (HP green, XP gold, timer/kills/wave).
- Level-up pauses the game and shows 3 random upgrade choices (weapons + perks).
- Damage numbers pop on hit; crits are larger and red.

## Pipeline & phases
1. Phase 1 — Core loop: move, auto-attack, enemies, waves, XP/level, game-over. (done)
2. Phase 2 — Depth: multiple weapons, traits, enemy variety, colored bars. (done)
3. Phase 3 — Content & polish: pickups/magnet, boss waves, weapon evolutions, audio.
4. Phase 4 — Balance & release prep: tuning, iOS verification via Xogot.
