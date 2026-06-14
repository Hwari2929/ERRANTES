extends Node

signal kill_count_changed(count: int)
signal survival_time_changed(seconds: float)
signal wave_changed(wave: int)

@export var enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var spawn_margin: float = 180.0
@export var base_interval: float = 1.6
@export var min_interval: float = 0.25

@onready var spawn_timer: Timer = $SpawnTimer

var current_wave: int = 1
var kill_count: int = 0
var survival_time: float = 0.0
var _active: bool = false

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

func _on_SpawnTimer_timeout() -> void:
	_do_spawn()

# Godot 4: Timer.timeout 연결은 _ready에서
func _ready() -> void:
	spawn_timer.timeout.connect(_do_spawn)

func _do_spawn() -> void:
	if not enemy_scene:
		return
	var count: int = mini(1 + current_wave / 2, 5)
	for i in count:
		_spawn_one()

func _spawn_one() -> void:
	# 웨이브 3 이후 10% 확률로 빠른 적 스폰
	var scene: PackedScene = enemy_scene
	if fast_enemy_scene and current_wave >= 3 and randf() < 0.15:
		scene = fast_enemy_scene

	var e: Node2D = scene.instantiate()
	get_parent().add_child(e)
	e.global_position = _edge_pos()
	if e.has_signal("dead"):
		e.dead.connect(_on_enemy_dead)

func _on_enemy_dead(_enemy: Node) -> void:
	kill_count += 1
	kill_count_changed.emit(kill_count)
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_method("add_xp"):
		player.add_xp(8 + current_wave * 2)

func _edge_pos() -> Vector2:
	# 플레이어 기준 화면 밖 랜덤 위치
	var cam: Camera2D = get_tree().get_first_node_in_group("main_camera")
	var center: Vector2 = Vector2(640, 360)
	if cam:
		center = cam.global_position
	var m: float = spawn_margin
	match randi() % 4:
		0: return center + Vector2(randf_range(-500, 500), -m - randf_range(0, 100))
		1: return center + Vector2(m + randf_range(0, 100), randf_range(-400, 400))
		2: return center + Vector2(randf_range(-500, 500), m + randf_range(0, 100))
		_: return center + Vector2(-m - randf_range(0, 100), randf_range(-400, 400))
