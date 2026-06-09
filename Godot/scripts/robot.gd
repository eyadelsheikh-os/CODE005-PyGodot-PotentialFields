# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 03 - Extends
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
extends CharacterBody2D

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 04 - Document
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# scripts/robot.gd
# "/root/Main/Robot"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 08 - Exported Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
@export var wheelbase: float = 100.0	# distance between axles (units: cm)
@export var wheel_acceleration: float= 200.0	# cm/s2
@export var max_speed: float = 200.0	# cm/s
@export var turn_speed: float = 3.0		# rad/s

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 09 - Public Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
var current_throttle: float = 0.0	# 0.0%
var current_steering: float = 0.0	# 0.0%

var left_wheel_speed: float = 0.0	# cm/s
var right_wheel_speed: float = 0.0	# cm/s

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13 - Built-In Virtual Methods (_process, _physics_process)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13.1 Built-In Virtual _process
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called every frame.
func _process(delta: float) -> void:
	# Desired linear and angular
	var desired_linear: float = current_throttle * max_speed
	var desired_angular: float = current_steering * turn_speed
	
	# Convert to desired wheel speeds (differential drive equations)
	var desired_left: float = desired_linear - desired_angular * wheelbase / 2.0
	var desired_right: float = desired_linear + desired_angular * wheelbase / 2.0
	
	# Apply acceleration limits to each wheel
	left_wheel_speed = move_toward(left_wheel_speed, desired_left, wheel_acceleration * delta)
	right_wheel_speed = move_toward(right_wheel_speed, desired_right, wheel_acceleration * delta)
	
	# Compute actual robot motion from wheel speeds
	var actual_linear: float = (left_wheel_speed + right_wheel_speed) / 2.0
	var actual_angular: float = (right_wheel_speed - left_wheel_speed) / wheelbase
	
	# Update velocity and rotation
	velocity = Vector2(actual_linear, 0).rotated(global_rotation)
	global_rotation += actual_angular * delta
	
	# Execute movement
	move_and_slide()
	
	_send_pos()
	

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 15 - Public Methods
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 15.1 ----- ----- ----- -----
func set_control(throttle: float, steering: float) -> void:
	self.current_throttle = clamp(throttle, -1, 1) 
	self.current_steering = clamp(steering, -1, 1) 

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 16 - Private Methods
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
func _send_pos() -> void:
	EventBus.broadcast_data({
		"type": "pos_update",
		"x": global_position.x,
		"y": global_position.y,
		"theta": global_rotation,
		"timestamp": Time.get_ticks_msec()
		})

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
