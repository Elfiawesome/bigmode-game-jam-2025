class_name RoomManager extends CanvasLayer

@export var room_nodes: CanvasLayer
@export var transition_nodes: CanvasLayer
var current_room: Room

func _ready() -> void:
	Registries.register_resource(Registries.ROOM, "main_menu", load("res://scenes/rooms/main_menu/main_menu.tscn"))
	Registries.register_resource(Registries.ROOM, "world", load("res://scenes/rooms/world/world.tscn"))
	Registries.register_resource(Registries.TRANSITION, "fade", load("res://scenes/transitions/fade.tscn"))
	
	TransitionManager.transition_nodes = transition_nodes
	change_room(
		"main_menu",
		"fade",
		{"color":Color.BLACK}
	)

func change_room(room_id: String, transition_id: String = "", transition_params: Dictionary[String, Variant] = {}, completion_lamda: Callable = func(_room: Room) -> void: pass) -> void:
	TransitionManager.start_transition(
		transition_id, transition_params,
		func() -> void:
			var new_room: Room = _instantiate_room(room_id)
			if current_room:
				current_room.queue_free()
			room_nodes.add_child(new_room)
			current_room = new_room
			completion_lamda.call(current_room),
		func() -> void: current_room.room_ready()
	)

func _instantiate_room(room_id: String) -> Room:
	var loaded_scene: PackedScene = Registries.get_resource(Registries.ROOM, room_id)
	if loaded_scene == null: return null
	var scene: Room = loaded_scene.instantiate()
	scene.room_manager = self
	return scene
