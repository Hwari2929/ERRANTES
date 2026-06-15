extends "res://scripts/enemy.gd"
# 원거리 적 — 일정 거리를 유지하며 플레이어에게 투사체 발사.

const PROJECTILE := preload("res://scenes/enemy_projectile.tscn")
const PREFERRED_DIST := 280.0
const FIRE_INTERVAL := 2.0

var _fire_accum: float = 0.0

func _ready() -> void:
	max_health = 22.0
	speed = 70.0
	damage = 8
	xp_reward = 18
	armor = 0.0
	sprite_base = "enemy_basic"
	sprite_count = 3
	tint = Color(0.6, 1.0, 0.6, 1.0)   # 녹색 틴트로 구분
	super._ready()

func _move(dir: Vector2, player: Node) -> void:
	var dist: float = global_position.distance_to(player.global_position)
	# 너무 가까우면 후퇴, 멀면 접근, 적정거리면 정지
	if dist < PREFERRED_DIST - 40.0:
		velocity = -dir * speed
	elif dist > PREFERRED_DIST + 40.0:
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _dead:
		return
	_fire_accum += delta
	if _fire_accum >= FIRE_INTERVAL:
		_fire_accum = 0.0
		_shoot()

func _shoot() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	var p: Node = PROJECTILE.instantiate()
	p.global_position = global_position
	p.direction = (player.global_position - global_position).normalized()
	p.damage = damage
	get_parent().add_child(p)
