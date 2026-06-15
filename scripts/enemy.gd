extends CharacterBody2D

class_name Enemy

signal dead(enemy: Enemy)

@export var max_health: float = 30.0
@export var speed: float = 90.0
@export var damage: int = 10
@export var xp_reward: int = 10
@export var armor: float = 0.0          # 받는 피해 플랫 감소

# 스프라이트 변종: assets/sprites/{sprite_base}_{1..sprite_count}.png 중 랜덤 선택
@export var sprite_base: String = "enemy_basic"
@export var sprite_count: int = 3
@export var tint: Color = Color(1, 1, 1, 1)   # 특수 적 구분용 틴트

@onready var health_bar: ProgressBar = $HealthBar

var current_health: float = 0.0
var _dead: bool = false
var _flash_tween: Tween

func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")
	health_bar.max_value = max_health
	health_bar.value = max_health
	_apply_random_sprite()
	if has_node("Sprite2D"):
		$Sprite2D.modulate = tint

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
	_move(dir, player)
	if has_node("Sprite2D"):
		$Sprite2D.flip_h = dir.x < 0

# 하위 클래스가 이동 패턴을 오버라이드 (기본: 직진 추적)
func _move(dir: Vector2, _player: Node) -> void:
	velocity = dir * speed
	move_and_slide()

func take_damage(amount: float, is_crit: bool = false) -> void:
	if _dead:
		return
	var dealt: float = maxf(1.0, amount - armor)
	current_health -= dealt
	health_bar.value = current_health
	DamageNumber.spawn(get_parent(), global_position, dealt, is_crit)
	_hit_flash()
	if current_health <= 0.0:
		_die()

func _hit_flash() -> void:
	if not has_node("Sprite2D"):
		return
	var spr: Sprite2D = $Sprite2D
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	spr.modulate = Color(1.6, 1.6, 1.6, 1.0)
	_flash_tween = spr.create_tween()
	_flash_tween.tween_property(spr, "modulate", tint, 0.12)

func _die() -> void:
	if _dead:
		return
	_dead = true
	_on_death()
	dead.emit(self)
	queue_free()

# 하위 클래스 사망 훅 (분열 등)
func _on_death() -> void:
	pass
