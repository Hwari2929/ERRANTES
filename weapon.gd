extends Node2D

@export var damage: float = 15.0
@export var projectile_speed: float = 450.0
@export var projectile_scene: PackedScene

@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	fire_timer.timeout.connect(_on_fire)

func _on_fire() -> void:
	var target := _nearest_enemy()
	if not target:
		return
	var dir := (target.global_position - global_position).normalized()
	_spawn(dir)

func _nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemy")
	var best: Node2D = null
	var best_dist := INF
	for e in enemies:
		var d := global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best = e
	return best

func _spawn(dir: Vector2) -> void:
	if not projectile_scene:
		return
	var p = projectile_scene.instantiate()
	p.global_position = global_position
	p.direction = dir
	p.speed = projectile_speed
	p.damage = damage
	get_tree().get_root().get_child(0).add_child(p)
