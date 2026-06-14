extends "res://enemy.gd"
# 빠르고 약한 적 — enemy.gd 상속, 스탯만 변경

func _ready() -> void:
	max_health = 15.0
	speed = 180.0
	damage = 5
	xp_reward = 6
	super._ready()
	$Sprite2D.modulate = Color(1.0, 0.55, 0.1, 1.0)  # 주황 색상
