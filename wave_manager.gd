extends Node

signal kill_count_changed(count: int)
signal survival_time_changed(seconds: float)
signal wave_changed(wave: int)

@export var enemy_scene: PackedScene
@export var spawn_margin: float = 120.0
@export var base_interval: float = 1.8
@export var min_interval: float = 0.3

@onready var spawn_timer: Timer = $SpawnTimer

var current_wave: int = 1
var kill_count: int = 0
var survival_time: float = 0.0
var _active: bool = false
var _viewport_size: Vector2

func _ready() -> void:
	_viewport_size = get_viewport().get_visible_rect().size
	spawn_timer.timeout.connect(_on_spawn)

func _process(delta: float) -> void:
	if not _active:
		return
	survival_time += delta
	survival_time_changed.emit(survival_time)
	# 웨이브는 30초마다 증가
	var new_wave: int = int(survival_time / 30.0) + 1
	if new_wave != current_wave:
		current_wave = new_wave
		wave_changed.emit(current_wave)
		# 웨이브 오를수록 스폰 빨라짐
		spawn_timer.wait_time = max(min_interval, base_interval - (current_wave - 1) * 0.15)

func start_waves() -> void:
	_active = true
	spawn_timer.wait_time = base_interval
	spawn_timer.start()

func stop_waves() -> void:
	_active = false
	spawn_timer.stop()

func _on_spawn() -> void:
	if not enemy_scene:
		return
	# 한 번에 스폰 수 = 웨이브에 비례
	var count: int = mini(current_wave, 4)
	for i in count:
		_spawn_one()

func _spawn_one() -> void:
	var e: Node2D = enemy_scene.instantiate()
	get_parent().add_child(e)
	e.global_position = _random_edge_pos()
	# 사망 시그널 연결
	if e.has_signal("dead"):
		e.dead.connect(_on_enemy_dead)

func _on_enemy_dead(enemy: Node) -> void:
	kill_count += 1
	kill_count_changed.emit(kill_count)
	# 플레이어 XP 지급
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_method("add_xp"):
		player.add_xp(10)

func _random_edge_pos() -> Vector2:
	var m: float = spawn_margin
	var w: float = _viewport_size.x
	var h: float = _viewport_size.y
	match randi() % 4:
		0: return Vector2(randf_range(0, w), -m)
		1: return Vector2(w + m, randf_range(0, h))
		2: return Vector2(randf_range(0, w), h + m)
		_: return Vector2(-m, randf_range(0, h))
