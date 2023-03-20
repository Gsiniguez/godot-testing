extends Node3D


func _physics_process(_delta):
	if is_multiplayer_authority():
		rpc("handle_position", position)
		var direction:Vector3 = Vector3.ZERO
		
		if Input.is_key_pressed(KEY_W): direction.z -= 1
		if Input.is_key_pressed(KEY_S): direction.z += 1
		if Input.is_key_pressed(KEY_A): direction.x -= 1
		if Input.is_key_pressed(KEY_D): direction.x += 1
		
		global_position += direction.normalized()


@rpc("authority")
func handle_position(authority_position):
	print("SET GLOBAL POSITION")
	self.position = authority_position
