extends Node

var Player = preload("res://player/player.tscn")
var Character = preload("res://player/character.tscn")
const PORT = 3005

var peer = ENetMultiplayerPeer.new()

var players = {}
@onready var tab_menu_players = $TabMenu/TabMenu_MarginContainer/TabMenu_Players

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
	
	instantiate_player()
	$NetworkUI.hide()

func _on_join_pressed():
	peer.create_client("127.0.0.1", PORT)
	multiplayer.multiplayer_peer = peer
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Error al conectarse al servidor deidcado")
		return
	
	$NetworkUI.hide()


func _on_peer_connected(id):
	print("New Connection: ", id)
	await get_tree().create_timer(2).timeout
	instantiate_player(id)
	
	#await get_tree().create_timer(1).timeout
	#CALL A TODOS LOS PEER
	#rpc("setNewPLayer", id)
	#CALL A UN PEER
	#rpc_id(id, "setNewPLayers", players)
	
	var nameLabel = Label.new()
	nameLabel.name = str(id)
	nameLabel.text = str(id)
	tab_menu_players.add_child(nameLabel)


@rpc
func setNewPLayer(id):
	pass

@rpc
func setNewPLayers(player_list):
	for id in player_list:
		var nameLabel = Label.new()
		nameLabel.name = str(id)
		nameLabel.text = str(id)
		tab_menu_players.add_child(nameLabel)

func _on_peer_disconnected(id):
	print("Lost Connection: ", id)
	remove_child(players[id])
	tab_menu_players.remove_child(players[id])


func instantiate_player(id = 1):
	var player = Character.instantiate()
	player.name = str(id)
	players[id] = player
	add_child(player)
