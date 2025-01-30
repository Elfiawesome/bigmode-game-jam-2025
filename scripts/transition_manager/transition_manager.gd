extends Node

var transition_nodes: CanvasLayer

func start_transition(
		transition_id: String,
		transition_params: Dictionary[String, Variant] = {},
		swap_func: Callable = func() -> void: pass,
		completion_func: Callable = func() -> void: pass
	) -> void:
	if transition_id != "":
		var new_transition: Transition = _instantiate_transition(transition_id)
		new_transition.set_params(transition_params)
		transition_nodes.add_child(new_transition)
		new_transition.transition_swap.connect(swap_func)
		new_transition.transition_completed.connect(completion_func)
	else:
		swap_func.call()
		completion_func.call()

func _instantiate_transition(transition_id: String) -> Transition:
	var loaded_scene: Resource = Registries.get_resource(Registries.TRANSITION, transition_id)
	if loaded_scene is PackedScene:
		var scene: Transition = loaded_scene.instantiate()
		return scene
	return
