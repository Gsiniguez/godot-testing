extends Node3D


func _on_network_player_spawned(peer_id):
	var player_character = preload("res://player/player.tscn").instantiate()
	player_character.set_multiplayer_authority(peer_id)
	add_child(player_character)
