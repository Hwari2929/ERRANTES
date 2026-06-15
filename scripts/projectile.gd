extends Area2D

@export var speed: float = 450.0
@export var damage: float = 15.0
@export var lifetime: float = 2.5
@export var pierce: int = 1

var direction: Vector2 = Vector2.RIGHT
var is_crit: bool = false
var _hits_left: int = 0

func _ready() -> void:
	_hits_left = pierce
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemy"):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage, is_crit)
	_hits_left -= 1
	if _hits_left <= 0:
		queue_free()
