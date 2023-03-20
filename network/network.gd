extends Node

signal player_spawned

const PORT = 3005

var peer = ENetMultiplayerPeer.new()
var connected_peer_ids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if DisplayServer.get_name() == "headless":
		print("Iniciando servidor dedicado en el puerto " + str(PORT) + "...")
		_on_host_pressed().call()


func _on_host_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Error al iniciar servidor dedicado")
		return
	
	#HOOKS
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)
	
	emit_signal("player_spawned", multiplayer.get_unique_id())
	connected_peer_ids.append(multiplayer.get_unique_id())
	$NetworkUI.hide()

func _on_join_pressed():
	peer.create_client("127.0.0.1", PORT)
	multiplayer.multiplayer_peer = peer
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Error al conectarse al servidor deidcado")
		return
	
	$NetworkUI.hide()


func _on_peer_connected(new_peer_id):
	print("New Connection: ", new_peer_id)
	await get_tree().create_timer(1).timeout
	rpc("add_player", new_peer_id)
	rpc_id(new_peer_id, "add_others_players", connected_peer_ids)
	#SERVER
	emit_signal("player_spawned", new_peer_id)
	
@rpc
func add_player(new_peer_id):
	connected_peer_ids.append(new_peer_id)	
	emit_signal("player_spawned", new_peer_id)


@rpc
func add_others_players(peer_ids):
	for peer_id in peer_ids:
		emit_signal("player_spawned", peer_id)

func _on_peer_disconnected(new_peer_id):
	print("Lost Connection: ", new_peer_id)
	pass
