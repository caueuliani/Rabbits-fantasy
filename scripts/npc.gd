extends CharacterBody2D

# NPC base para interação
@export var npc_name: String = "NPC"
@export var dialogue_id: String = ""
@export var can_interact: bool = true
@export var interaction_range: float = 100.0

var player_in_range: bool = false
var is_interacting: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_prompt: Label = $InteractionPrompt

signal interaction_started(npc_name: String)
signal interaction_finished

func _ready() -> void:
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	
	if interaction_prompt:
		interaction_prompt.visible = false
		interaction_prompt.text = "Pressione E para interagir"
	
	add_to_group("npcs")
	add_to_group("interactable")

func _physics_process(_delta: float) -> void:
	if player_in_range and can_interact and not is_interacting:
		if Input.is_action_just_pressed("ui_text_input_toggle"):
			start_interaction()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if interaction_prompt:
			interaction_prompt.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if interaction_prompt:
			interaction_prompt.visible = false

func start_interaction() -> void:
	if not can_interact or is_interacting:
		return
	
	is_interacting = true
	interaction_started.emit(npc_name)
	
	# Iniciar diálogo
	if dialogue_id != "":
		var dialogue_system = get_tree().get_first_node_in_group("dialogue_system")
		if dialogue_system:
			dialogue_system.start_dialogue(dialogue_id)
			dialogue_system.dialogue_finished.connect(_on_dialogue_finished)

func _on_dialogue_finished() -> void:
	is_interacting = false
	interaction_finished.emit()

func set_dialogue(new_dialogue_id: String) -> void:
	dialogue_id = new_dialogue_id

func enable_interaction() -> void:
	can_interact = true

func disable_interaction() -> void:
	can_interact = false

func set_npc_name(new_name: String) -> void:
	npc_name = new_name

func face_player() -> void:
	if player_in_range:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var direction = player.global_position - global_position
			if direction.x > 0:
				sprite.flip_h = false
			else:
				sprite.flip_h = true