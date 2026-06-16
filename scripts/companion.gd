extends CharacterBody2D
# 동료 — 플레이어를 따라다니며 최근접 적을 자동 공격. 피격 시 사망 후 자동 리스폰.

const PROJECTILE := preload("res://scenes/projectile.tscn")

@export var max_health: float = 40.0
@export var speed: float = 240.0
@export var follow_dist: float = 64.0
@export var fire_cooldown: float = 1.0
@export var fire_range: float = 420.0
@export var attack_damage: float = 10.0
@export var respawn_cooldown: float = 6.0
@export var contact_dmg_interval: float = 0.7

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar

var current_health: float = 0.0
var alive: bool = true
var _fire_t: float = 0.0
var _respawn_t: float = 0.0
var _contact_t: float = 0.0

func _ready() -> void:
	add_to_group("companion")
	current_health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = max_health

func _physics_process(delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D

	if not alive:
		_respawn_t -= delta
		if _respawn_t <= 0.0:
			_respawn(player)
		return
	if not player:
		return

	# 추종
	var to_p: Vector2 = player.global_position - global_position
	velocity = to_p.normalized() * speed if to_p.length() > follow_dist else Vector2.ZERO
	move_and_slide()

	# 자동 공격
	_fire_t -= delta
	if _fire_t <= 0.0:
		var e: Node2D = _nearest_enemy()
		if e:
			_fire_t = fire_cooldown
			_shoot(e)

	# 접촉 피해(자체 관리)
	_contact_t -= delta
	if _contact_t <= 0.0:
		for en in get_tree().get_nodes_in_group("enemy"):
			if is_instance_valid(en) and global_position.distance_to(en.global_position) < 26.0:
				_contact_t = contact_dmg_interval
				var dmg: int = en.damage if "damage" in en else 8
				take_damage(float(dmg))
				break

func _nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_d: float = fire_range
	for e in get_tree().get_nodes_in_group("enemy"):
		var d: float = global_position.distance_to(e.global_position)
		if d < best_d:
			best_d = d; best = e
	return best

func _shoot(target: Node2D) -> void:
	var p: Node = PROJECTILE.instantiate()
	p.global_position = global_position
	p.direction = (target.global_position - global_position).normalized()
	p.speed = 440.0
	p.damage = attack_damage
	p.pierce = 1
	get_tree().get_root().get_child(0).add_child(p)

func take_damage(amount: float, _is_crit: bool = false) -> void:
	if not alive:
		return
	current_health -= amount
	if health_bar:
		health_bar.value = current_health
	if current_health <= 0.0:
		_die()

func _die() -> void:
	alive = false
	visible = false
	_respawn_t = respawn_cooldown

func _respawn(player: Node2D) -> void:
	alive = true
	visible = true
	current_health = max_health
	if health_bar:
		health_bar.value = current_health
	if player:
		global_position = player.global_position + Vector2(48, 0)
