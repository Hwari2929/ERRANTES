extends CanvasLayer

@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HPBar
@onready var timer_label: Label = $MarginContainer/VBoxContainer/TimerLabel
@onready var kill_label: Label = $MarginContainer/VBoxContainer/KillLabel
@onready var wave_label: Label = $MarginContainer/VBoxContainer/WaveLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var final_time_label: Label = $GameOverPanel/VBox/FinalTimeLabel
@onready var final_kills_label: Label = $GameOverPanel/VBox/FinalKillsLabel
@onready var restart_btn: Button = $GameOverPanel/VBox/RestartButton

signal restart_pressed()

func _ready() -> void:
	game_over_panel.visible = false

func update_hp(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current

func update_timer(seconds: float) -> void:
	var m := int(seconds / 60)
	var s := int(seconds) % 60
	timer_label.text = "TIME  %02d:%02d" % [m, s]

func update_kills(count: int) -> void:
	kill_label.text = "KILLS  %d" % count

func update_wave(wave: int) -> void:
	wave_label.text = "WAVE  %d" % wave

func show_game_over(time: float, kills: int) -> void:
	var m := int(time / 60)
	var s := int(time) % 60
	final_time_label.text = "Survived  %02d:%02d" % [m, s]
	final_kills_label.text = "Kills  %d" % kills
	game_over_panel.visible = true
	restart_btn.pressed.connect(func(): restart_pressed.emit(), CONNECT_ONE_SHOT)
