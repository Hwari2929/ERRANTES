extends CharacterBody2D

signal hp_changed(current_hp: int, max_hp: int)
signal xp_changed(current_xp: int, xp_to_next: int)
signal level_uped(new_level: int)
signal died()

@export var speed: float = 200.0
@export var max_hp: int = 100
@export var xp_to_next_level: int = 100

@onready var inv_timer: Timer = $InvincibilityTimer
@onready var sprite: Sprite2D = $Sprite2D

var current_hp: int = 0
var current_xp: int = 0
var level: int = 1
var invincible: bool = false

func _ready() -> void:
	current_hp = max_hp
	add_to_group("player")
	inv_timer.timeout.connect(_on_inv_timeout)
	hp_changed.emit(current_hp, max_hp)

func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * speed
	move_and_slide()

func take_damage(amount: int) -> void:
	if invincible or current_hp <= 0:
		return
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		died.emit()
		queue_free()
		return
	invincible = true
	sprite.modulate.a = 0.5
	inv_timer.start()

func add_xp(amount: int) -> void:
	current_xp += amount
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		_level_up()
	xp_changed.emit(current_xp, xp_to_next_level)

func _level_up() -> void:
	level += 1
	xp_to_next_level = int(xp_to_next_level * 1.5)
	max_hp += 10
	current_hp = max_hp
	speed += 10.0
	level_uped.emit(level)
	hp_changed.emit(current_hp, max_hp)

func _on_inv_timeout() -> void:
	invincible = false
	sprite.modulate.a = 1.0
