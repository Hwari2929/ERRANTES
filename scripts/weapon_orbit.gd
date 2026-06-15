extends WeaponBase
# 플레이어 주위를 도는 구슬. 닿는 적에게 지속 피해.

var _angle: float = 0.0
var _orbs: Array = []                  # Sprite2D 노드
var _hit_cd: Dictionary = {}           # enemy_id -> 남은 쿨다운
const ORBIT_RADIUS := 78.0
const ORB_HIT_RADIUS := 22.0
const HIT_INTERVAL := 0.45
const ROT_SPEED := 2.4                 # rad/s

func _on_setup() -> void:
	weapon_name = "Orbit Shards"
	base_cooldown = 9999.0   # 틱 타이머 미사용 (상시 회전)
	_rebuild_orbs()

func _orb_count() -> int:
	return [2, 2, 3, 4, 5][clampi(level - 1, 0, 4)]

func _base_damage() -> float:
	return 8.0 + (level - 1) * 3.0

func _on_level_up() -> void:
	_rebuild_orbs()

func _rebuild_orbs() -> void:
	for o in _orbs:
		if is_instance_valid(o):
			o.queue_free()
	_orbs.clear()
	var tex: Texture2D = null
	if ResourceLoader.exists("res://assets/sprites/projectile.png"):
		tex = load("res://assets/sprites/projectile.png")
	for i in _orb_count():
		var s := Sprite2D.new()
		s.texture = tex
		s.modulate = Color(0.5, 0.8, 1.0, 1.0)
		s.z_index = 5
		add_child(s)
		_orbs.append(s)

func _process(delta: float) -> void:
	_angle += ROT_SPEED * delta
	var n: int = _orbs.size()
	if n == 0:
		return
	# 구슬 배치
	for i in n:
		var a: float = _angle + TAU * i / float(n)
		_orbs[i].position = Vector2(cos(a), sin(a)) * ORBIT_RADIUS
	# 쿨다운 감소
	for k in _hit_cd.keys():
		_hit_cd[k] -= delta
	# 피해 판정
	for e in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(e):
			continue
		var eid: int = e.get_instance_id()
		if _hit_cd.get(eid, 0.0) > 0.0:
			continue
		for orb in _orbs:
			if orb.global_position.distance_to(e.global_position) <= ORB_HIT_RADIUS:
				deal(e, _base_damage())
				_hit_cd[eid] = HIT_INTERVAL
				break
