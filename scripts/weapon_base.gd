extends Node2D
class_name WeaponBase
# 모든 무기의 베이스. 자체 Timer로 주기 발동하고, 플레이어 스탯을 참조한다.

var level: int = 1
var max_level: int = 5
var player: Node = null
var _timer: Timer

# 하위 무기가 오버라이드할 값
var base_cooldown: float = 1.0
var weapon_name: String = "Weapon"

func setup(p: Node) -> void:
	player = p
	_timer = Timer.new()
	_timer.one_shot = false
	add_child(_timer)
	_timer.timeout.connect(_on_tick)
	_on_setup()          # 하위 클래스가 base_cooldown 등 설정
	_refresh_cooldown()
	_timer.start()

func _refresh_cooldown() -> void:
	if not _timer:
		return
	var asm: float = 1.0
	if player and "attack_speed_mult" in player:
		asm = player.attack_speed_mult
	_timer.wait_time = maxf(0.08, base_cooldown / maxf(0.2, asm))

func level_up() -> void:
	level = mini(level + 1, max_level)
	_refresh_cooldown()
	_on_level_up()

func is_maxed() -> bool:
	return level >= max_level

# 데미지 계산 + 적에게 적용 (치명타 반영)
func deal(enemy: Node, base_dmg: float) -> void:
	if not is_instance_valid(enemy) or not enemy.has_method("take_damage"):
		return
	var dmg: float = base_dmg
	var crit: bool = false
	if player and player.has_method("roll_damage"):
		var rd: Array = player.roll_damage(base_dmg)
		dmg = rd[0]
		crit = rd[1]
	enemy.take_damage(dmg, crit)

func _nearest_enemy(from: Vector2, max_range: float = INF) -> Node2D:
	var best: Node2D = null
	var best_d: float = max_range
	for e in get_tree().get_nodes_in_group("enemy"):
		var d: float = from.distance_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best

# 하위 클래스 훅
func _on_setup() -> void: pass
func _on_tick() -> void: pass
func _on_level_up() -> void: pass
