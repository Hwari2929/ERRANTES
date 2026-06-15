extends Label
class_name DamageNumber
# 데미지 숫자 팝업 — 생성 후 위로 뜨다 사라짐

var _font_size: int = 18
var _color: Color = Color(1.0, 0.85, 0.2, 1.0)

func _ready() -> void:
	add_theme_font_size_override("font_size", _font_size)
	add_theme_color_override("font_color", _color)
	z_index = 10
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position:y", position.y - 40.0, 0.8)
	tw.tween_property(self, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tw.chain().tween_callback(queue_free)

static func spawn(parent: Node, pos: Vector2, amount: float, is_crit: bool = false) -> void:
	var lbl := preload("res://scenes/damage_number.tscn").instantiate()
	lbl.text = str(int(round(amount)))
	if is_crit:
		lbl._font_size = 28
		lbl._color = Color(1.0, 0.3, 0.15, 1.0)
		lbl.text += "!"
	lbl.position = pos + Vector2(randf_range(-12, 12), -24)
	parent.add_child(lbl)
