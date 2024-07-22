extends Node

@export var max_health: float = 100
@export var health: float = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("players")
	get_parent().get_node("body_3d").add_to_group("players")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func apply_damage(damage: float):
	health -= damage
	print("Health is now ", health)
