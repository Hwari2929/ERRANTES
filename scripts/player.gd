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
	var dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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
	sprite.modulate.a = 0.4
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
	level_uped.emit(level)

func heal(amount: int) -> void:
	current_hp = mini(current_hp + amount, max_hp)
	hp_changed.emit(current_hp, max_hp)

# 업그레이드 적용
func apply_upgrade(upgrade_id: String) -> void:
	match upgrade_id:
		"speed":
			speed *= 1.20
		"max_hp":
			max_hp += 25
			heal(25)
		"damage":
			var w: Node = get_node_or_null("Weapon")
			if w:
				w.damage *= 1.30
		"fire_rate":
			var w: Node = get_node_or_null("Weapon")
			if w:
				var ft: Timer = w.get_node_or_null("FireTimer")
				if ft:
					ft.wait_time = maxf(0.15, ft.wait_time * 0.75)
		"pierce":
			var w: Node = get_node_or_null("Weapon")
			if w and w.has_method("add_pierce"):
				w.add_pierce(1)
		"hp_regen":
			heal(15)

func _on_inv_timeout() -> void:
	invincible = false
	sprite.modulate.a = 1.0
