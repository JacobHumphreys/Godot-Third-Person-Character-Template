class_name Player
extends CharacterBody3D
## This is the Player's control script and is meant to handle movement and Animation.
##
## This is not meant to actually singal changes to the animator node, rather it should signal changes to the Player animation controller.

var input: Vector2  ## A [Vector3] representing the players input. The y value is not used but is needed for the [member Transform3D.basis] calculations to work.

@onready var animation_handler: AnimationHandler = $Visuals/AnimationHandler
@onready var camera_handler: CameraHandler = $CameraHandler
@onready var physics_handler: PhysicsHandler = $PhysicsHandler

@onready var twist_pivot: Node3D = $CameraHandler/TwistPivot  ## A node that is used to rotate the Camera [i]horizontally[/i] around a point
@onready var pitch_pivot: Node3D = $CameraHandler/TwistPivot/PitchPivot  ## A node that is used to rotate the Camera [i]vertically[/i] around a point
@onready var visuals: Node3D = $Visuals


func _ready() -> void:
	animation_handler.animation_ready(physics_handler.walking_speed, physics_handler.running_speed)


func _process(delta: float) -> void:
	animation_handler.update(is_on_floor(), delta)
	animation_handler.update_move_state(input, physics_handler.running, delta)


func _physics_process(delta: float) -> void:
	_movement(delta)


## Handles modifying the player's location based on keyboard input [br][br]
## Inherits the behavior of [method MainLoop._physics_process] and is passed [param delta]
func _movement(delta: float) -> void:
	if not is_on_floor():  # Applies gravity reguardless of player input
		velocity = physics_handler.get_gravity(velocity, delta)
	elif Input.is_action_just_pressed("jump"):  # Applies intial jump velocity.
		velocity.y = physics_handler.get_jump_velocity()
	input = Input.get_vector("move_left", "move_right", "move_foreward", "move_back")
	var direction := (twist_pivot.basis * Vector3(input.x, 0, input.y)).normalized()  # Motified
	if direction:
		velocity = physics_handler.apply_acceleration(velocity, direction, delta)
		var align := visuals.transform.looking_at(visuals.transform.origin - direction)
		visuals.transform = visuals.transform.interpolate_with(align, delta * 10.0)
	elif is_on_floor():
		velocity = physics_handler.apply_friction(velocity, delta)
	move_and_slide()
