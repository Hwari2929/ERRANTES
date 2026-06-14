extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var wave_manager: Node = $WaveManager
@onready var ui: CanvasLayer = $UI
@onready var upgrade_menu: CanvasLayer = $UpgradeMenu
@onready var camera: Camera2D = $Camera2D

var _game_over: bool = false
# 적 접촉 데미지 쿨다운 (적별로 추적)
var _enemy_hit_cooldown: Dictionary = {}
const CONTACT_DAMAGE_INTERVAL := 0.8

func _ready() -> void:
	# Player 시그널
	player.hp_changed.connect(ui.update_hp)
	player.died.connect(_on_player_died)
	player.level_uped.connect(_on_level_up)

	# WaveManager 시그널
	wave_manager.kill_count_changed.connect(ui.update_kills)
	wave_manager.survival_time_changed.connect(ui.update_timer)
	wave_manager.wave_changed.connect(_on_wave_changed)

	# 업그레이드 메뉴
	upgrade_menu.upgrade_chosen.connect(_on_upgrade_chosen)

	# UI restart
	ui.restart_pressed.connect(_on_restart)

	# 씬 주입
	var weapon: Node = player.get_node_or_null("Weapon")
	if weapon:
		weapon.projectile_scene = load("res://projectile.tscn")

	wave_manager.enemy_scene = load("res://enemy.tscn")
	wave_manager.fast_enemy_scene = load("res://enemy_fast.tscn")
	wave_manager.tank_enemy_scene = load("res://enemy_tank.tscn")

	camera.add_to_group("main_camera")
	wave_manager.start_waves()

func _process(delta: float) -> void:
	if _game_over:
		return
	if is_instance_valid(player):
		camera.global_position = camera.global_position.lerp(player.global_position, 8.0 * delta)
	_check_contact_damage(delta)

func _check_contact_damage(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var dist: float = player.global_position.distance_to(e.global_position)
		if dist < 28.0:
			var uid: int = e.get_instance_id()
			_enemy_hit_cooldown[uid] = _enemy_hit_cooldown.get(uid, 0.0) - delta
			if _enemy_hit_cooldown.get(uid, 0.0) <= 0.0:
				_enemy_hit_cooldown[uid] = CONTACT_DAMAGE_INTERVAL
				if e.has_method("damage"):
					player.take_damage(e.damage)
				else:
					player.take_damage(10)

func _on_player_died() -> void:
	if _game_over:
		return
	_game_over = true
	wave_manager.stop_waves()
	ui.show_game_over(wave_manager.survival_time, wave_manager.kill_count)

func _on_level_up(new_level: int) -> void:
	ui.show_level_up(new_level)
	upgrade_menu.show_menu()

func _on_upgrade_chosen(upgrade_id: String) -> void:
	player.apply_upgrade(upgrade_id)

func _on_wave_changed(wave: int) -> void:
	ui.update_wave(wave)

func _on_restart() -> void:
	_enemy_hit_cooldown.clear()
	get_tree().reload_current_scene()
