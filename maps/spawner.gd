extends Node3D

var local_player_character

func _on_network_player_spawned(peer_id):
	print(multiplayer.get_unique_id()," _on_network_player_spawned ",peer_id )
	var player_character = preload("res://player/player.tscn").instantiate()
	player_character.set_multiplayer_authority(peer_id)
	$Label.add_child(player_character)
	$Label.text = str(get_multiplayer_authority())
	if peer_id == multiplayer.get_unique_id():
		local_player_character = player_character
