extends WeaponBase
# 자동 조준 투사체. 레벨에 따라 발사 수/관통 증가.

const PROJECTILE := preload("res://scenes/projectile.tscn")

func _on_setup() -> void:
	weapon_name = "Magic Bolt"
	base_cooldown = 0.7

func _bolt_count() -> int:
	return [1, 1, 2, 2, 3][clampi(level - 1, 0, 4)]

func _pierce() -> int:
	return [1, 2, 2, 3, 3][clampi(level - 1, 0, 4)]

func _base_damage() -> float:
	return 12.0 + (level - 1) * 4.0

func _on_tick() -> void:
	var target: Node2D = _nearest_enemy(global_position, 700.0)
	if not target:
		return
	var base_dir: Vector2 = (target.global_position - global_position).normalized()
	var n: int = _bolt_count()
	# 여러 발이면 약간 부채꼴로
	for i in n:
		var spread: float = 0.0 if n == 1 else deg_to_rad(-12.0 + 24.0 * i / float(n - 1))
		_fire(base_dir.rotated(spread))

func _fire(dir: Vector2) -> void:
	var p: Node = PROJECTILE.instantiate()
	p.global_position = global_position
	p.direction = dir
	p.speed = 460.0
	p.pierce = _pierce()
	# 데미지/치명타를 미리 굴려 투사체에 주입
	var dmg: float = _base_damage()
	var crit: bool = false
	if player and player.has_method("roll_damage"):
		var rd: Array = player.roll_damage(_base_damage())
		dmg = rd[0]
		crit = rd[1]
	p.damage = dmg
	p.is_crit = crit
	get_tree().get_root().get_child(0).add_child(p)
