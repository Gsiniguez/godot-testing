extends Node

const PORT = 3005

var connected_peer_ids = []

signal player_spawned

var local_player_character

# Called when the node enters the scene tree for the first time.
func _ready():
	if DisplayServer.get_name() == "headless":
		print("Iniciando servidor dedicado en el puerto " + str(PORT) + "...")
		_on_host_pressed().call()


func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Error al iniciar servidor dedicado")
		return
	
	#HOOKS
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)
	
	multiplayer.multiplayer_peer = peer
	emit_signal("player_spawned", 1)
	connected_peer_ids.append(peer.get_unique_id())
	$NetworkUI.hide()

func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", PORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Error al conectarse al servidor deidcado")
		return
	
	multiplayer.multiplayer_peer = peer
	$NetworkUI.hide()


func _on_peer_connected(new_peer_id):
	print("New Connection: ", new_peer_id)
	await get_tree().create_timer(1).timeout
	rpc("add_player", new_peer_id)
	rpc_id(new_peer_id, "add_others_players", connected_peer_ids)
	#SERVER
	#emit_signal("player_spawned", new_peer_id)
	
@rpc
func add_player(new_peer_id):
	connected_peer_ids.append(new_peer_id)	
	emit_signal("player_spawned", new_peer_id)
	
	$NetworkUI/Players/Label.text += ' ' + str(new_peer_id)
	
@rpc
func add_others_players(peer_ids):
	for peer_id in peer_ids:
		connected_peer_ids.append(peer_id)
		emit_signal("player_spawned", peer_id)

func _on_peer_disconnected(new_peer_id):
	print("Lost Connection: ", new_peer_id)
	pass
