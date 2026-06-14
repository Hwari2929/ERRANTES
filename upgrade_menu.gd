extends CanvasLayer

signal upgrade_chosen(upgrade_id: String)

@onready var vbox: VBoxContainer = $Panel/VBox
@onready var title_label: Label = $Panel/VBox/Title

const UPGRADES := [
	{"id": "speed",     "label": "⚡ Speed +20%",      "desc": "Move faster"},
	{"id": "max_hp",    "label": "❤️  Max HP +25",       "desc": "Gain max HP and heal"},
	{"id": "damage",    "label": "🗡️  Damage +30%",      "desc": "Projectile damage up"},
	{"id": "fire_rate", "label": "🔥 Fire Rate +25%",   "desc": "Shoot more often"},
	{"id": "pierce",    "label": "🎯 Pierce +1",         "desc": "Projectiles pass through"},
	{"id": "hp_regen",  "label": "💚 HP Regen",          "desc": "Restore 15 HP now"},
]

func _ready() -> void:
	visible = false

func show_menu() -> void:
	# 기존 버튼 제거 (Title만 남김)
	for child in vbox.get_children():
		if child != title_label:
			child.queue_free()

	# 3개 랜덤 선택
	var pool: Array = UPGRADES.duplicate()
	pool.shuffle()
	var picks: Array = pool.slice(0, 3)

	for up in picks:
		var btn := Button.new()
		btn.text = "%s\n%s" % [up["label"], up["desc"]]
		btn.custom_minimum_size = Vector2(360, 64)
		btn.theme_override_font_sizes = {"font_size": 18}
		var uid: String = up["id"]
		btn.pressed.connect(func(): _pick(uid))
		vbox.add_child(btn)

	visible = true
	get_tree().paused = true

func _pick(upgrade_id: String) -> void:
	get_tree().paused = false
	visible = false
	upgrade_chosen.emit(upgrade_id)
