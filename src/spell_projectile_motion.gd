extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self._on_Area3D_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var dir = get_parent().target.global_transform.origin - self.global_transform.origin
	dir = dir.normalized()
	self.global_transform = self.global_transform.translated(dir * delta * get_parent().speed)
	
func _on_Area3D_body_entered(body):
	if body.is_in_group("players"):
		var data_node = body.get_parent().get_node("data")
		data_node.apply_damage(get_parent().damage)
		# Handle the collision (e.g., apply damage, destroy the projectile, etc.)
		get_parent().queue_free()  # Example: Remove the projectile
