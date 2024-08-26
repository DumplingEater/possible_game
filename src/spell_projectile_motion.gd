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
	if body == get_parent().target:
		var data_node = body.get_parent().get_node("data")
		if data_node:
			data_node.apply_damage(get_parent().damage)
			# Handle the collision (e.g., apply damage, destroy the projectile, etc.)
		else:
			push_error("Spell hit node with no data node or whatever idk. this thing doesn't have a script to take damage")
		get_parent().queue_free()  # Example: Remove the projectile
		
