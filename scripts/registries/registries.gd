extends Node

class CategoryRegistry:
	var resources: Dictionary[String, Resource] = {}
	var instances: Dictionary[String, Object] = {}

# Main registry storage
var registries: Dictionary[String, CategoryRegistry] = {}

const MISC := "misc"
const ROOM := "room"
const MENUUI := "menu_ui"
const CARDABILITY := "card_ability"
const CARDRESOURCE := "card_resource"
const ITEMRESOURCE := "item_resource"
const SOUND := "sound"
const TRANSITION := "transition"


func _ready() -> void:
	registries[MISC] = CategoryRegistry.new()
	_auto_load_registries_debug()

func _auto_load_registries_debug() -> void:
	# TODO: This must not be here
	_auto_register_cards()
func _auto_register_cards() -> void:
	var card_resources := _get_all_files_from_directory("res://scenes/rooms/world/card_resource/", "tres")
	for resource in card_resources:
		var card_id := resource.split("/")[-1].split(".")[0]
		Registries.register_resource(Registries.CARDRESOURCE, card_id, load(resource))
	var card_abilities := _get_all_files_from_directory("res://scenes/rooms/world/card_ability/", "gd")
	for ability in card_abilities:
		var card_id := ability.split("/")[-1].split(".")[0]
		if card_id != "card_ability":
			Registries.register_resource(Registries.CARDABILITY, card_id, load(ability))
	var item_resource := _get_all_files_from_directory("res://scenes/rooms/world/item_resource/", "tres")
	for item in item_resource:
		var item_id := item.split("/")[-1].split(".")[0]
		Registries.register_resource(Registries.ITEMRESOURCE, item_id, load(item))
	


func _get_all_files_from_directory(path : String, file_ext:= "gd", files: Array[String] = []) -> Array[String]:
	var resources := ResourceLoader.list_directory(path)
	for res in resources:
		if res.ends_with("/"): 
			_get_all_files_from_directory(path+res, file_ext, files)
		elif file_ext && res.ends_with(file_ext): 
			files.append(path+res)
	return files

func register_resource(category: String, key: String, resource: Resource) -> void:
	_ensure_category_exists(category)
	registries[category].resources[key] = resource

func register_script_instance(category: String, key: String, resource: GDScript) -> void:
	_ensure_category_exists(category)
	registries[category].instances[key] = resource.new()

func register_instance(category: String, key: String, instance: Object) -> void:
	_ensure_category_exists(category)
	registries[category].instances[key] = instance

func get_resource(category: String, key: String) -> Resource:
	if not registries.has(category):
		push_error("Category not found: ", category)
		return null
		
	return registries[category].resources.get(key, null)

func get_instance(category: String, key: String) -> Object:
	if not registries.has(category):
		push_error("Category not found: ", category)
		return null
		
	return registries[category].instances.get(key, null)


func _ensure_category_exists(category: String) -> void:
	if not registries.has(category):
		registries[category] = CategoryRegistry.new()
