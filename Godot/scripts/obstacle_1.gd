# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 03 - Extends
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
extends Area2D

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 04 - Document
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# scripts/obstacle_1.gd
# "/root/Main/Obstacles/Obstacle1"
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 10 - Private Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
var _dragging: bool = false
var _mouse_over = false
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12 - Built-In Virtual Methods (_enter_tree, _ready, _exit_tree)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12.2 Built-In Virtual _ready
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called when both the node and its children have entered the scene tree.
func _ready() -> void:
	EventBus.demand_data.connect(_send_pos)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13 - Built-In Virtual Methods (_process, _physics_process)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13.1 Built-In Virtual _process
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called every frame.
func _process(_delta: float) -> void:
	if _dragging:
		global_position = get_global_mouse_position()
		_send_pos()

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 14 - Built-In Virtual Methods (_unhandled_input, _input)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 14.2 Built-In Virtual _input
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called once for every event before _unhandled_input(), allowing you to
# consume some events. For instant response on key press/release
func _input(event: InputEvent) -> void:
	if _mouse_over:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
			else:
				_dragging = false

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 16 - Private Methods
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 16.1 ----- ----- ----- -----
func _send_pos(tag: String = "obstacle_update") -> void:
	if tag == "obstacle_update":
		EventBus.broadcast_data({
			"type": "obstacle_update",
			"name": self.get_name(),
			"x": global_position.x,
			"y": global_position.y,
			"r": 200,
			})

# 16.2 ----- ----- ----- -----
func _on_mouse_entered():
	_mouse_over = true

# 16.3 ----- ----- ----- -----
func _on_mouse_exited():
	_mouse_over = false
	
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

