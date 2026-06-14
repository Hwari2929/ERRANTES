extends CharacterBody2D

class_name Enemy

signal dead(enemy: Enemy)

@export var max_health: float = 30.0
@export var speed: float = 90.0
@export var damage: int = 10
@export var xp_reward: int = 10

@onready var health_bar: ProgressBar = $HealthBar

var current_health: float = 0.0
var _dead: bool = false

func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")
	health_bar.max_value = max_health
	health_bar.value = max_health

func _physics_process(_delta: float) -> void:
	if _dead:
		return
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
	var dir: Vector2 = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	if has_node("Sprite2D"):
		$Sprite2D.flip_h = dir.x < 0

func take_damage(amount: float) -> void:
	if _dead:
		return
	current_health -= amount
	health_bar.value = current_health
	# 데미지 숫자 팝업
	var dn_scene: PackedScene = load("res://damage_number.tscn")
	if dn_scene:
		var dn: Node = dn_scene.instantiate()
		dn.get_script().call("spawn", get_parent(), global_position, amount) if false else _spawn_dmg(amount)
	if current_health <= 0.0:
		_die()

func _spawn_dmg(amount: float) -> void:
	var lbl := Label.new()
	lbl.text = str(int(amount))
	lbl.position = global_position + Vector2(randf_range(-12, 12), -28)
	lbl.z_index = 10
	lbl.theme_override_font_sizes["font_size"] = 18
	lbl.theme_override_colors["font_color"] = Color(1.0, 0.9, 0.2, 1.0)
	get_parent().add_child(lbl)
	var tw: Tween = lbl.create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 38.0, 0.75)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.75).set_delay(0.25)
	tw.chain().tween_callback(lbl.queue_free)

func _die() -> void:
	if _dead:
		return
	_dead = true
	dead.emit(self)
	queue_free()
