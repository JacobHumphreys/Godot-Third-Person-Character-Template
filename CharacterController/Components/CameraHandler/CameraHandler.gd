@tool
class_name CameraHandler
extends Node3D

@export_range(0, 15, 0.1, "suffix:m") var camera_distance := 1.0
@export_range(0, 360, 0.5, "suffix:°") var camera_angle := 35.3

var joy_hori_sensitivity := 0.05  

var joy_vert_sensitivity := 0.025  

var mouse_hori_sensitivity := 0.001  

var mouse_vert_sensitivity := 0.001  

## Point around which the camera [i]horizontally[/i] rotates
@onready var twist_pivot: Node3D = $TwistPivot  

##Point around which the camera [i]vertically[/i] rotates
@onready var pitch_pivot: Node3D = $TwistPivot/PitchPivot  

##Prevents camera clipping into walls
@onready var camera_spring_arm: SpringArm3D = $"TwistPivot/PitchPivot/Camera Spring Arm"

@onready var camera: Camera3D = $"TwistPivot/PitchPivot/Camera Spring Arm/Camera3D"


func _ready() -> void:
	if not Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_set_initial_position()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_set_initial_position()


func _input(event: InputEvent) -> void:
	camera_control(event)


## Takes input events and rotates pivots based on it.
func camera_control(event: InputEvent) -> void:
	var twist_amount: float
	var pitch_amount: float
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:  #if mouse input
		twist_amount = -event.relative.x * mouse_hori_sensitivity
		pitch_amount = -event.relative.y * mouse_vert_sensitivity
	elif event is InputEventJoypadMotion:
		var axis_vector := Vector2(
			Input.get_axis("look_left", "look_right"), Input.get_axis("look_down", "look_up")
		)  #Direction of event.
		twist_amount = -axis_vector.x * joy_hori_sensitivity
		pitch_amount = axis_vector.y * joy_vert_sensitivity

	twist_pivot.rotate_y(twist_amount) 
	pitch_pivot.rotate_x(pitch_amount)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(30))


func _set_initial_position() -> void:
	camera_spring_arm.spring_length = camera_distance
	camera.position.z = camera_distance
	camera_spring_arm.rotation.y = deg_to_rad(camera_angle)
	camera.rotation.y = deg_to_rad(-1 * camera_angle)
