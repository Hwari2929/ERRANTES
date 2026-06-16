extends WeaponBase
# 스캐터 샷 — 최근접 적 방향으로 산탄(콘) 발사.

const PROJECTILE := preload("res://scenes/projectile.tscn")
const SPREAD_DEG := 42.0

func _on_setup() -> void:
	weapon_name = "Scatter Shot"
	base_cooldown = 1.3

func _count() -> int:
	return [3, 3, 4, 5, 6][clampi(level - 1, 0, 4)]

func _base_damage() -> float:
	return 8.0 + (level - 1) * 3.0

func _on_tick() -> void:
	var target: Node2D = _nearest_enemy(global_position, 620.0)
	if not target:
		return
	var base_dir: Vector2 = (target.global_position - global_position).normalized()
	var n: int = _count()
	for i in n:
		var off: float = 0.0 if n == 1 else deg_to_rad(-SPREAD_DEG / 2.0 + SPREAD_DEG * i / float(n - 1))
		_fire(base_dir.rotated(off))

func _fire(dir: Vector2) -> void:
	var p: Node = PROJECTILE.instantiate()
	p.global_position = global_position
	p.direction = dir
	p.speed = 480.0
	p.pierce = 1
	var dmg: float = _base_damage()
	var crit: bool = false
	if player and player.has_method("roll_damage"):
		var rd: Array = player.roll_damage(_base_damage())
		dmg = rd[0]; crit = rd[1]
	p.damage = dmg
	p.is_crit = crit
	get_tree().get_root().get_child(0).add_child(p)
