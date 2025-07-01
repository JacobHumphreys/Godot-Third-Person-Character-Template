##A special component meant to do physics calculations on request.
class_name PhysicsHandler
extends Node 

@export_group("Moving")
@export_subgroup("Walk")
@export_range(0.2, 100, 0.05, "suffix:m/s") var walking_speed:= 3.0 ##Normal speed if running is not actively occuring
@export_range(0.2, 10, 0.005, "suffix:s") var speed_up_time:= 0.135##The amount of time in seconds it takes for the player to stop.
@export_range(0.2, 10, 0.001, "suffix:s") var slow_time:= 0.125 ##The amount of time in seconds it takes for the player to stop.

@export_subgroup("Run")

##Enables running calculations.
@export var use_run := false 

##If running is set up this is the run speed
@export_range(0.1, 100, 0.05, "suffix:m/s") var running_speed: float = 5.0 

@export_group("Jump")

## Disable this for control over peak and fall times.
@export var simple_jump:=true 

## The time in seconds that it should take for the Jump to occur
@export_range(0.2, 10, 0.005, "suffix:s") var time_to_jump: float = 0.6: 
	set(val):
			_jump_time = val / 2
@export_range(0.2, 30, 0.05, "suffix:m") var jump_height: float = 1.45 ##The Height in meters that the jump should peak at

@export_subgroup("Complex Jump")
@export_range(0.2, 10, 0.005, "suffix:s") var time_to_peak: float = 0.3 ##The time in seconds it takes to get to the [member jump_height] of the jump. Accuracy of the fall time degrades if this gets to a value less than about 0.2
@export_range(0.2, 100, 0.005, "suffix:s") var time_to_ground: float = 0.45 ##The time in seconds it takes to get to the ground from the peak

var running:=false ##A boolean value that is used to specify if the character is meant to be running
var _speed:= 3.0 ##Current movement speed
var _friction:= Vector3.ZERO ##Acceleration when slowing to a stop
var _jump_time: float= time_to_jump/2

## The gravity that is needed for the jump to complete in the given [member jump_time]
@onready var _gravity: float = abs(_find_slope(_gravity_formula, _jump_time)) 

## The gravity that is needed for the jump to complete in the given [member peak_time]
@onready var _peak_gravity: float = abs(_find_slope(_gravity_formula, time_to_peak)) 


## The gravity that is needed for the jump to complete in the given fall_time
@onready var _fall_gravity: float = abs(_find_slope(_gravity_formula, time_to_ground))

## Calculates the change in velocity required to simulate accelerating to a predefined speed.
func apply_acceleration(velocity: Vector3, direction: Vector3, delta:float)-> Vector3:
	if use_run:
		running = Input.is_action_pressed("run")
	_change_speed()
	var output:=velocity
	output.x = move_toward(velocity.x, direction.x * _speed , _speed*delta/speed_up_time)
	output.z = move_toward(velocity.z, direction.z * _speed , _speed*delta/speed_up_time)
	_get_friction(velocity)
	return output


## Changes velocity gradually to reach zero.
func apply_friction(velocity:Vector3, delta: float) -> Vector3:
	running = false
	var output:= velocity
	output.x = move_toward(velocity.x, 0, _friction.x* delta) 
	output.z = move_toward(velocity.z, 0, _friction.z* delta)
	return output


## Appropriate Gravity based on [member Player.velocity] and [member simple_jump]
func get_gravity(velocity: Vector3, delta: float) -> Vector3:
	if simple_jump:
		velocity.y -= _gravity * delta
	elif velocity.y>0:
		velocity.y -= _peak_gravity * delta 
		velocity.y = clamp(velocity.y, 0, 10000)# Prevents the application of _peak_gravity past the peak
	else:
		velocity.y -= _fall_gravity * delta
	return velocity
		#from zero to peak 


## Initial velocity of gravity function
func get_jump_velocity() ->float: 
	return _gravity_formula(0.0, _jump_time) if simple_jump else _gravity_formula(0.0, time_to_peak)


## Increases speed based on whether the parameter [param running] == [b]true[/b]
func _change_speed() -> void:
	if running:
		_speed = move_toward(_speed, running_speed, 0.5)
	else:
		_speed = move_toward(_speed, walking_speed, 0.1)


## Finds the derivative(slope) of a given linear function by sampling two points
func _find_slope(my_func: Callable, time_interval: float) -> float:
	var y1: float = my_func.call(1, time_interval)
	var y2: float = my_func.call(2, time_interval)
	var slope := y2-y1
	return slope


## Calculates the change in velocity required to simulate friction using [member slow_time]. 
## Should be calculated when input is first released otherwise velocity just approaches zero.
func _get_friction(velocity_at_release:Vector3) -> void:
	var scaled_slow_time := slow_time
	if velocity_at_release.length() > walking_speed:
		scaled_slow_time = slow_time * running_speed/walking_speed 
	_friction.x = abs((-1*velocity_at_release.x)/scaled_slow_time)
	_friction.z = abs((-1*velocity_at_release.z)/scaled_slow_time)


## Returns the output of a formula that is used to find the value of the derivative of a perabola at a given point.
func _gravity_formula(x: float, time_interval: float) -> float:
	return ((-jump_height) * ((2.0*x) - (2.0*time_interval)))/pow(time_interval,2.0)
