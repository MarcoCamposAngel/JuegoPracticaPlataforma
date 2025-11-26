extends Camera3D

@export var punto_primera_persona:Node3D
@export var f_sensibilidad: float = 0.5
@export var suavizado: float = 12.0

@export var f_rot_x: float = 0.0
@export var f_rot_y: float = 0.0

const LIMITE_VERTICAL := 350.0

func _ready() -> void:
# Obtener rotación actual del punto de primera persona
	var rot = punto_primera_persona.global_rotation_degrees
	f_rot_x = rot.y
	f_rot_y = rot.x
	rotation_degrees = Vector3(rot.y, rot.x, 0)

func _physics_process(delta: float) -> void:
	mantener_posicion()
	aplicar_rotacion(delta)

func mantener_posicion () -> void:
	transform = punto_primera_persona.global_transform

func aplicar_rotacion(delta: float) -> void:
	# Solo rotamos si el mouse está capturado
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var objetivo = Vector3(f_rot_y, f_rot_x, 0)
		rotation_degrees = rotation_degrees.lerp(objetivo, suavizado * delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		f_rot_x -= event.relative.x * f_sensibilidad
		f_rot_y -= event.relative.y * f_sensibilidad
		
		f_rot_y = clamp(f_rot_y, -LIMITE_VERTICAL, LIMITE_VERTICAL)
