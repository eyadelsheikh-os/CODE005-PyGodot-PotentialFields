# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 02 - Class Name
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
class_name MotionTrail

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 03 - Extends
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
extends Line2D

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 04 - Document
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# scripts/motion_trail.gd
# "/root/Main/Robot/MotionTrail"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 08 - Exported Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
@export var max_length: int = 2000
@export var add_distance: float = 5.0
@export var min_distance: float = 2.0

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 10 - Private Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
var _parent_node: Node2D
var _distance_since_last: float = 0.0
var _last_position: Vector2

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12 - Built-In Virtual Methods (_enter_tree, _ready, _exit_tree)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12.2 Built-In Virtual _ready
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called when both the node and its children have entered the scene tree.
func _ready() -> void:
	_parent_node = get_parent()
	_last_position = _parent_node.global_position
	add_point(_last_position)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13 - Built-In Virtual Methods (_process, _physics_process)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13.2 Built-In Virtual _physics_process
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called every physics frame.
func _process(_delta: float) -> void:
	if not _parent_node:
		return
	
	var current_pos: Vector2 = _parent_node.global_position
	var moved: float = current_pos.distance_to(_last_position)
	
	if moved >= min_distance:
		_distance_since_last += moved
		
		if _distance_since_last >= add_distance:
			add_point(current_pos)
			_distance_since_last = 0.0
			
			while get_point_count() > max_length:
				remove_point(0)
			
			_last_position = current_pos

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
