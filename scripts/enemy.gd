extends CharacterBody2D

# Inimigo base
@export var enemy_name: String = "Enemy"
@export var max_health: float = 50.0
var current_health: float = 50.0
@export var damage: float = 10.0
@export var speed: float = 100.0
@export var detection_range: float = 200.0
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0

var is_dead: bool = false
var is_attacking: bool = false
var attack_timer: float = 0.0
var player_detected: bool = false
var patrol_direction: Vector2 = Vector2.RIGHT
var patrol_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

signal health_changed(new_health: float)
signal death
signal attacked(damage: float)

func _ready() -> void:
	current_health = max_health
	patrol_timer = randf() * 2.0
	
	if detection_area:
		detection_area.body_entered.connect(_on_player_detected)
		detection_area.body_exited.connect(_on_player_lost)
	
	if attack_area:
		attack_area.body_entered.connect(_on_player_in_attack_range)
		attack_area.body_exited.connect(_on_player_out_attack_range)
	
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	attack_timer = max(0, attack_timer - delta)
	
	if player_detected:
		chase_player()
	else:
		patrol(delta)
	
	move_and_slide()

func patrol(delta: float) -> void:
	patrol_timer -= delta
	
	if patrol_timer <= 0:
		patrol_direction = -patrol_direction
		patrol_timer = randf() * 2.0 + 1.0
	
	velocity = patrol_direction * speed
	
	# Virar sprite na direção do movimento
	if sprite:
		sprite.flip_h = velocity.x < 0

func chase_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	
	if global_position.distance_to(player.global_position) > attack_range:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		attack()
	
	# Virar sprite na direção do jogador
	if sprite:
		sprite.flip_h = direction.x < 0

func attack() -> void:
	if is_attacking or attack_timer > 0:
		return
	
	is_attacking = true
	attack_timer = attack_cooldown
	
	# Atacar jogador
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) <= attack_range:
		player.take_damage(damage)
		attacked.emit(damage)
	
	await get_tree().create_timer(0.3).timeout
	is_attacking = false

func take_damage(amount: float) -> void:
	if is_dead:
		return
	
	current_health -= amount
	current_health = max(0, current_health)
	health_changed.emit(current_health)
	
	# Efeito visual de dano
	if sprite:
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
	
	if current_health <= 0:
		die()

func die() -> void:
	is_dead = true
	death.emit()
	
	# Desativar colisão
	if collision:
		collision.disabled = true
	
	# Efeito de morte
	if sprite:
		sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)
	
	# Remover após um tempo
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_player_detected(body: Node) -> void:
	if body.is_in_group("player"):
		player_detected = true

func _on_player_lost(body: Node) -> void:
	if body.is_in_group("player"):
		player_detected = false

func _on_player_in_attack_range(body: Node) -> void:
	if body.is_in_group("player"):
		# Já tratado no chase_player
		pass

func _on_player_out_attack_range(body: Node) -> void:
	if body.is_in_group("player"):
		# Já tratado no chase_player
		pass