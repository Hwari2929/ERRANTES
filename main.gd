extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var wave_manager: Node = $WaveManager
@onready var ui: CanvasLayer = $UI
@onready var camera: Camera2D = $Camera2D

var _game_over: bool = false

func _ready() -> void:
	# Player 시그널
	player.hp_changed.connect(ui.update_hp)
	player.died.connect(_on_player_died)
	player.level_uped.connect(_on_level_up)

	# WaveManager 시그널
	wave_manager.kill_count_changed.connect(ui.update_kills)
	wave_manager.survival_time_changed.connect(ui.update_timer)
	wave_manager.wave_changed.connect(_on_wave_changed)

	# UI restart
	ui.restart_pressed.connect(_on_restart)

	# Weapon 투사체 씬 주입
	var weapon: Node = player.get_node_or_null("Weapon")
	if weapon:
		weapon.projectile_scene = load("res://projectile.tscn")

	# WaveManager에 enemy 씬 주입
	wave_manager.enemy_scene = load("res://enemy.tscn")
	wave_manager.fast_enemy_scene = load("res://enemy_fast.tscn")

	# 카메라 그룹 등록 (wave_manager 스폰 위치 계산용)
	camera.add_to_group("main_camera")

	wave_manager.start_waves()

func _process(_delta: float) -> void:
	if not _game_over and is_instance_valid(player):
		camera.global_position = player.global_position

func _on_player_died() -> void:
	if _game_over:
		return
	_game_over = true
	wave_manager.stop_waves()
	ui.show_game_over(wave_manager.survival_time, wave_manager.kill_count)

func _on_level_up(new_level: int) -> void:
	ui.show_level_up(new_level)

func _on_wave_changed(wave: int) -> void:
	ui.update_wave(wave)

func _on_restart() -> void:
	get_tree().reload_current_scene()
