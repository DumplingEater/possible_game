extends Node

signal set_buildable

@onready var grid_container = $buildable_grid
var buildable_item_container: Node = null
var buildables: Array = []
var building: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

	buildable_item_container = get_tree().get_nodes_in_group("buildable_library")[0]
	self.buildables = buildable_item_container.buildable_scenes
	self._create_buttons()
	
	var player: Node = get_tree().get_nodes_in_group("players")[0]
	var buildable_controller = player.get_parent().get_node("building_controller")
	var result = buildable_controller.connect("build_mode_toggled", self._on_build_mode_toggled)
	if result != OK:
		push_error("problem connecting build mode toggle to ui")
	result = buildable_controller.connect("build_menu_toggled", self._on_build_menu_toggled)
	if result != OK:
		push_error("problem connecting build menu toggle signal to menu scene")

func _create_buttons():
	for i in range(self.buildables.size()):
		var buildable_scene: PackedScene = self.buildables[i]
		var button: Button = Button.new()
		button.text = buildable_scene.resource_path.get_file().get_basename()
		grid_container.add_child(button)
		
		button.pressed.connect(self._on_buildable_clicked.bind(i))
	
	# We use Signal.connect() again, and we also use the Callable.bind() method,
	# which returns a new Callable with the parameter binds.
	#player.hit.connect(_on_player_hit.bind("sword", 100))

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_build_menu_toggled(value: bool = true):
	self.visible = value

func _on_build_mode_toggled(value: bool):
	self.building = value
	
func _on_buildable_clicked(buildable_index: int):
	set_buildable.emit(self.buildables[buildable_index])
	self._on_build_menu_toggled(false)
