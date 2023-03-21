extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var _pivot = $CollisionShape3D/Pivot
@onready var _camera = $SpringArm/Camera
@onready var _sync = $Sync
@onready var _spring_arm = $SpringArm

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	_sync.set_multiplayer_authority(str(name).to_int())
	_camera.current = _sync.is_multiplayer_authority()

func _physics_process(delta):
	if not _sync.is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		self.velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		self.velocity.y = JUMP_VELOCITY

	# MOVEMENT
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	velocity.x = move_direction.x * SPEED
	velocity.z = move_direction.z * SPEED
	
	# LOOK AT
	_pivot.look_at(global_position + move_direction * 100, Vector3.UP)
	
	move_and_slide()
