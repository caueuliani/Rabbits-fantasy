extends Node

# Sistema de combate gerenciado
signal attack_started(attacker: Node, target: Node)
signal attack_hit(attacker: Node, target: Node, damage: float)
signal attack_dodged(attacker: Node, target: Node)
signal combo_increased(combo_count: int)

var current_combo: int = 0
var combo_timer: float = 0.0
var combo_timeout: float = 2.0

func _ready() -> void:
	add_to_group("combat_system")

func _process(delta: float) -> void:
	# Gerenciar timer de combo
	if current_combo > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			reset_combo()

func register_attack(attacker: Node, target: Node, damage: float) -> void:
	attack_started.emit(attacker, target)
	
	# Verificar se o alvo esquivou
	if target.has_method("is_dodging") and target.is_dodging():
		attack_dodged.emit(attacker, target)
		return
	
	# Aplicar dano
	if target.has_method("take_damage"):
		target.take_damage(damage)
		attack_hit.emit(attacker, target, damage)
		
		# Aumentar combo
		increase_combo()

func increase_combo() -> void:
	current_combo += 1
	combo_timer = combo_timeout
	combo_increased.emit(current_combo)
	print("Combo: ", current_combo)

func reset_combo() -> void:
	current_combo = 0
	print("Combo resetado")

func get_combo() -> int:
	return current_combo

func calculate_damage(base_damage: float, attacker_level: int, target_level: int) -> float:
	# Fórmula básica de dano baseada em níveis
	var level_modifier = 1.0 + (attacker_level - target_level) * 0.1
	return base_damage * level_modifier

func is_critical_hit() -> bool:
	# 10% de chance de crítico
	return randf() < 0.1

func apply_critical_damage(base_damage: float) -> float:
	return base_damage * 1.5