extends WeaponBase
# 노바 버스트 — 주기적으로 360도 방사형 탄막.

const PROJECTILE := preload("res://scenes/projectile.tscn")

func _on_setup() -> void:
	weapon_name = "Nova Burst"
	base_cooldown = 2.2

func _count() -> int:
	return [6, 8, 10, 12, 16][clampi(level - 1, 0, 4)]

func _base_damage() -> float:
	return 9.0 + (level - 1) * 3.0

func _on_tick() -> void:
	var n: int = _count()
	for i in n:
		var ang: float = TAU * i / float(n)
		_fire(Vector2(cos(ang), sin(ang)))

func _fire(dir: Vector2) -> void:
	var p: Node = PROJECTILE.instantiate()
	p.global_position = global_position
	p.direction = dir
	p.speed = 300.0
	p.pierce = 1
	var dmg: float = _base_damage()
	var crit: bool = false
	if player and player.has_method("roll_damage"):
		var rd: Array = player.roll_damage(_base_damage())
		dmg = rd[0]; crit = rd[1]
	p.damage = dmg
	p.is_crit = crit
	get_tree().get_root().get_child(0).add_child(p)
