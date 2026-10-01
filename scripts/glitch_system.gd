extends Node

# Sistema de Glitch P&B (Preto e Branco)
signal glitch_activated(duration: float)
signal glitch_deactivated
signal hidden_element_revealed(element: Node)

var is_glitch_active: bool = false
var glitch_duration: float = 2.0
var glitch_timer: float = 0.0
var player: Node = null

# Elementos que são revelados durante o glitch
var hidden_elements: Array = []

func _ready() -> void:
	add_to_group("glitch_system")
	find_player()

func find_player() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if is_glitch_active:
		glitch_timer -= delta
		if glitch_timer <= 0:
			deactivate_glitch()

func activate_glitch(duration: float = 2.0) -> void:
	if is_glitch_active:
		# Estender duração se já estiver ativo
		glitch_timer = duration
		return
	
	is_glitch_active = true
	glitch_duration = duration
	glitch_timer = duration
	
	glitch_activated.emit(duration)
	
	# Aplicar efeitos visuais
	apply_glitch_effects()
	
	# Revelar elementos escondidos
	reveal_hidden_elements()
	
	print("Glitch P&B ativado!")

func deactivate_glitch() -> void:
	if not is_glitch_active:
		return
	
	is_glitch_active = false
	
	glitch_deactivated.emit()
	
	# Remover efeitos visuais
	remove_glitch_effects()
	
	# Esconder elementos novamente
	hide_hidden_elements()
	
	print("Glitch P&B desativado")

func apply_glitch_effects() -> void:
	# Efeito visual principal: converter mundo para preto e branco
	get_tree().call_group("glitch_sensitive", "on_glitch_activated", true)
	
	# Aplicar efeito no viewport se existir
	var viewport = get_viewport()
	if viewport:
		# Criar shader de preto e branco
		var canvas_layer = CanvasLayer.new()
		canvas_layer.name = "GlitchLayer"
		var color_rect = ColorRect.new()
		color_rect.anchors_preset = 15  # Full rect
		color_rect.color = Color(1, 1, 1, 0.1)  # Leve overlay
		
		# Adicionar shader material
		var shader_material = ShaderMaterial.new()
		shader_material.shader = preload("res://shaders/glitch_shader.gdshader")
		color_rect.material = shader_material
		
		canvas_layer.add_child(color_rect)
		viewport.add_child(canvas_layer)

func remove_glitch_effects() -> void:
	# Remover efeitos visuais
	get_tree().call_group("glitch_sensitive", "on_glitch_activated", false)
	
	# Remover layer de glitch
	var viewport = get_viewport()
	if viewport:
		var glitch_layer = viewport.get_node_or_null("GlitchLayer")
		if glitch_layer:
			glitch_layer.queue_free()

func reveal_hidden_elements() -> void:
	# Tornar elementos escondidos visíveis
	for element in hidden_elements:
		if is_instance_valid(element):
			element.visible = true
			hidden_element_revealed.emit(element)
			print("Elemento revelado: ", element.name)

func hide_hidden_elements() -> void:
	# Esconder elementos novamente
	for element in hidden_elements:
		if is_instance_valid(element):
			element.visible = false

func register_hidden_element(element: Node) -> void:
	if not element in hidden_elements:
		hidden_elements.append(element)
		element.visible = false  # Começa invisível
		print("Elemento escondido registrado: ", element.name)

func unregister_hidden_element(element: Node) -> void:
	if element in hidden_elements:
		hidden_elements.erase(element)
		element.visible = true  # Torna visível permanentemente
		print("Elemento removido do registro: ", element.name)

func is_active() -> bool:
	return is_glitch_active

func get_remaining_time() -> float:
	return glitch_timer