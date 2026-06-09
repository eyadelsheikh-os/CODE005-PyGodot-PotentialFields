# tcp_client.py
import socket
import json
import threading
from typing import Callable, Optional, Dict, Any

class TCPClient:
    """Base TCP client with JSON message handling (newline terminated)."""
    
    def __init__(self, host: str = 'localhost', port: int = 9999):
        self.host = host
        self.port = port
        self.sock: Optional[socket.socket] = None
        self._lock = threading.Lock()
    
    def connect(self) -> bool:
        """Connect to server. Returns True on success."""
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.connect((self.host, self.port))
            print(f"✅ Connected to {self.host}:{self.port}")
            return True
        except ConnectionRefusedError:
            print(f"❌ Cannot connect to {self.host}:{self.port} - server not running?")
            return False
        except Exception as e:
            print(f"❌ Connection error: {e}")
            return False
    
    def send(self, data: Dict[str, Any]) -> bool:
        """Send JSON data to server."""
        if not self.sock:
            return False
        try:
            json_str = json.dumps(data) + "\n"
            with self._lock:
                self.sock.sendall(json_str.encode('utf-8'))
            return True
        except Exception as e:
            print(f"❌ Send failed: {e}")
            return False
    
    def close(self):
        """Close connection."""
        if self.sock:
            try:
                with self._lock:
                    self.sock.close()
            except:
                pass
            self.sock = None
    
    def __enter__(self):
        self.connect()
        return self
    
    def __exit__(self, *args):
        self.close()


class TCPBroadcaster(TCPClient):
    """
    Use this when you ONLY send data (don't receive).
    
    Example:
        broadcaster = TCPBroadcaster(port=9999)
        broadcaster.connect()
        broadcaster.send({"type": "slam", "data": 123})
        broadcaster.close()
    """
    
    def __init__(self, host: str = 'localhost', port: int = 9999):
        super().__init__(host, port)
        print(f"📡 TCPBroadcaster initialized for port {port}")
    
    def broadcast(self, data: Dict[str, Any]) -> bool:
        """Alias for send() - makes intent clearer."""
        return self.send(data)


class TCPReceiver(TCPClient):
    """
    Use this when you ONLY receive data (don't send).
    
    Example:
        def handle_message(msg):
            print(f"Got: {msg}")
        
        receiver = TCPReceiver(port=9998)
        receiver.connect()
        receiver.start_receiving(handle_message)
        # ... do other work ...
        receiver.stop_receiving()
        receiver.close()
    """
    
    def __init__(self, host: str = 'localhost', port: int = 9999):
        super().__init__(host, port)
        self._receive_thread: Optional[threading.Thread] = None
        self._stop_receive = threading.Event()
        print(f"🎧 TCPReceiver initialized for port {port}")
    
    def start_receiving(self, callback: Callable[[Dict[str, Any]], None]):
        """Start background thread to receive messages."""
        if not self.sock:
            print("❌ Connect first before receiving.")
            return
        
        if self._receive_thread and self._receive_thread.is_alive():
            print("Already receiving...")
            return
        
        self._stop_receive.clear()
        self._receive_thread = threading.Thread(
            target=self._receive_loop, 
            args=(callback,), 
            daemon=True
        )
        self._receive_thread.start()
    
    def stop_receiving(self):
        """Stop the receiving thread."""
        self._stop_receive.set()
        if self._receive_thread and self._receive_thread.is_alive():
            self._receive_thread.join(timeout=1.0)
    
    def _receive_loop(self, callback: Callable):
        """Internal: read messages and call callback."""
        buffer = ""
        while not self._stop_receive.is_set():
            try:
                with self._lock:
                    if not self.sock:
                        break
                    data = self.sock.recv(4096)
                
                if not data:
                    print("Server disconnected.")
                    break
                
                buffer += data.decode('utf-8')
                
                # Process complete lines
                while '\n' in buffer:
                    line, buffer = buffer.split('\n', 1)
                    line = line.strip()
                    if line:
                        try:
                            callback(json.loads(line))
                        except json.JSONDecodeError as e:
                            print(f"❌ Invalid JSON: {e}")
                            
            except Exception as e:
                if not self._stop_receive.is_set():
                    print(f"❌ Receive error: {e}")
                break
        
        print("Receive loop ended.")
    
    def close(self):
        """Close connection and stop receiving."""
        self.stop_receiving()
        super().close()











