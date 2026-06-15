extends Node2D

@export var damage: float = 15.0
@export var projectile_speed: float = 450.0
@export var projectile_pierce: int = 1
@export var projectile_scene: PackedScene

@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	fire_timer.timeout.connect(_on_fire)

func add_pierce(amount: int) -> void:
	projectile_pierce += amount

func _on_fire() -> void:
	var target: Node2D = _nearest_enemy()
	if not target:
		return
	var dir: Vector2 = (target.global_position - global_position).normalized()
	_spawn(dir)

func _nearest_enemy() -> Node2D:
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	var best: Node2D = null
	var best_dist: float = INF
	for e in enemies:
		var d: float = global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best = e
	return best

func _spawn(dir: Vector2) -> void:
	if not projectile_scene:
		return
	var p: Node = projectile_scene.instantiate()
	p.global_position = global_position
	p.direction = dir
	p.speed = projectile_speed
	p.damage = damage
	p.pierce = projectile_pierce
	get_tree().get_root().get_child(0).add_child(p)
