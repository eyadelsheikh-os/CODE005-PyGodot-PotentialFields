# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 03 - Extends
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
extends Node

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 04 - Document
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# scripts/event_bus.gd
# "/root/EventBus"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 05 - Signals
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
signal control_update(throttle:float, steering:float)
signal demand_data(tag:String)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 07 - Constants
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
const EVENTS: Array[String] = [
	"control_update",
	"pos_update",
	"goal_update",
	"obstacle_update",
	"demand_data",
	]

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 15 - Public Methods
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 15.1 ----- ----- ----- -----
func server_received_data(data: Dictionary) -> void:
	match data.get("type"):
		"control_update":
			control_update.emit(data.throttle, data.steering)
		"demand_data":
			demand_data.emit(data.tag)
		_:
			print("Unknown message type: ", data.get("type"))

# 15.2 ----- ----- ----- -----
func broadcast_data(data: Dictionary) -> void:
	var type: String = data.get("type")
	if type in EVENTS:
		TCPBroadcaster._broadcast_data(data)
	else:
		print("Unknown message type: ", data.get("type"))
	

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
