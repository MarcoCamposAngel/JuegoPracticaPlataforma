class_name Trampolin
extends Node3D

@export var fuerza_impulso: float = 50

var tiempo_ultimo_impulso := {}

func get_normal() -> Vector3:
	return global_transform.basis.y

func get_potencia() -> float:
	return fuerza_impulso
