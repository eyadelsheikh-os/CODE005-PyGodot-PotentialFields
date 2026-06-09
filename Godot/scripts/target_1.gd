

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 03 - Extends
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
extends Node2D

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 04 - Document
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# scripts/target_1.gd
# "/root/Main/Target1"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12 - Built-In Virtual Methods (_enter_tree, _ready, _exit_tree)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12.2 Built-In Virtual _ready
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called when both the node and its children have entered the scene tree.
func _ready() -> void:
	EventBus.demand_data.connect(_send_pos)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 14 - Built-In Virtual Methods (_unhandled_input, _input)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 14.2 Built-In Virtual _input
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called once for every event before _unhandled_input(), allowing you to
# consume some events. For instant response on key press/release
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		position = get_global_mouse_position()
		_send_pos()

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 16 - Private Methods
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
func _send_pos(tag: String = "goal_update") -> void:
	if tag == "goal_update":
		EventBus.broadcast_data({
			"type": "goal_update",
			"x": global_position.x,
			"y": global_position.y,
			})
		print("goal sent")
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
