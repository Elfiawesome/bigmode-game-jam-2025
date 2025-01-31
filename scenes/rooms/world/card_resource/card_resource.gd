class_name CardResource extends Resource

@export var texture: Texture2D
@export var name: String
@export_custom(PROPERTY_HINT_MULTILINE_TEXT, "description") var description: String
@export var power_generation: float
@export var transmission_strength: int = 1
@export var resistance: float
@export var flavor_text: String
