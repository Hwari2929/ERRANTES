extends Node2D
# 플레이어의 무기들을 보유/관리. 레벨업 메뉴가 무기 추가·강화를 요청한다.

const WEAPON_SCRIPTS := {
	"bolt":  "res://scripts/weapon_bolt.gd",
	"orbit": "res://scripts/weapon_orbit.gd",
	"whip":  "res://scripts/weapon_whip.gd",
	"aura":  "res://scripts/weapon_aura.gd",
}

const WEAPON_NAMES := {
	"bolt":  "🔫 Magic Bolt",
	"orbit": "🔵 Orbit Shards",
	"whip":  "🌀 Slash Whip",
	"aura":  "🔥 Burning Aura",
}

var _weapons: Dictionary = {}   # id -> WeaponBase

func _get_player() -> Node:
	return get_parent()

func add_weapon(id: String) -> void:
	if id in _weapons or id not in WEAPON_SCRIPTS:
		return
	var scr = load(WEAPON_SCRIPTS[id])
	var w: Node2D = Node2D.new()
	w.set_script(scr)
	add_child(w)
	w.setup(_get_player())
	_weapons[id] = w

func add_or_upgrade(id: String) -> void:
	if id in _weapons:
		_weapons[id].level_up()
	else:
		add_weapon(id)

func has_weapon(id: String) -> bool:
	return id in _weapons

func weapon_level(id: String) -> int:
	return _weapons[id].level if id in _weapons else 0

func is_maxed(id: String) -> bool:
	return id in _weapons and _weapons[id].is_maxed()

func owned_summary() -> Array:
	var out: Array = []
	for id in _weapons:
		out.append("%s Lv%d" % [WEAPON_NAMES.get(id, id), _weapons[id].level])
	return out

func refresh_cooldowns() -> void:
	for w in _weapons.values():
		if w.has_method("_refresh_cooldown"):
			w._refresh_cooldown()

# 레벨업 메뉴에 제시할 무기 옵션 (미보유 또는 강화가능)
func available_options() -> Array:
	var opts: Array = []
	for id in WEAPON_SCRIPTS:
		if id not in _weapons:
			opts.append({"id": "weapon:" + id,
				"label": WEAPON_NAMES[id] + " (NEW)",
				"desc": "Acquire a new weapon"})
		elif not _weapons[id].is_maxed():
			opts.append({"id": "weapon:" + id,
				"label": WEAPON_NAMES[id] + " Lv%d→%d" % [_weapons[id].level, _weapons[id].level + 1],
				"desc": "Upgrade this weapon"})
	return opts
