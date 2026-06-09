# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 03 - Extends
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
extends Node
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 04 - Document
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# scripts/tcp_broadcaster.gd
# "/root/TCPBroadcaster"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 07 - Constants
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
const PORT: int = 9999	# SPEAKING/OUTPUT
const MAX_CLIENTS: int = 1
const HEARTBEAT_INTERVAL = 1.0  # Send heartbeat every 1 seconds

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 09 - Public Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
var tcp: TCPServer
var clients: Array[StreamPeerTCP] = []
var last_heartbeat_time = {}  # Dictionary to track last heartbeat per client

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12 - Built-In Virtual Methods (_enter_tree, _ready, _exit_tree)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12.2 Built-In Virtual _ready
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called when both the node and its children have entered the scene tree.
func _ready() -> void:
	_start_server(PORT)

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13 - Built-In Virtual Methods (_process, _physics_process)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 13.2 Built-In Virtual _physics_process
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called every physics frame.
func _physics_process(_delta: float) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert to seconds
	var disconnected = []
	
	# Accept new clients
	if clients.size() < MAX_CLIENTS and tcp.is_connection_available():
		var new_client = tcp.take_connection()
		#new_client.set_no_delay(true)   # Disable Nagle's algorithm
		clients.append(new_client)
		print("New client connected to TCPBroadcaster. Total: ", clients.size())
	
	
	for client in clients:
		# Check if client is still connected
		if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			disconnected.append(client)
			continue
		
		# Heartbeat: Send a tiny ping periodically
		var last_time = last_heartbeat_time.get(client, 0)
		if current_time - last_time > HEARTBEAT_INTERVAL:
			# Send a heartbeat ping
			var heartbeat_msg = JSON.stringify({"type": "heartbeat"}) + "\n"
			var err = client.put_data(heartbeat_msg.to_utf8_buffer())
			
			if err != OK:
				# Heartbeat failed - client is dead
				disconnected.append(client)
				continue
			else:
				# Update last heartbeat time
				last_heartbeat_time[client] = current_time
	
	# Clean up disconnected clients
	for client in disconnected:
		last_heartbeat_time.erase(client)
		clients.erase(client)
		print("A client disconnected from TCPBroadcaster.")
	
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 16 - Private Methods
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 16.1 ----- ----- ----- -----
func _start_server(port: int) -> void:
	tcp = TCPServer.new()
	var err = tcp.listen(port)
	if err == OK:
		print("✅ TCPBroadcaster talking on port ", port)
	else:
		print("❌ Failed to start server on port ", port)


# 16.2 ----- ----- ----- -----
func _broadcast_data(data: Dictionary) -> void:
	if not clients.size():
		print("⚠️ No clients connected, broadcasting failed.")
		return
	
	var json_string = JSON.stringify(data) + "\n"
	var bytes = json_string.to_utf8_buffer()
	
	for client in clients:
			client.put_data(bytes)
	
	print("📡 Broadcast to ", clients.size(), " client/s")
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
