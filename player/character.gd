extends CharacterBody3D

const SPEED = 5.0
const ACCELERATION = 0.3
const FRICTION = 0.1
const JUMP_VELOCITY = 4.5


@onready var _spring_arm = $SpringArm
@onready var _camera = $SpringArm/Camera
@onready var _sync = $Sync
@onready var _pivot = $Armature

@onready var _animation_tree = $AnimationTree


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
		_animation_tree.set("parameters/a-g/transition_request","on_air")
		_animation_tree.set("parameters/jump_blend/blend_position", clamp(velocity.y, -1,1))
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		self.velocity.y = JUMP_VELOCITY

	# MOVEMENT
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	if is_on_floor():
		velocity = velocity.move_toward(SPEED * move_direction , ACCELERATION)
		velocity = velocity.move_toward(Vector3.ZERO, FRICTION)
		_animation_tree.set("parameters/a-g/transition_request","on_ground")
		_animation_tree.set("parameters/i-w-r/blend_amount",clamp(velocity.length(), 0 ,1))
	
	# LOOK AT
	if move_direction:
		_pivot.look_at(global_position - move_direction * 100, Vector3.UP)
	
	move_and_slide()
