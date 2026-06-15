extends Area2D
# 원거리 적이 발사하는 투사체. 플레이어에 닿으면 피해.

@export var speed: float = 230.0
@export var damage: int = 8
@export var lifetime: float = 4.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
