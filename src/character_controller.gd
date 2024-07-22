extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO
	
	var child_camera = get_node("camera")
	var forward = child_camera.transform.basis.z
	var right = child_camera.transform.basis.x
	
	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction += right
	if Input.is_action_pressed("move_left"):
		direction -= right
	if Input.is_action_pressed("move_back"):
		direction += forward
	if Input.is_action_pressed("move_forward"):
		direction -= forward
	
	if Input.is_action_just_pressed("jump"):
		target_velocity.y = 10
		
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
