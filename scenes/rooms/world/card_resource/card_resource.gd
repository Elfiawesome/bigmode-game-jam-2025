class_name CardResource extends Resource

@export var texture: Texture2D
@export var name: String
@export var resistance: float = 0.0
@export var power_output: float = 0.0
@export var transmission_strength: int = 1
@export var can_generate_power: bool = true

@export_custom(PROPERTY_HINT_MULTILINE_TEXT, "ability_description") var ability_description: String

# Looks
@export var rarity: Rarity = Rarity.COMMON
@export var custom_card_back: Texture2D = preload("res://assets/texture/card_back/desaturated_card_shadow_slice.png")
@export var flavor_text: String

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
	NONE,
}
const rarity_color:Dictionary[Rarity, Color] = {
	Rarity.COMMON: Color("#DCFFEE"),
	Rarity.UNCOMMON: Color("#C5DCFF"),
	Rarity.RARE: Color("#DCC5FF"),
	Rarity.LEGENDARY: Color("#FFEEC5"),
	Rarity.NONE: Color.WHITE
}
const rarity_name:Dictionary[Rarity, String] = {
	Rarity.COMMON: "Common",
	Rarity.UNCOMMON: "Uncommon",
	Rarity.RARE: "Rare",
	Rarity.LEGENDARY: "Legendary",
	Rarity.NONE: "None"
}

static func format_card_text(original_text: String) -> String:
	var processed_text := original_text
	var card_regex := RegEx.new()
	card_regex.compile("\\[CARD:(.+?)\\]")
	for match_result in card_regex.search_all(processed_text):
		var full_match := match_result.get_string()
		var card_id := match_result.get_string(1)
		var resource:CardResource = Registries.get_resource(Registries.CARDRESOURCE, card_id)
		var img_path := resource.texture.resource_path
		var card_name := resource.name
		processed_text = processed_text.replace(full_match, "%s [img=3,3]%s[/img]" % [card_name, img_path])
	
	# Replace [POWER] tags
	processed_text = processed_text.replace("[POWER]", "[img=1,1]res://assets/texture/icons/energy.png[/img]")
	processed_text = processed_text.replace("[RESISTANCE]", "[img=1,1]res://assets/texture/icons/resistance.png[/img]")
	processed_text = processed_text.replace("[TRANSMISSION]", "[img=1,1]res://assets/texture/icons/transmission_strength.png[/img]")
	
	return processed_text
