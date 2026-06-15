extends Node

signal kill_count_changed(count: int)
signal survival_time_changed(seconds: float)
signal wave_changed(wave: int)

@export var enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var tank_enemy_scene: PackedScene
@export var shooter_enemy_scene: PackedScene
@export var splitter_enemy_scene: PackedScene
@export var spawn_margin: float = 180.0
@export var base_interval: float = 1.6
@export var min_interval: float = 0.22

@onready var spawn_timer: Timer = $SpawnTimer

var current_wave: int = 1
var kill_count: int = 0
var survival_time: float = 0.0
var _active: bool = false

func _ready() -> void:
	add_to_group("wave_manager")
	spawn_timer.timeout.connect(_do_spawn)

func _process(delta: float) -> void:
	if not _active:
		return
	survival_time += delta
	survival_time_changed.emit(survival_time)
	var new_wave: int = int(survival_time / 30.0) + 1
	if new_wave != current_wave:
		current_wave = new_wave
		wave_changed.emit(current_wave)
		spawn_timer.wait_time = maxf(min_interval, base_interval - (current_wave - 1) * 0.12)

func start_waves() -> void:
	_active = true
	spawn_timer.wait_time = base_interval
	spawn_timer.start()

func stop_waves() -> void:
	_active = false
	spawn_timer.stop()

func _do_spawn() -> void:
	if not enemy_scene:
		return
	var count: int = mini(1 + current_wave / 2, 6)
	for i in count:
		_spawn_one()

func _pick_scene() -> PackedScene:
	# 웨이브에 따라 가중치를 둔 스폰 풀
	var pool: Array = []
	pool.append([enemy_scene, 10])
	if fast_enemy_scene and current_wave >= 2:
		pool.append([fast_enemy_scene, 5 + current_wave])
	if shooter_enemy_scene and current_wave >= 4:
		pool.append([shooter_enemy_scene, 3 + current_wave])
	if tank_enemy_scene and current_wave >= 5:
		pool.append([tank_enemy_scene, 2 + current_wave / 2])
	if splitter_enemy_scene and current_wave >= 6:
		pool.append([splitter_enemy_scene, 2 + current_wave / 2])

	var total: int = 0
	for entry in pool:
		total += entry[1]
	var r: int = randi() % total
	for entry in pool:
		r -= entry[1]
		if r < 0:
			return entry[0]
	return enemy_scene

func _spawn_one() -> void:
	var scene: PackedScene = _pick_scene()
	var e: Node2D = scene.instantiate()
	get_parent().add_child(e)
	e.global_position = _edge_pos()
	if e.has_signal("dead"):
		e.dead.connect(_on_enemy_dead)

func _on_enemy_dead(enemy: Node) -> void:
	kill_count += 1
	kill_count_changed.emit(kill_count)
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_method("add_xp"):
		var reward: int = 8 + current_wave * 2
		if is_instance_valid(enemy) and "xp_reward" in enemy:
			reward = enemy.xp_reward
		player.add_xp(reward)

func _edge_pos() -> Vector2:
	var cam: Camera2D = get_tree().get_first_node_in_group("main_camera") as Camera2D
	var center: Vector2 = Vector2(640.0, 360.0)
	if cam:
		center = cam.global_position
	var m: float = spawn_margin
	match randi() % 4:
		0: return center + Vector2(randf_range(-500.0, 500.0), -m - randf_range(0.0, 80.0))
		1: return center + Vector2(m + randf_range(0.0, 80.0), randf_range(-380.0, 380.0))
		2: return center + Vector2(randf_range(-500.0, 500.0), m + randf_range(0.0, 80.0))
		_: return center + Vector2(-m - randf_range(0.0, 80.0), randf_range(-380.0, 380.0))
