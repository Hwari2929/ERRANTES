extends "res://scripts/enemy.gd"
# 느리고 체력 많은 탱커

func _ready() -> void:
	max_health = 120.0
	speed = 45.0
	damage = 25
	xp_reward = 30
	sprite_base = "enemy_tank"
	sprite_count = 2
	super._ready()
