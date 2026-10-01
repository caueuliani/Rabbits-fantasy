extends CanvasLayer

# UI de diálogos
@onready var dialogue_box: ColorRect = $DialogueBox
@onready var speaker_label: Label = $DialogueBox/SpeakerLabel
@onready var text_label: RichTextLabel = $DialogueBox/TextLabel
@onready var choices_container: VBoxContainer = $DialogueBox/ChoicesContainer
@onready var continue_prompt: Label = $DialogueBox/ContinuePrompt

var current_choices: Array = []
var is_typing: bool = false
var typing_speed: float = 0.02

signal dialogue_completed
signal choice_selected(choice_index: int)

func _ready() -> void:
	hide_dialogue()
	if continue_prompt:
		continue_prompt.visible = false

func show_line(speaker: String, text: String, choices: Array) -> void:
	dialogue_box.visible = true
	
	if speaker_label:
		speaker_label.text = speaker
	
	current_choices = choices
	
	# Mostrar texto com efeito de digitação
	if text_label:
		text_label.text = ""
		is_typing = true
		type_text(text)
	
	# Gerenciar escolhas
	if choices.size() > 0:
		show_choices(choices)
		if continue_prompt:
			continue_prompt.visible = false
	else:
		hide_choices()
		if continue_prompt:
			continue_prompt.visible = true

func type_text(text: String) -> void:
	var current_text = ""
	for i in range(text.length()):
		current_text += text[i]
		text_label.text = current_text
		await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false

func show_choices(choices: Array) -> void:
	# Limpar escolhas anteriores
	for child in choices_container.get_children():
		child.queue_free()
	
	# Criar botões para cada escolha
	for i in range(choices.size()):
		var choice = choices[i]
		var button = Button.new()
		button.text = choice["text"]
		button.pressed.connect(_on_choice_pressed.bind(i))
		choices_container.add_child(button)

func hide_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _on_choice_pressed(choice_index: int) -> void:
	choice_selected.emit(choice_index)

func advance_dialogue() -> void:
	if is_typing:
		# Completar texto imediatamente se estiver digitando
		is_typing = false
	else:
		dialogue_completed.emit()

func hide_dialogue() -> void:
	dialogue_box.visible = false
	hide_choices()
	if continue_prompt:
		continue_prompt.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_input_toggle") and dialogue_box.visible:
		if current_choices.size() == 0:
			advance_dialogue()