extends "res://scripts/enemy.gd"
# 빠르고 약한 적 — enemy.gd 상속, 스탯만 변경

func _ready() -> void:
	max_health = 15.0
	speed = 180.0
	damage = 5
	xp_reward = 6
	sprite_base = "enemy_fast"
	sprite_count = 3
	super._ready()
