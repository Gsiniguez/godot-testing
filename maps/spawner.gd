extends Node3D

var Player = preload("res://player/player.tscn")
@onready var players = $"../PanelContainer/MarginContainer/Players"

func _on_network_player_spawned(peer_id):
	var player = Player.instantiate()
	player.set_multiplayer_authority(peer_id)
	player.name = str(peer_id)
	add_child(player)
	var lab = Label.new()
	lab.text = str(peer_id)
	lab.name = str(peer_id)
	players.add_child(lab)
