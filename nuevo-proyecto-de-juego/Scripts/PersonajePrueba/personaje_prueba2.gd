extends CharacterBody3D

# Velocidad general del personaje
@export var f_velocidad:float = 5.0
@export var gravedad_caida := -20.0        # mientras cae
@export var f_friccion_suelo: float = 4.0
@export var f_friccion_aire: float = 1.0

# Parametros relacionados con el salto
@export var f_velocidad_salto:float = 7.0
@export var gravedad_salto := -12.0        # mientras sube

@export var cam_camara : Camera3D
@export var moverse_aire := false

# Variables internas
var raton_capturado := true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	raton_capturado = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	orientar_personaje()
	pausar()
	
func _physics_process(delta: float) -> void:
	# Gravedad
	aplicar_gravedad(delta)

	# Salta en caso de pulsar el boton asociado al salto
	saltar()

	# Ajustar la velocidad del personaje y moverlo en base a esta
	ajustar_velocidad(delta, obtener_direccion_movimiento())
	move_and_slide()
	
	# Aplica impulse en caso de detectar un trampolin
	detectar_trampolin()

func detectar_trampolin() -> void:
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		var posible_trampolin = collider.get_parent()

		if posible_trampolin is Trampolin:
			aplicar_impulso_trampolin(posible_trampolin)

func aplicar_impulso_trampolin(trampolin: Trampolin) -> void:
	var normal = trampolin.get_normal().normalized()
	var potencia = trampolin.get_potencia()
	velocity += normal * potencia

func ajustar_velocidad(delta: float, direccion: Vector3) -> void:
	if direccion != Vector3.ZERO:
		if is_on_floor() or moverse_aire:
			velocity.x = direccion.x * f_velocidad
			velocity.z = direccion.z * f_velocidad
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, f_friccion_suelo * delta)
			velocity.z = move_toward(velocity.z, 0, f_friccion_suelo * delta)
		else:
			if moverse_aire:
				velocity.x = move_toward(velocity.x, 0, f_friccion_aire * delta)
				velocity.z = move_toward(velocity.z, 0, f_friccion_aire * delta)

func saltar() -> void:
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = f_velocidad_salto

func aplicar_gravedad(delta: float) -> void:
	if not is_on_floor():
		if velocity.y > 0: # Si ha saltado
			velocity.y += gravedad_salto * delta
		else : # Si está cayendo de forma natural o empieza a caer despues de un salto
			velocity.y += gravedad_caida * delta

func obtener_direccion_movimiento() -> Vector3:
	var entrada := Vector2(
		Input.get_action_strength("mover_derecha") - Input.get_action_strength("mover_izquierda"),
		Input.get_action_strength("mover_arriba") - Input.get_action_strength("mover_abajo") 
		)
	
	# Si no se introduce ninguna direccion
	if entrada == Vector2.ZERO:
		return Vector3.ZERO
		
	var adelante = -cam_camara.global_transform.basis.z
	var derecha = cam_camara.global_transform.basis.x
	
	return (adelante * entrada.y + derecha * entrada.x).normalized()

func orientar_personaje() -> void:
	# Aplicamos la rotación del eje y al personaje
	if raton_capturado:
		rotation.y = cam_camara.rotation.y

func pausar() -> void:
	if Input.is_action_just_pressed("pausa"):
		if raton_capturado:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
