extends "res://scripts/enemy.gd"
# 분열 적 — 사망 시 작은 적 여러 마리로 분열.

const SPLIT_SCENE := preload("res://scenes/enemy_fast.tscn")
@export var split_count: int = 3
@export var is_split_child: bool = false   # 분열로 생긴 자식은 또 분열하지 않음

func _ready() -> void:
	max_health = 50.0
	speed = 65.0
	damage = 12
	xp_reward = 22
	armor = 1.0
	sprite_base = "enemy_tank"
	sprite_count = 2
	tint = Color(0.5, 1.0, 0.5, 1.0)   # 녹색
	super._ready()
	if is_split_child:
		# 작은 분열체로 스케일 축소
		scale = Vector2(0.6, 0.6)

func _on_death() -> void:
	if is_split_child:
		return
	for i in split_count:
		var child: Node2D = SPLIT_SCENE.instantiate()
		get_parent().add_child(child)
		var offset := Vector2(randf_range(-30, 30), randf_range(-30, 30))
		child.global_position = global_position + offset
		# 분열 자식 표시 (enemy_fast엔 is_split_child 없지만 안전하게 setter)
		if "is_split_child" in child:
			child.is_split_child = true
		# wave_manager가 dead 시그널을 연결할 수 있도록 그룹/시그널은 자체 _ready에서 처리됨
		var wm: Node = get_tree().get_first_node_in_group("wave_manager")
		if wm and child.has_signal("dead"):
			child.dead.connect(wm._on_enemy_dead)
