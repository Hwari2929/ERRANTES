extends CharacterBody2D

signal hp_changed(current_hp: int, max_hp: int)
signal xp_changed(current_xp: int, xp_to_next: int)
signal level_uped(new_level: int)
signal died()
signal stats_changed()

# ── 기본 스탯 (캐릭터 특성으로 성장) ──
@export var base_speed: float = 200.0
@export var max_hp: int = 100
@export var xp_to_next_level: int = 100

# 배수/특성 (업그레이드로 강화)
var move_speed_mult: float = 1.0      # 이동 속도 배수
var damage_mult: float = 1.0          # 모든 무기 데미지 배수
var attack_speed_mult: float = 1.0    # 공격 속도 배수 (쿨다운 단축)
var armor: int = 0                     # 받는 피해 감소 (플랫)
var hp_regen: float = 0.0             # 초당 체력 재생
var pickup_radius: float = 90.0       # 경험치 획득 반경
var crit_chance: float = 0.05         # 치명타 확률
var crit_mult: float = 2.0           # 치명타 배수

@onready var inv_timer: Timer = $InvincibilityTimer
@onready var sprite: Sprite2D = $Sprite2D
@onready var weapons: Node2D = $WeaponManager

var current_hp: int = 0
var current_xp: int = 0
var level: int = 1
var invincible: bool = false
var _regen_accum: float = 0.0

# ── 대시 능력 변수 ──
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
const DASH_DURATION: float = 0.15
const DASH_COOLDOWN: float = 1.2
const DASH_SPEED_MULT: float = 3.0

func _ready() -> void:
	current_hp = max_hp
	add_to_group("player")
	inv_timer.timeout.connect(_on_inv_timeout)
	hp_changed.emit(current_hp, max_hp)
	xp_changed.emit(current_xp, xp_to_next_level)
	# 시작 무기
	if weapons and weapons.has_method("add_weapon"):
		weapons.add_weapon("bolt")

func _physics_process(delta: float) -> void:
	# 대시 쿨다운 감소
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# 대시 입력 및 상태 전환
	if Input.is_action_just_pressed("ui_accept") and not is_dashing and dash_cooldown_timer <= 0:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN

	# 대시 지속 시간 감소
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	# 이동 계산 (대시 배수 통합)
	var dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var current_speed_mult: float = move_speed_mult
	if is_dashing:
		current_speed_mult *= DASH_SPEED_MULT
	velocity = dir * base_speed * current_speed_mult
	move_and_slide()

func _process(delta: float) -> void:
	# 체력 재생
	if hp_regen > 0.0 and current_hp < max_hp and current_hp > 0:
		_regen_accum += hp_regen * delta
		if _regen_accum >= 1.0:
			var whole: int = int(_regen_accum)
			_regen_accum -= whole
			heal(whole)

func take_damage(amount: int) -> void:
	if invincible or current_hp <= 0:
		return
	var dealt: int = max(1, amount - armor)
	current_hp = max(0, current_hp - dealt)
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		died.emit()
		queue_free()
		return
	invincible = true
	sprite.modulate = Color(1, 0.5, 0.5, 0.5)
	inv_timer.start()

func add_xp(amount: int) -> void:
	current_xp += amount
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		_level_up()
	xp_changed.emit(current_xp, xp_to_next_level)

func _level_up() -> void:
	level += 1
	xp_to_next_level = int(xp_to_next_level * 1.5)
	level_uped.emit(level)

func heal(amount: int) -> void:
	current_hp = mini(current_hp + amount, max_hp)
	hp_changed.emit(current_hp, max_hp)

# 무기가 호출: [데미지, 치명타여부]
func roll_damage(base: float) -> Array:
	var dmg: float = base * damage_mult
	var crit: bool = randf() < crit_chance
	if crit:
		dmg *= crit_mult
	return [dmg, crit]

func _on_inv_timeout() -> void:
	invincible = false
	sprite.modulate = Color(1, 1, 1, 1)

# ── 업그레이드 적용 (스탯 특성 + 무기) ──
func apply_upgrade(upgrade_id: String) -> void:
	match upgrade_id:
		# 스탯/특성
		"speed":       move_speed_mult += 0.15
		"max_hp":      max_hp += 25; heal(25)
		"damage":      damage_mult += 0.20
		"attack_speed":
			attack_speed_mult += 0.18
			if weapons and weapons.has_method("refresh_cooldowns"):
				weapons.refresh_cooldowns()
		"armor":       armor += 2
		"regen":       hp_regen += 0.6
		"crit":        crit_chance = minf(crit_chance + 0.06, 0.75)
		"pickup":      pickup_radius += 40.0
		"heal_now":    heal(40)
		# 무기 추가/강화 → weapon_manager가 "weapon:<id>" 형태로 처리
		_:
			if upgrade_id.begins_with("weapon:") and weapons:
				var wid: String = upgrade_id.substr(7)
				weapons.add_or_upgrade(wid)
	stats_changed.emit()