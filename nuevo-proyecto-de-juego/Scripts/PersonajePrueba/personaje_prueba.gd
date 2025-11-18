extends CharacterBody3D

# =======================
# Configuración general
# =======================
@export var f_velocidad: float = 5.0
@export var f_velocidad_caida: float = -9.8
@export var f_velocidad_salto: float = 5.0
@export var f_altura_maxima_salto: float = 10.0
@export var f_friccion_suelo: float = 4.0
@export var f_friccion_aire: float = 1.0
@export var cam_camara: Camera3D

# =======================
# Variables internas
# =======================
var b_saltando: bool = false
var altura_inicio: float = 0.0
var altura_fin: float = 0.0

# =======================
# Funciones de salto
# =======================
func saltar() -> void:
	if is_on_floor():
		altura_inicio = global_position.y
		altura_fin = altura_inicio + f_altura_maxima_salto
		velocity.y = f_velocidad_salto
		b_saltando = true

func limitar_salto() -> void:
	if b_saltando and velocity.y > 0 and global_position.y >= altura_fin:
		velocity.y = 0
		b_saltando = false

# =======================
# Física y movimiento
# =======================
func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y += f_velocidad_caida * delta

	# Salto
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		saltar()

	limitar_salto()

	# Entrada de movimiento
	var entrada_direccion = Vector2(
		Input.get_action_strength("mover_derecha") - Input.get_action_strength("mover_izquierda"),
		Input.get_action_strength("mover_arriba") - Input.get_action_strength("mover_abajo")
	)

	var direccion = Vector3.ZERO
	var cam_delante = -cam_camara.transform.basis.z
	var cam_derecha = cam_camara.transform.basis.x
	direccion = (cam_delante * entrada_direccion.y) + (cam_derecha * entrada_direccion.x)
	direccion.y = 0
	direccion = direccion.normalized()

	if direccion:
		velocity.x += direccion.x * f_velocidad * delta
		velocity.z += direccion.z * f_velocidad * delta
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, f_friccion_suelo * delta)
			velocity.z = move_toward(velocity.z, 0, f_friccion_suelo * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, f_friccion_aire * delta)
			velocity.z = move_toward(velocity.z, 0, f_friccion_aire * delta)

	# Mover el personaje primero
	move_and_slide()

	# Detectar trampolines y aplicar rebote
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		var posible_trampolin = collider.get_parent()

		if posible_trampolin is Trampolin:
			aplicar_impulso_trampolin(posible_trampolin)

# Función de impulso del trampolín
func aplicar_impulso_trampolin(trampolin: Trampolin) -> void:
	var normal = trampolin.get_normal().normalized()
	var potencia = trampolin.get_potencia()
	velocity += normal * potencia
