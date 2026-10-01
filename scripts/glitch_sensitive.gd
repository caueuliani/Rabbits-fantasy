extends Node2D

# Elemento que responde ao Glitch P&B
@export var is_hidden: bool = true
@export var reveal_on_glitch: bool = true
@export var permanent_reveal: bool = false

var original_visible: bool = true
var original_modulate: Color = Color.WHITE
var is_revealed: bool = false

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var collision: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

func _ready() -> void:
	add_to_group("glitch_sensitive")
	
	# Salvar estado original
	original_visible = visible
	if sprite:
		original_modulate = sprite.modulate
	
	# Se deve começar escondido
	if is_hidden:
		hide_element()

func on_glitch_activated(glitch_active: bool) -> void:
	if not reveal_on_glitch:
		return
	
	if glitch_active:
		reveal_element()
	else:
		if not permanent_reveal:
			hide_element()

func reveal_element() -> void:
	if is_revealed:
		return
	
	is_revealed = true
	visible = true
	
	if sprite:
		sprite.modulate = Color.WHITE
	
	if collision:
		collision.disabled = false
	
	print("Elemento revelado pelo Glitch: ", name)

func hide_element() -> void:
	if not is_revealed:
		return
	
	is_revealed = false
	visible = false
	
	if sprite:
		sprite.modulate = Color(1, 1, 1, 0.3)  # Semi-transparente quando escondido
	
	if collision:
		collision.disabled = true
	
	print("Elemento escondido: ", name)

func set_permanent_reveal() -> void:
	permanent_reveal = true
	is_hidden = false
	reveal_element()

func interact_with_player() -> void:
	# Método para interação quando o jogador usa o elemento
	print("Interagindo com elemento sensível ao glitch: ", name)