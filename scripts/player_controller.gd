extends CharacterBody2D

@export var speed: float = 200.0
@export var max_health: float = 100.0
var current_health: float = 100.0
@export var attack_damage: float = 25.0
@export var attack_cooldown: float = 0.5
var attack_timer: float = 0.0

@export var max_mana: float = 50.0
var current_mana: float = 50.0
@export var magic_cost: float = 10.0
var can_use_magic: bool = false
var is_glitching: bool = false
var glitch_timer: float = 0.0
@export var glitch_duration: float = 2.0

var is_attacking: bool = false
var is_dodging: bool = false
var dodge_timer: float = 0.0
@export var dodge_duration: float = 0.3
@export var dodge_speed_multiplier: float = 2.0
var is_dead: bool = false

@export var use_bow: bool = false
var current_direction: Vector2 = Vector2.DOWN
var last_movement_direction: Vector2 = Vector2.DOWN

var collision: CollisionShape2D = null
var attack_area: Area2D = null
var magic_area: Area2D = null

var bow_front: Sprite2D = null
var bow_back: Sprite2D = null
var bow_left: Sprite2D = null
var bow_right: Sprite2D = null
var sword_front: Sprite2D = null
var sword_back: Sprite2D = null
var sword_left: Sprite2D = null
var sword_right: Sprite2D = null

signal health_changed(new_health: float)
signal mana_changed(new_mana: float)
signal death

func _ready() -> void:
	current_health = max_health
	current_mana = max_mana
	health_changed.emit(current_health)
	mana_changed.emit(current_mana)
	add_to_group("player")
	
	collision = get_node_or_null("CollisionShape2D")
	attack_area = get_node_or_null("AttackArea")
	magic_area = get_node_or_null("MagicArea")
	
	bow_front = get_node_or_null("BowFront")
	bow_back = get_node_or_null("BowBack")
	bow_left = get_node_or_null("BowLeft")
	bow_right = get_node_or_null("BowRight")
	sword_front = get_node_or_null("SwordFront")
	sword_back = get_node_or_null("SwordBack")
	sword_left = get_node_or_null("SwordLeft")
	sword_right = get_node_or_null("SwordRight")
	
	load_sprites()
	hide_all_sprites()
	update_sprite()
	
	print("Jogador inicializado")

func load_sprites() -> void:
	if bow_front:
		bow_front.texture = load("res://assets/Gray-Arco-Frente.png")
	if bow_back:
		bow_back.texture = load("res://assets/Gray-Arco-Costa.png")
	if bow_left:
		bow_left.texture = load("res://assets/Gray-Arco-Esquerda.png")
	if bow_right:
		bow_right.texture = load("res://assets/Gray-Arco-Direita.png")
	
	if sword_front:
		sword_front.texture = load("res://assets/Gray-Espada-Frente.png")
	if sword_back:
		sword_back.texture = load("res://assets/Gray-Espada-Costa.png")
	if sword_left:
		sword_left.texture = load("res://assets/Gray-Espada-Esquerda.png")
	if sword_right:
		sword_right.texture = load("res://assets/Gray-Espada-Direita.png")

func hide_all_sprites() -> void:
	if bow_front: bow_front.visible = false
	if bow_back: bow_back.visible = false
	if bow_left: bow_left.visible = false
	if bow_right: bow_right.visible = false
	if sword_front: sword_front.visible = false
	if sword_back: sword_back.visible = false
	if sword_left: sword_left.visible = false
	if sword_right: sword_right.visible = false

func update_sprite() -> void:
	hide_all_sprites()
	
	var direction_to_use = current_direction if current_direction.length() > 0.1 else last_movement_direction
	var target_sprite: Sprite2D = null
	
	if use_bow:
		match direction_to_use:
			Vector2.UP: target_sprite = bow_back
			Vector2.DOWN: target_sprite = bow_front
			Vector2.LEFT: target_sprite = bow_left
			Vector2.RIGHT: target_sprite = bow_right
			_: target_sprite = bow_front
	else:
		match direction_to_use:
			Vector2.UP: target_sprite = sword_back
			Vector2.DOWN: target_sprite = sword_front
			Vector2.LEFT: target_sprite = sword_left
			Vector2.RIGHT: target_sprite = sword_right
			_: target_sprite = sword_front
	
	if target_sprite:
		target_sprite.visible = true

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	attack_timer = max(0, attack_timer - delta)
	dodge_timer = max(0, dodge_timer - delta)
	
	if is_dodging and dodge_timer <= 0:
		is_dodging = false
	
	if is_glitching:
		glitch_timer -= delta
		if glitch_timer <= 0:
			end_glitch()
	
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_direction.length() > 0.1:
		current_direction = input_direction.normalized()
		last_movement_direction = current_direction
		update_sprite()
	
	velocity = input_direction * speed
	move_and_slide()
	
	if not is_attacking and not is_dodging:
		process_combat_input()
		process_magic_input()
	
	if Input.is_action_just_pressed("ui_text_edit"):
		switch_weapon()

func process_combat_input() -> void:
	if Input.is_action_just_pressed("attack_basic") and attack_timer <= 0:
		perform_basic_attack()
	
	if Input.is_action_just_pressed("dodge") and dodge_timer <= 0:
		perform_dodge()

func process_magic_input() -> void:
	if Input.is_action_just_pressed("cast_magic") and current_mana >= magic_cost:
		attempt_magic()

func perform_basic_attack() -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	
	if attack_area:
		attack_area.monitoring = true
	
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
	
	await get_tree().create_timer(0.1).timeout
	if attack_area:
		attack_area.monitoring = false
	is_attacking = false

func perform_dodge() -> void:
	is_dodging = true
	dodge_timer = dodge_duration
	
	if collision:
		collision.set_deferred("disabled", true)
	
	await get_tree().create_timer(dodge_duration).timeout
	if collision:
		collision.disabled = false

func attempt_magic() -> void:
	current_mana -= magic_cost
	mana_changed.emit(current_mana)
	
	if can_use_magic:
		successful_magic()
	else:
		failed_magic()

func successful_magic() -> void:
	print("Magia realizada!")
	if magic_area:
		magic_area.monitoring = true
		await get_tree().create_timer(0.5).timeout
		if magic_area:
			magic_area.monitoring = false

func failed_magic() -> void:
	print("Magia falhou! Glitch P&B ativado!")
	trigger_glitch()

func trigger_glitch() -> void:
	is_glitching = true
	glitch_timer = glitch_duration
	
	var current_sprite = get_current_sprite()
	if current_sprite:
		current_sprite.modulate = Color(1, 1, 1, 0.5)
	
	var glitch_system = get_tree().get_first_node_in_group("glitch_system")
	if glitch_system:
		glitch_system.activate_glitch(glitch_duration)
	
	get_tree().call_group("glitch_sensitive", "on_glitch_activated", true)

func end_glitch() -> void:
	is_glitching = false
	
	var current_sprite = get_current_sprite()
	if current_sprite:
		current_sprite.modulate = Color.WHITE
	
	var glitch_system = get_tree().get_first_node_in_group("glitch_system")
	if glitch_system:
		glitch_system.deactivate_glitch()
	
	get_tree().call_group("glitch_sensitive", "on_glitch_activated", false)

func take_damage(amount: float) -> void:
	if is_dodging or is_dead:
		return
	
	current_health -= amount
	current_health = max(0, current_health)
	health_changed.emit(current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	is_dead = true
	death.emit()
	
	if collision:
		collision.disabled = true
	
	var current_sprite = get_current_sprite()
	if current_sprite:
		current_sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)

func heal(amount: float) -> void:
	current_health += amount
	current_health = min(max_health, current_health)
	health_changed.emit(current_health)

func restore_mana(amount: float) -> void:
	current_mana += amount
	current_mana = min(max_mana, current_mana)
	mana_changed.emit(current_mana)

func enable_magic() -> void:
	can_use_magic = true
	print("Magia habilitada!")

func switch_weapon() -> void:
	use_bow = !use_bow
	update_sprite()
	print("Arma alterada para: ", "Arco" if use_bow else "Espada")

func get_current_sprite() -> Sprite2D:
	var direction_to_use = current_direction if current_direction.length() > 0.1 else last_movement_direction
	
	if use_bow:
		match direction_to_use:
			Vector2.UP: return bow_back
			Vector2.DOWN: return bow_front
			Vector2.LEFT: return bow_left
			Vector2.RIGHT: return bow_right
			_: return bow_front
	else:
		match direction_to_use:
			Vector2.UP: return sword_back
			Vector2.DOWN: return sword_front
			Vector2.LEFT: return sword_left
			Vector2.RIGHT: return sword_right
			_: return sword_front