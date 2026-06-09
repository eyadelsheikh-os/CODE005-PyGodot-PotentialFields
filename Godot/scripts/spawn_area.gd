# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 01 - Tools
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
@tool

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 02 - Class Name
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# SpawnArea

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 03 - Extends
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
extends Node2D

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 04 - Document
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# Defines a rectangular spawn area using two markers. Generates random positions
# within the area and spawns objects. Handles scaling, rotation, and positioning
# correctly regardless of parent transforms.

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 05 - Signals
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
signal positions_generated(positions: Array)
signal objects_spawned(objects: Array)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 06 - Enumerations
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# (No enumerations in this script)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 07 - Constants
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# (No constants in this script)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 08 - Exported Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# Spawn Configuration
@export var object_to_spawn: PackedScene = null
@export var target_parent: Node = null
@export var spawn_count: int = 1

# Generation Behavior
@export var auto_generate_on_ready: bool = false

# Randmization Configuration
@export var use_fixed_seed: bool = true      # Enable deterministic spawns
@export var random_seed: int = 42            # Change this to get different layouts

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 09 - Public Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# (No public variables in this script)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 10 - Private Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
var _marker_left_top: Marker2D
var _marker_right_bottom: Marker2D

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 11 - Onready Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#@warning_ignore("unused_private_class_variable")
#@onready var _color_rect: ColorRect = $ColorRect

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12 - Built-In Virtual Methods (_enter_tree, _ready, _exit_tree)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12.1 Built-In Virtual _enter_tree
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called every time the node enters the scene tree.
#func _enter_tree() -> void:

# ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12.2 Built-In Virtual _ready
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called when both the node and its children have entered the scene tree.
func _ready() -> void:
	# ----- ----- -----
	# Variables
	# ----- ----- -----
	# (No local variables needed)
	
	# ----- ----- -----
	# Algorithm
	# ----- ----- -----
	# 1. Remove visual debug helper
	# _color_rect.queue_free()
	
	# 2. Cache marker references for performance
	_marker_left_top = $Marker1
	_marker_right_bottom = $Marker2
	
	# 3 Set deterministic seed if enabled
	if use_fixed_seed:
		seed(random_seed)
	else:
		randomize()   # optional: ensure true randomness when seed = 0
	
	# 4. Auto-generate if enabled
	if auto_generate_on_ready:
		# Use call_deferred to avoid "busy setting up children" error
		call_deferred("generate_and_spawn_objects")
	
	return

# ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12.3 Built-In Virtual _exit_tree
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called when the node is about to leave the scene tree, after all its children
# received the _exit_tree() callback.
#func _exit_tree() -> void:

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13 - Built-In Virtual Methods (_process, _physics_process)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13.1 Built-In Virtual _process
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called every frame.
#func _process(_delta: float) -> void:

# ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13.2 Built-In Virtual _physics_process
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called every physics frame.
#func _physics_process(_delta: float) -> void:

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 14 - Built-In Virtual Methods (_unhandled_input, _input)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 14.1 Built-In Virtual _unhandled_input
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called once for every event.
#func _unhandled_input(_event: InputEvent) -> void:

# ----- ----- ----- ----- ----- ----- ----- ----- -----
# 14.2 Built-In Virtual _input
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called once for every event before _unhandled_input(), allowing you to
# consume some events.
#func _input(_event: InputEvent) -> void:

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 15 - Public Methods
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 15.1 ----- ----- ----- -----
# Generates a single random position within the spawn area.
func get_random_spawn_position() -> Vector2:
	# ----- ----- -----
	# Variables
	# ----- ----- -----
	var local_position: Vector2
	var global_position_result: Vector2
	
	# ----- ----- -----
	# Algorithm
	# ----- ----- -----
	# 1. Generate random local position within rectangle bounds
	local_position.x = randf_range(_marker_left_top.position.x, _marker_right_bottom.position.x)
	local_position.y = randf_range(_marker_left_top.position.y, _marker_right_bottom.position.y)
	
	# 2. Apply scaling
	local_position.x *= scale.x
	local_position.y *= scale.y
	
	# 3. Apply rotation
	local_position = local_position.rotated(rotation)
	
	# 4. Apply translation
	global_position_result = local_position + position
	
	return global_position_result


# 15.2 ----- ----- ----- -----
# Generates an array of random positions within the spawn area.
func generate_spawn_positions(count: int) -> Array[Vector2]:
	# ----- ----- -----
	# Variables
	# ----- ----- -----
	var positions: Array[Vector2] = []
	
	# ----- ----- -----
	# Algorithm
	# ----- ----- -----
	for i in range(count):
		positions.append(get_random_spawn_position())
	
	return positions


# 15.3 ----- ----- ----- -----
# Spawns objects at the given positions.
func spawn_objects_at_positions(positions: Array[Vector2]) -> Array:
	# ----- ----- -----
	# Variables
	# ----- ----- -----
	var spawned_instances: Array = []
	var parent_node: Node = target_parent if target_parent != null else get_parent()
	
	# ----- ----- -----
	# Algorithm
	# ----- ----- -----
	# 1. Validate object to spawn
	if object_to_spawn == null:
		push_warning("SpawnArea: object_to_spawn is null, cannot spawn objects")
		return spawned_instances
	
	# 2. Spawn instances
	for spawn_position in positions:
		var new_instance = object_to_spawn.instantiate()
		new_instance.position = spawn_position
		
		# Use call_deferred to avoid "busy setting up children" error
		if Engine.is_editor_hint():
			parent_node.add_child(new_instance)
		else:
			parent_node.call_deferred("add_child", new_instance)
		
		spawned_instances.append(new_instance)
	
	# 3. Emit signal
	objects_spawned.emit(spawned_instances)
	
	return spawned_instances


# 15.4 ----- ----- ----- -----
# Generates positions and spawns objects in one operation.
func generate_and_spawn_objects() -> Array:
	# ----- ----- -----
	# Variables
	# ----- ----- -----
	var positions: Array[Vector2] = []
	var spawned_instances: Array = []
	
	# ----- ----- -----
	# Algorithm
	# ----- ----- -----
	if spawn_count > 0:
		positions = generate_spawn_positions(spawn_count)
		positions_generated.emit(positions)
		
		if object_to_spawn != null:
			spawned_instances = spawn_objects_at_positions(positions)
	
	return spawned_instances


# 15.5 ----- ----- ----- -----
# Generates and spawns with custom parameters (overrides defaults).
func spawn_with_custom_settings(spawn_amount: int = -1, custom_scene: PackedScene = null, custom_parent: Node = null) -> Array:
	# ----- ----- -----
	# Variables
	# ----- ----- -----
	var final_spawn_count: int = spawn_amount if spawn_amount > 0 else spawn_count
	var scene_to_use: PackedScene = custom_scene if custom_scene != null else object_to_spawn
	var parent_node: Node = custom_parent if custom_parent != null else target_parent
	var positions: Array[Vector2] = []
	var spawned_instances: Array = []
	
	# ----- ----- -----
	# Algorithm
	# ----- ----- -----
	# 1. Set default parent if needed
	if parent_node == null:
		parent_node = get_parent()
	
	# 2. Generate positions
	if final_spawn_count > 0:
		positions = generate_spawn_positions(final_spawn_count)
		positions_generated.emit(positions)
		
		# 3. Spawn objects
		if scene_to_use != null:
			for spawn_position in positions:
				var new_instance = scene_to_use.instantiate()
				new_instance.position = spawn_position
				
				if Engine.is_editor_hint():
					parent_node.add_child(new_instance)
				else:
					parent_node.call_deferred("add_child", new_instance)
				
				spawned_instances.append(new_instance)
			
			objects_spawned.emit(spawned_instances)
	
	return spawned_instances


# 15.6 ----- ----- ----- -----
# Immediate spawn without deferred calls (use with caution).
func spawn_immediately() -> Array:
	# ----- ----- -----
	# Variables
	# ----- ----- -----
	var positions: Array[Vector2] = []
	var spawned_instances: Array = []
	var parent_node: Node = target_parent if target_parent != null else get_parent()
	
	# ----- ----- -----
	# Algorithm
	# ----- ----- -----
	# Warning: Only safe when not called during _ready
	if spawn_count > 0 and object_to_spawn != null:
		positions = generate_spawn_positions(spawn_count)
		positions_generated.emit(positions)
		
		for spawn_position in positions:
			var new_instance = object_to_spawn.instantiate()
			new_instance.position = spawn_position
			parent_node.add_child(new_instance)
			spawned_instances.append(new_instance)
		
		objects_spawned.emit(spawned_instances)
	
	return spawned_instances


# 15.7 ----- ----- ----- -----
# Set the scene to spawn.
func set_spawn_scene(packed_scene: PackedScene) -> void:
	object_to_spawn = packed_scene


# 15.8 ----- ----- ----- -----
# Set the parent node for spawned objects.
func set_spawn_parent(node: Node) -> void:
	target_parent = node


# 15.9 ----- ----- ----- -----
# Set how many objects to spawn.
func set_spawn_count(count: int) -> void:
	spawn_count = max(1, count)


# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 16 - Private Methods
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# (No private methods in this script)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
