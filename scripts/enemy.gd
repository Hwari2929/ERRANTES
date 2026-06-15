extends CharacterBody2D

class_name Enemy

signal dead(enemy: Enemy)

@export var max_health: float = 30.0
@export var speed: float = 90.0
@export var damage: int = 10
@export var xp_reward: int = 10

# 스프라이트 변종: assets/sprites/{sprite_base}_{1..sprite_count}.png 중 랜덤 선택
@export var sprite_base: String = "enemy_basic"
@export var sprite_count: int = 3

@onready var health_bar: ProgressBar = $HealthBar

var current_health: float = 0.0
var _dead: bool = false

func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")
	health_bar.max_value = max_health
	health_bar.value = max_health
	_apply_random_sprite()

func _apply_random_sprite() -> void:
	if sprite_count <= 0 or not has_node("Sprite2D"):
		return
	var idx: int = randi_range(1, sprite_count)
	var path: String = "res://assets/sprites/%s_%d.png" % [sprite_base, idx]
	if ResourceLoader.exists(path):
		$Sprite2D.texture = load(path)

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
	DamageNumber.spawn(get_parent(), global_position, amount)
	if current_health <= 0.0:
		_die()

func _die() -> void:
	if _dead:
		return
	_dead = true
	dead.emit(self)
	queue_free()
