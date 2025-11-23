extends Camera3D

@export var punto_primera_persona:Node3D
@export var f_sensibilidad:float = 0.5

@export var f_rotacion_x:float = 0.0
@export var f_rotacion_y:float = 0.0

func _ready() -> void:
# Obtener rotación actual del punto de primera persona
	var rot = punto_primera_persona.global_rotation
	rotation_degrees = Vector3(rot.y,rot.x,0)

func _process(delta:float) -> void:
	mantener_posicion(delta)
	aplicar_rotacion()

func mantener_posicion (delta:float) -> void:
	transform = punto_primera_persona.global_transform

func aplicar_rotacion() -> void:
	# Solo rotamos si el mouse está capturado
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees = Vector3(f_rotacion_y, f_rotacion_x, 0)


func _unhandled_input(event: InputEvent) -> void:
	if event is  InputEventMouseMotion:
		f_rotacion_x -= event.relative.x * f_sensibilidad
		f_rotacion_y -= event.relative.y * f_sensibilidad
