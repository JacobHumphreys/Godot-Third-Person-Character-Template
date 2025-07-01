## Is responsible for changing between animation states and blend positions based on calls from the player script.
## This is used to help simplify and shorten the process of animating player actions from the Player Controller
## and should be the only script that directly sets properties of the Animation Tree.
class_name AnimationHandler
extends AnimationTree

var _move_state := -1.0  ## A value with a range from zero to 1 which controls movement animations


func animation_ready(walk_speed: float, run_speed: float) -> void:
	set("parameters/Weapon/Rifle/Fix/add_amount", 0.2)
	set("parameters/Weaponless/WalkScale/scale", walk_speed / 1.8)
	set("parameters/Weaponless/RunScale/scale", run_speed / 3.0)


func update(on_floor: bool, delta: float) -> void:
	var jump_blend := move_toward(
		get("parameters/State Machine/Jump/blend_amount"), not on_floor, 5.0 * delta
	)
	set("parameters/State Machine/Jump/blend_amount", jump_blend)
	set("parameters/State Machine/walk_state/blend_amount", _move_state)


## Alters movestate to go between walking, running, and stopped.
func update_move_state(input: Vector2, running: bool, delta: float) -> void:
	if input == Vector2.ZERO:
		_move_state = move_toward(_move_state, -1.0, 6.25 * delta)
	else:
		var movement_value := 1 if running else 0
		_move_state = move_toward(_move_state, movement_value, 6.25 * delta)  #if walking running = 0. If running running = 1
