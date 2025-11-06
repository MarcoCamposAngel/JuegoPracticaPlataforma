extends CharacterBody3D

# Velocidad general del personaje
@export var f_velocidad:float = 5.0
@export var f_velocidad_caida: float = -9.8

# Parametros relacionados con el salto
@export var f_velocidad_salto:float = 5.0
@export var f_altura_maxima_salto:float = 10.0
var b_saltando:bool = false
var altura_inicio:float = 0.0
var altura_fin: float = 0.0

@export var f_velocidad_rotacion:float = 1.0
@export var cam_camara : Camera3D

# Funcion para el salto
func saltar() -> void:
	if is_on_floor():
		altura_inicio = global_position.y 
		altura_fin = altura_inicio + f_altura_maxima_salto
		velocity.y = f_velocidad_salto
		b_saltando = true

# Funcion que determina la altura máxima que puede alcanzar un salto
func limitar_salto() -> void:
	if b_saltando: 
		if velocity.y > 0 and global_position.y >= altura_fin:
			velocity.y = 0
			b_saltando = false

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y += f_velocidad_caida * delta

	# Salta en caso de pulsar el boton asociado al salto
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		saltar()
	
	
	limitar_salto()
	
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
	
	if direccion:
		velocity.x = direccion.x * f_velocidad
		velocity.z = direccion.z * f_velocidad
	else:
		velocity.x = move_toward(velocity.x, 0, f_velocidad)
		velocity.z = move_toward(velocity.z, 0, f_velocidad)

	move_and_slide()
