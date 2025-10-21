class_name Trampolin
extends Node3D

@onready var rigidbody: RigidBody3D = $Body
@export var fuerza_impulso: float = 15.0
@export var direccion_superficie: Vector3 = Vector3.UP

var tiempo_ultimo_impulso := {}


func _ready():
	rigidbody.contact_monitor = true
	rigidbody.max_contacts_reported = 4

func _integrate_forces(state):
	var contact_count = state.get_contact_count()
	if contact_count == 0:
		return
	
	for i in range(contact_count):
		var collider = state.get_contact_collider_object(i)
		if collider is CharacterBody3D:
			var now = Time.get_ticks_msec()
			if tiempo_ultimo_impulso.get(collider, 0) + 200 > now:
				continue
			tiempo_ultimo_impulso[collider] = now
			
			var normal_superficie = (rigidbody.global_transform.basis * direccion_superficie).normalized()
			
			collider.velocity += normal_superficie * fuerza_impulso
