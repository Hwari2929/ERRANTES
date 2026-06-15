extends CanvasLayer

signal upgrade_chosen(upgrade_id: String)

@onready var vbox: VBoxContainer = $Panel/VBox
@onready var title_label: Label = $Panel/VBox/Title

var player: Node = null

# 스탯/특성 풀
const PERKS := [
	{"id": "damage",       "label": "🗡️ Damage +20%",      "desc": "All weapon damage up"},
	{"id": "attack_speed", "label": "⏩ Attack Speed +18%", "desc": "Weapons fire faster"},
	{"id": "speed",        "label": "👟 Move Speed +15%",   "desc": "Move faster"},
	{"id": "max_hp",       "label": "❤️ Max HP +25",         "desc": "More max HP, heal 25"},
	{"id": "armor",        "label": "🛡️ Armor +2",          "desc": "Reduce damage taken"},
	{"id": "regen",        "label": "💚 Regen +0.6/s",       "desc": "Recover HP over time"},
	{"id": "crit",         "label": "🎯 Crit +6%",           "desc": "Higher crit chance"},
	{"id": "pickup",       "label": "🧲 Pickup +40",         "desc": "Larger XP pickup range"},
	{"id": "heal_now",     "label": "✨ Heal 40",            "desc": "Restore 40 HP now"},
]

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _build_pool() -> Array:
	var pool: Array = []
	# 무기 옵션 (보유 강화 + 신규)
	if player:
		var wm: Node = player.get_node_or_null("WeaponManager")
		if wm and wm.has_method("available_options"):
			pool += wm.available_options()
	# 특성 옵션
	pool += PERKS.duplicate()
	return pool

func show_menu() -> void:
	for child in vbox.get_children():
		if child != title_label:
			child.queue_free()

	var pool: Array = _build_pool()
	pool.shuffle()
	var picks: Array = pool.slice(0, 3)

	for up in picks:
		var btn := Button.new()
		btn.text = "%s\n%s" % [up["label"], up["desc"]]
		btn.custom_minimum_size = Vector2(380, 66)
		btn.add_theme_font_size_override("font_size", 18)
		var uid: String = up["id"]
		btn.pressed.connect(func(): _pick(uid))
		vbox.add_child(btn)

	visible = true
	get_tree().paused = true

func _pick(upgrade_id: String) -> void:
	get_tree().paused = false
	visible = false
	upgrade_chosen.emit(upgrade_id)
