extends CanvasLayer

# HUD principal do jogo
@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $ManaBar
@onready var quest_display: Label = $QuestDisplay
@onready var interaction_prompt: Label = $InteractionPrompt
@onready var pause_menu: Control = $PauseMenu

var player: Node = null

func _ready() -> void:
	hide_pause_menu()
	find_player()
	
	# Conectar sinais do jogador
	if player:
		player.health_changed.connect(_on_health_changed)
		player.mana_changed.connect(_on_mana_changed)

func find_player() -> void:
	player = get_tree().get_first_node_in_group("player")

func _on_health_changed(new_health: float) -> void:
	if health_bar:
		var health_percent = (new_health / player.max_health) * 100
		health_bar.value = health_percent

func _on_mana_changed(new_mana: float) -> void:
	if mana_bar:
		var mana_percent = (new_mana / player.max_mana) * 100
		mana_bar.value = mana_percent

func show_interaction_prompt(text: String) -> void:
	if interaction_prompt:
		interaction_prompt.text = text
		interaction_prompt.visible = true

func hide_interaction_prompt() -> void:
	if interaction_prompt:
		interaction_prompt.visible = false

func update_quest_display(quest_title: String, objectives: Array) -> void:
	if quest_display:
		var display_text = "Missão: " + quest_title + "\n\n"
		for objective in objectives:
			var status = "✓" if objective["completed"] else "○"
			display_text += status + " " + objective["description"] + "\n"
		quest_display.text = display_text

func show_pause_menu() -> void:
	if pause_menu:
		pause_menu.visible = true

func hide_pause_menu() -> void:
	if pause_menu:
		pause_menu.visible = false