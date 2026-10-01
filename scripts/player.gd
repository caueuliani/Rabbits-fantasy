extends CharacterBody2D

@export_group("Movimentação")
@export var walk_speed: float = 180.0
@export var run_speed: float = 320.0
@export var walk_frame_time: float = 0.18

@export_group("Idle - Direções")
@export var idle_front: Texture2D
@export var idle_back: Texture2D
@export var idle_left: Texture2D
@export var idle_right: Texture2D

@export_group("Walk Front")
@export var walk_front_a: Texture2D
@export var walk_front_b: Texture2D

@export_group("Walk Back")
@export var walk_back_a: Texture2D
@export var walk_back_b: Texture2D

@export_group("Walk Left")
@export var walk_left_a: Texture2D
@export var walk_left_b: Texture2D

@export_group("Walk Right")
@export var walk_right_a: Texture2D
@export var walk_right_b: Texture2D

@onready var player_sprite: Sprite2D = $Sprite2D

var facing_direction: String = "front"
var animation_timer: float = 0.0
var current_walk_frame: int = 0


func _ready() -> void:
	update_idle_sprite()


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	var current_speed := walk_speed

	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = run_speed

	velocity = direction * current_speed

	if direction != Vector2.ZERO:
		update_facing_direction(direction)
		update_walk_animation(delta)
	else:
		reset_walk_animation()

	move_and_slide()


func update_facing_direction(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			facing_direction = "right"
		else:
			facing_direction = "left"
	else:
		if direction.y > 0:
			facing_direction = "front"
		else:
			facing_direction = "back"


func update_walk_animation(delta: float) -> void:
	animation_timer += delta

	if animation_timer >= walk_frame_time:
		animation_timer = 0.0
		current_walk_frame = 1 - current_walk_frame

	update_walk_sprite()


func update_walk_sprite() -> void:
	match facing_direction:
		"front":
			player_sprite.texture = walk_front_a if current_walk_frame == 0 else walk_front_b
		"back":
			player_sprite.texture = walk_back_a if current_walk_frame == 0 else walk_back_b
		"left":
			player_sprite.texture = walk_left_a if current_walk_frame == 0 else walk_left_b
		"right":
			player_sprite.texture = walk_right_a if current_walk_frame == 0 else walk_right_b


func reset_walk_animation() -> void:
	animation_timer = 0.0
	current_walk_frame = 0
	update_idle_sprite()


func update_idle_sprite() -> void:
	match facing_direction:
		"front":
			player_sprite.texture = idle_front
		"back":
			player_sprite.texture = idle_back
		"left":
			player_sprite.texture = idle_left
		"right":
			player_sprite.texture = idle_right
