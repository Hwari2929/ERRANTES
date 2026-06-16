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
var _prev_hp: int = 0
var damage_vignette: ColorRect

func _ready() -> void:
	game_over_panel.visible = false
	levelup_label.visible = false
	_style_bar(hp_bar, Color(0.16, 0.85, 0.36), Color(0.5, 0.08, 0.08))
	_style_bar(xp_bar, Color(1.0, 0.82, 0.22), Color(0.18, 0.14, 0.05))
	_load_best()
	
	# Setup damage vignette
	damage_vignette = ColorRect.new()
	damage_vignette.name = "DamageVignette"
	damage_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_vignette.anchors_preset = Control.PRESET_FULL_RECT
	damage_vignette.modulate = Color(1.0, 0.0, 0.0, 0.0)
	add_child(damage_vignette)

func _style_bar(bar: ProgressBar, fill: Color, bg: Color) -> void:
	var bg_box: StyleBoxFlat = StyleBoxFlat.new()
	bg_box.bg_color = bg
	bg_box.set_corner_radius_all(3)
	bg_box.border_color = Color(0, 0, 0, 0.6)
	bg_box.set_border_width_all(1)
	var fill_box: StyleBoxFlat = StyleBoxFlat.new()
	fill_box.bg_color = fill
	fill_box.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg_box)
	bar.add_theme_stylebox_override("fill", fill_box)

func update_hp(current: int, maximum: int) -> void:
	_prev_hp = int(hp_bar.value)
	hp_bar.max_value = maximum
	hp_bar.value = current
	
	if current < _prev_hp:
		flash_damage()
	
	var ratio: float = float(current) / maxf(1.0, float(maximum))
	var fill: Color = Color(0.16, 0.85, 0.36) if ratio > 0.3 else Color(0.9, 0.25, 0.2)
	var fb: StyleBoxFlat = hp_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if fb:
		fb.bg_color = fill

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
		var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if f:
			f.store_float(time)
			f.store_32(kills)
			f.close()
	return is_new

func _load_best() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		_best_time = f.get_float()
		_best_kills = f.get_32()
		f.close()

func flash_damage() -> void:
	if not damage_vignette:
		return
	damage_vignette.modulate.a = 0.35
	var tween: Tween = create_tween()
	tween.tween_property(damage_vignette, "modulate:a", 0.0, 0.4)