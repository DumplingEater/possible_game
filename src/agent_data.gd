extends Node

@export var is_player: bool = false
@export var is_instance_owner: bool = false  # is this the player running this instance of the game


@export var max_health: float = 100
@export var health: float = 100
var alive: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("players")
	#get_parent().get_node("body_3d").add_to_group("players")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func apply_damage(damage: float):
	health -= damage
	if health <= 0:
		print("dead")
