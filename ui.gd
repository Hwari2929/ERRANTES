extends CanvasLayer

@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HPBar
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var timer_label: Label = $MarginContainer/VBoxContainer/TimerLabel
@onready var kill_label: Label = $MarginContainer/VBoxContainer/KillLabel
@onready var wave_label: Label = $MarginContainer/VBoxContainer/WaveLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var final_time_label: Label = $GameOverPanel/VBox/FinalTimeLabel
@onready var final_kills_label: Label = $GameOverPanel/VBox/FinalKillsLabel
@onready var best_label: Label = $GameOverPanel/VBox/BestLabel
@onready var restart_btn: Button = $GameOverPanel/VBox/RestartButton
@onready var levelup_label: Label = $LevelUpLabel

signal restart_pressed()

const SAVE_PATH := "user://best_score.dat"
var _levelup_tween: Tween
var _best_time: float = 0.0
var _best_kills: int = 0

func _ready() -> void:
	game_over_panel.visible = false
	levelup_label.visible = false
	_load_best()

func update_hp(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current

func update_xp(current: int, maximum: int) -> void:
	xp_bar.max_value = maximum
	xp_bar.value = current

func update_timer(seconds: float) -> void:
	var m: int = int(seconds / 60)
	var s: int = int(seconds) % 60
	timer_label.text = "TIME  %02d:%02d" % [m, s]

func update_kills(count: int) -> void:
	kill_label.text = "KILLS  %d" % count

func update_wave(wave: int) -> void:
	wave_label.text = "WAVE  %d" % wave

func show_level_up(new_level: int) -> void:
	level_label.text = "LV %d" % new_level
	levelup_label.text = "LEVEL UP!  LV %d" % new_level
	levelup_label.visible = true
	levelup_label.modulate.a = 1.0
	if _levelup_tween:
		_levelup_tween.kill()
	_levelup_tween = create_tween()
	_levelup_tween.tween_property(levelup_label, "modulate:a", 0.0, 1.8).set_delay(0.8)
	_levelup_tween.tween_callback(func(): levelup_label.visible = false)

func show_game_over(time: float, kills: int) -> void:
	var is_best: bool = _save_best(time, kills)
	var m: int = int(time / 60)
	var s: int = int(time) % 60
	final_time_label.text = "Survived  %02d:%02d" % [m, s]
	final_kills_label.text = "Kills  %d" % kills
	var bm: int = int(_best_time / 60)
	var bs: int = int(_best_time) % 60
	best_label.text = "Best  %02d:%02d  /  %d kills%s" % [bm, bs, _best_kills, "  🏆 NEW!" if is_best else ""]
	game_over_panel.visible = true
	restart_btn.pressed.connect(func(): restart_pressed.emit(), CONNECT_ONE_SHOT)

func _save_best(time: float, kills: int) -> bool:
	var is_new: bool = time > _best_time or (time == _best_time and kills > _best_kills)
	if is_new:
		_best_time = time
		_best_kills = kills
		var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if f:
			f.store_float(time)
			f.store_32(kills)
			f.close()
	return is_new

func _load_best() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		_best_time = f.get_float()
		_best_kills = f.get_32()
		f.close()
