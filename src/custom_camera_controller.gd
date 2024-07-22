extends Node3D

@export var move_speed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_W):
		position.z -= move_speed
	if Input.is_key_pressed(KEY_S):
		position.z += move_speed
	if Input.is_key_pressed(KEY_A):
		position.x += move_speed
	if Input.is_key_pressed(KEY_D):
		position.x -= move_speed
	if Input.is_key_pressed(KEY_Q):
		position.y += move_speed
	if Input.is_key_pressed(KEY_E):
		position.y -= move_speed
	
		
