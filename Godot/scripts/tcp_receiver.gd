# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 03 - Extends
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
extends Node
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 04 - Document
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# scripts/tcp_reciever.gd
# "/root/TCPReceiver"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 07 - Constants
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
const PORT: int = 9998	# LISTENING/INPUT
const MAX_CLIENTS: int = 1
const HEARTBEAT_INTERVAL = 1.0  # Send heartbeat every 1 seconds

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 09 - Public Variables
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
var tcp: TCPServer
var clients: Array[StreamPeerTCP] = []
var receive_buffers: Dictionary = {}  # Store partial messages per client
var last_heartbeat_time = {}  # Dictionary to track last heartbeat per client

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12 - Built-In Virtual Methods (_enter_tree, _ready, _exit_tree)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 12.2 Built-In Virtual _ready
# ----- ----- ----- ----- ----- ----- ----- ----- -----
# Called when both the node and its children have entered the scene tree.
func _ready():
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
		var new_client: StreamPeerTCP = tcp.take_connection()
		new_client.set_no_delay(true)   # Disable Nagle's algorithm
		clients.append(new_client)
		receive_buffers[new_client] = ""  # Initialize buffer for this client
		print("New client connected to TCPReceiver. Total: ", clients.size())
	
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
		
		# Process normal data
		_process_client_data(client)
	
	# Clean up disconnected clients
	for client in disconnected:
		receive_buffers.erase(client)
		last_heartbeat_time.erase(client)
		clients.erase(client)
		print("A client disconnected from TCPReceiver.")
	


# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 16 - Private Methods
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# 16.1 ----- ----- ----- -----
func _start_server(port: int) -> void:
	tcp = TCPServer.new()
	var err = tcp.listen(port)
	if err == OK:
		print("✅ TCPReceiver listening on port ", port)
	else:
		print("❌ Failed to start server on port ", port)


# 16.2 ----- ----- ----- -----
func _process_client_data(client: StreamPeerTCP) -> void:
	var bytes_available = client.get_available_bytes()
	if bytes_available > 0:
		# Read raw data
		var data = client.get_data(bytes_available)
		if data[0] == OK:
			# Append to buffer for this client
			var received_text = data[1].get_string_from_utf8()
			receive_buffers[client] += received_text
			
			# Process complete messages (separated by newline)
			var buffer = receive_buffers[client]
			var newline_pos = buffer.find("\n")
			
			while newline_pos != -1:
				# Extract one complete message (without the newline)
				var message_json = buffer.substr(0, newline_pos)
				buffer = buffer.substr(newline_pos + 1)
				
				# Process the message if not empty
				if message_json.strip_edges() != "":
					_handle_message(message_json)
				
				# Look for next newline
				newline_pos = buffer.find("\n")
			
			# Save remaining incomplete data back to buffer
			receive_buffers[client] = buffer


# 16.3 ----- ----- ----- -----
func _handle_message(json_string: String) -> void:
	var data = JSON.parse_string(json_string)
	
	if data != null:
		print("📥 Received: ", data)
		
		# Emit to event bus
		EventBus.server_received_data(data)  # Note: fixed typo "recieved" -> "received"
	else:
		print("❌ Failed to parse JSON: ", json_string)
		print("   First 50 chars: ", json_string.substr(0, 50))

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
