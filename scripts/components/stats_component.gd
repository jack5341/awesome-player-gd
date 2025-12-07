class_name StatsComponent
extends Node

signal health_changed(current: float, max: float)
signal stamina_changed(current: float, max: float)
signal died()

@export_group("Health")
@export var max_health: float = 100.0:
	set(value):
		max_health = value
		health_changed.emit(current_health, max_health)

@export var current_health: float = 100.0:
	set(value):
		current_health = clamp(value, 0.0, max_health)
		health_changed.emit(current_health, max_health)
		if current_health <= 0:
			died.emit()

@export_group("Stamina")
@export var max_stamina: float = 100.0:
	set(value):
		max_stamina = value
		stamina_changed.emit(current_stamina, max_stamina)

@export var current_stamina: float = 100.0:
	set(value):
		current_stamina = clamp(value, 0.0, max_stamina)
		stamina_changed.emit(current_stamina, max_stamina)

@export var stamina_regen_rate: float = 10.0
@export var stamina_drain_rate: float = 20.0

# Modifiers
var modifiers: Dictionary = {}

func _process(delta: float) -> void:
	if current_stamina < max_stamina:
		current_stamina += stamina_regen_rate * delta

func damage(amount: float) -> void:
	current_health -= amount

func heal(amount: float) -> void:
	current_health += amount

func consume_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		return true
	return false
