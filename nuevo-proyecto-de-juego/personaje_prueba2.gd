extends CharacterBody3D

# Velocidad general del personaje
@export var f_velocidad:float = 5.0
@export var gravedad_caida := -20.0        # mientras cae

# Parametros relativos a la rotacion del personaje
var rotacion_x:= 0.0
var rotacion_y:= 0.0
#@export var f_velocidad_rotacion:float = 1.0

# Parametros relacionados con el salto
@export var f_velocidad_salto:float = 7.0
@export var gravedad_salto := -12.0        # mientras sube


@export var cam_camara : Camera3D

func _process(delta: float) -> void:
	rotacion_x = cam_camara.f_rotacion_x
	rotacion_y = cam_camara.f_rotacion_y
	rotation_degrees = Vector3(0, rotacion_x, 0)

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		if velocity.y > 0: # Si ha saltado
			velocity.y += gravedad_salto * delta
		else : # Si está cayendo de forma natural o empieza a caer despues de un salto
			velocity.y += gravedad_caida * delta


	# Salta en caso de pulsar el boton asociado al salto
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		saltar()

	# Entrada del movimiento
	var entrada_direccion := Vector2(
		Input.get_action_strength("mover_derecha") - Input.get_action_strength("mover_izquierda"),
		Input.get_action_strength("mover_arriba") - Input.get_action_strength("mover_abajo") 
	)

	# Variable para la direccion
	var direccion:Vector3 = Vector3.ZERO

	# Direccion relativa de la camara
	var cam_delante := -cam_camara.transform.basis.z
	var cam_derecha := cam_camara.transform.basis.x
	
	# Asigno la direccion que seguira el personaje a la direccion relativa de la camara
	direccion = (cam_delante * entrada_direccion.y) + (cam_derecha * entrada_direccion.x)
	direccion.y = 0
	direccion = direccion.normalized()
	
	if is_on_floor(): # Solo puede moverse en caso de estar en el suelo
		if direccion:
			velocity.x = direccion.x * f_velocidad
			velocity.z = direccion.z * f_velocidad
		else:
			velocity.x = move_toward(velocity.x, 0, f_velocidad)
			velocity.z = move_toward(velocity.z, 0, f_velocidad)

	move_and_slide()

# Funcion para el salto
func saltar() -> void:
	velocity.y = f_velocidad_salto
