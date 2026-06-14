extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var wave_manager: Node = $WaveManager
@onready var ui: CanvasLayer = $UI

var _game_over: bool = false

func _ready() -> void:
	# Player → UI HP
	player.hp_changed.connect(ui.update_hp)
	player.died.connect(_on_player_died)

	# WaveManager → UI
	wave_manager.kill_count_changed.connect(ui.update_kills)
	wave_manager.survival_time_changed.connect(ui.update_timer)
	wave_manager.wave_changed.connect(ui.update_wave)

	# UI restart
	ui.restart_pressed.connect(_on_restart)

	# Weapon에 투사체 씬 연결
	var weapon := player.get_node_or_null("Weapon")
	if weapon:
		weapon.projectile_scene = load("res://projectile.tscn")

	# 웨이브 시작
	wave_manager.start_waves()

func _on_player_died() -> void:
	if _game_over:
		return
	_game_over = true
	wave_manager.stop_waves()
	ui.show_game_over(wave_manager.survival_time, wave_manager.kill_count)

func _on_restart() -> void:
	get_tree().reload_current_scene()
