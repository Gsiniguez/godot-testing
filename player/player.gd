extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var pivot = $CollisionShape3D/Pivot
@onready var mark = $CollisionShape3D/Mark


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	#LOOK AT MOVEMENT
	var future_position = Vector3(pivot.position.x + input_dir.x , 1, pivot.position.z + input_dir.y)
	mark.position = future_position

	pivot.look_at(transform.origin + future_position, Vector3.UP)
	#pivot.look_at(mark.position, Vector3(0,1,0))
	
	move_and_slide()
	rpc("handle_position", position)

@rpc("reliable")
func handle_position(authority_position):
	print("SET GLOBAL POSITION")
	self.position = authority_position

@rpc("reliable")
func handle_rotation(authority_rotation):
	print("SET GLOBAL POSITION")
	self.rotation = authority_rotation
