# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 03 - Extends
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
extends Node

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 04 - Document
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# scripts/input_handler.gd
# "/root/Main/Robot/InputHandler"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 11 - Onready Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
@onready var robot: CharacterBody2D = get_parent()

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12 - Built-In Virtual Methods (_enter_tree, _ready, _exit_tree)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12.2 Built-In Virtual _ready
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called when both the node and its children have entered the scene tree.
func _ready():
	EventBus.control_update.connect(robot.set_control)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 14 - Built-In Virtual Methods (_unhandled_input, _input)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 14.2 Built-In Virtual _input
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called once for every event before _unhandled_input(), allowing you to
# consume some events. For instant response on key press/release
func _input(_event: InputEvent) -> void:
	if not robot:
		return
	
	var throttle: float = Input.get_axis("backward", "forward")  # -1 to 1 (both pressed = 0)
	var steering: float = Input.get_axis("steer_right", "steer_left")  # note reversed order
	
	robot.set_control(throttle, steering)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
