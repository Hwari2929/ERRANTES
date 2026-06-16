# Development Guidelines (Coder reference)

Minimum safety rules. Every change MUST follow these. Many encode real bugs that
previously broke this project.

## Naming
- snake_case for vars/functions, PascalCase for class_name and node names.
- One script per entity; file name matches the entity (player.gd, enemy_fast.gd).
- Private helpers prefixed with `_`.

## Structure & reuse
- Prefer extending a base script over duplicating logic
  (enemy_fast.gd / enemy_tank.gd extend enemy.gd and only override stats/hooks).
- Cross-node references: use groups + signals, NOT absolute node paths from
  unrelated nodes. Player is in group "player"; enemies in "enemy";
  the camera in "main_camera"; the wave manager in "wave_manager".
- Weapons are added at runtime by WeaponManager; never hard-code weapon nodes.

## GDScript / Godot 4 patterns (REQUIRED)
- Type your locals. `var x := min(a, b)` infers Variant and triggers a warning that
  this project treats as an ERROR. Use explicit types: `var x: int = mini(a, b)`,
  and prefer typed math helpers (mini/maxi/maxf/minf) over min/max.
- Theme from code: use `add_theme_font_size_override("font_size", n)` and
  `add_theme_color_override(...)`. NEVER assign `theme_override_font_sizes[...]`
  or `theme_override_colors[...]` in code — those are inspector-only paths and
  cause "Identifier not declared" parse errors.
- Connect signals in `_ready()`. Match signal names EXACTLY between emitter and
  listener (a mismatched name silently fails to connect, then errors at runtime).
- Use `@onready` for node references; guard optional nodes with get_node_or_null.
- A `Sprite2D` with only `modulate` set and no `texture` renders nothing — always
  set a texture for visible sprites.
- Scripts that must be validated at import time need `class_name` OR must be
  attached to a scene that the smoke scene loads; otherwise parse errors only
  surface at runtime.

## Preservation (do not regress)
- player.gd MUST keep: signals (hp_changed, xp_changed, level_uped, died,
  stats_changed); the WeaponManager bootstrap `weapons.add_weapon("bolt")` in
  _ready; stat fields and all public methods (take_damage with armor, add_xp,
  _level_up, heal, roll_damage, apply_upgrade) and hp_regen in _process.
- When editing a central file, integrate new behavior into the existing flow;
  do not delete unrelated existing behavior.

## Must-not
- Do not change the renderer away from gl_compatibility (breaks iOS/Xogot).
- Do not introduce Variant-inference warnings (treated as errors here).
- Do not leave a node referenced by a scene without its script/texture.
