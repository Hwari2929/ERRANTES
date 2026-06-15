extends WeaponBase
# 주기적으로 좌/우로 휘두르는 근접 베기. 부채꼴 범위 내 적 전체 타격.

var _side: int = 1   # 1=오른쪽, -1=왼쪽
const ARC_RANGE := 150.0
const ARC_HALF_ANGLE := 0.85   # rad (~49도)

func _on_setup() -> void:
	weapon_name = "Slash Whip"
	base_cooldown = 1.1

func _base_damage() -> float:
	return 16.0 + (level - 1) * 6.0

func _range() -> float:
	return ARC_RANGE + (level - 1) * 18.0

func _on_tick() -> void:
	var facing := Vector2(_side, 0.0)
	for e in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(e):
			continue
		var to_e: Vector2 = e.global_position - global_position
		if to_e.length() > _range():
			continue
		if absf(facing.angle_to(to_e.normalized())) <= ARC_HALF_ANGLE:
			deal(e, _base_damage())
	_show_slash(facing)
	# 레벨 4+ 면 양쪽 동시
	if level >= 4:
		var back := Vector2(-_side, 0.0)
		for e in get_tree().get_nodes_in_group("enemy"):
			if not is_instance_valid(e):
				continue
			var to_e: Vector2 = e.global_position - global_position
			if to_e.length() <= _range() and abs(back.angle_to(to_e.normalized())) <= ARC_HALF_ANGLE:
				deal(e, _base_damage())
		_show_slash(back)
	_side *= -1

func _show_slash(facing: Vector2) -> void:
	# 부채꼴 시각 효과 (반투명, 짧게 사라짐)
	var poly := Polygon2D.new()
	var pts: PackedVector2Array = [Vector2.ZERO]
	var steps := 10
	var base_a: float = facing.angle()
	for i in steps + 1:
		var a: float = base_a - ARC_HALF_ANGLE + (2.0 * ARC_HALF_ANGLE) * i / float(steps)
		pts.append(Vector2(cos(a), sin(a)) * _range())
	poly.polygon = pts
	poly.color = Color(0.8, 0.9, 1.0, 0.35)
	poly.z_index = 4
	add_child(poly)
	var tw := poly.create_tween()
	tw.tween_property(poly, "modulate:a", 0.0, 0.22)
	tw.tween_callback(poly.queue_free)
