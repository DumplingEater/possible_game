extends Label

@export var player_data: Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	player_data = get_parent().get_parent().get_node("data")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.text = "Health:   %s / %s" % [player_data.health, player_data.max_health]
	get_node("health_bar").value = (player_data.health / player_data.max_health ) * 100
