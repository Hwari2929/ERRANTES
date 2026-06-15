extends WeaponBase
# 플레이어 주위 지속 피해 장판. 반경 내 모든 적에게 주기 피해.

var _field: Polygon2D

func _on_setup() -> void:
	weapon_name = "Burning Aura"
	base_cooldown = 0.6   # 틱 간격
	_make_field()

func _radius() -> float:
	return 90.0 + (level - 1) * 22.0

func _base_damage() -> float:
	return 5.0 + (level - 1) * 2.5

func _on_level_up() -> void:
	_make_field()

func _make_field() -> void:
	if _field and is_instance_valid(_field):
		_field.queue_free()
	_field = Polygon2D.new()
	var pts: PackedVector2Array = []
	var steps := 28
	for i in steps:
		var a: float = TAU * i / float(steps)
		pts.append(Vector2(cos(a), sin(a)) * _radius())
	_field.polygon = pts
	_field.color = Color(1.0, 0.4, 0.1, 0.13)
	_field.z_index = -1
	add_child(_field)

func _on_tick() -> void:
	var r: float = _radius()
	for e in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(e):
			continue
		if global_position.distance_to(e.global_position) <= r:
			deal(e, _base_damage())
