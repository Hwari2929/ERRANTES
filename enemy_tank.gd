extends "res://enemy.gd"
# 느리고 체력 많은 탱커

func _ready() -> void:
	max_health = 120.0
	speed = 45.0
	damage = 25
	xp_reward = 30
	super._ready()
	$Sprite2D.modulate = Color(0.6, 0.2, 1.0, 1.0)  # 보라색
	# 크기 키우기
	scale = Vector2(1.6, 1.6)
