extends Room
@onready var metal_panel_button: Control = $CanvasLayer/VBoxContainer/MarginContainer/MetalPanelButton

@onready var image_1: TextureRect = $CanvasLayer/VBoxContainer/HBoxContainer/Image1
@onready var image_2: TextureRect = $CanvasLayer/VBoxContainer/HBoxContainer/Image2
@onready var image_3: TextureRect = $CanvasLayer/VBoxContainer/HBoxContainer/Image3

var tween: Tween

func _ready() -> void:
	metal_panel_button.clicked.connect(
		func() -> void:
			room_manager.change_room("world", "fade")
	)
	animate()
	change_bg_color()

func animate() -> void:
	tween = get_tree().create_tween().set_parallel(true)
	var images: Array[TextureRect]= [image_1,image_2,image_3]
	for image in images:
		var delay := randf_range(2,5)
		tween.tween_property(image, "modulate:a", 0.0, 1).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(image, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_CIRC)
		tween.tween_callback(change_texture.bind(image)).set_delay(delay)
		tween.tween_property(image, "modulate:a", 1.0, 1).set_trans(Tween.TRANS_CIRC).set_delay(delay)
		tween.tween_property(image, "scale", Vector2.ONE, 1).set_trans(Tween.TRANS_CIRC)
	tween.chain()
	tween.finished.connect(
		func() -> void:
			animate()
	)

func get_random_card_id() -> String:
	var cards:Array = Registries.registries[Registries.CARDRESOURCE].resources.keys()
	cards.erase("end_power_depot")
	return cards.pick_random()

var bg_tween: Tween
var bg_stripe_color_dark: Color = Color("1f1200"):
	set(value):
		var bg:ColorRect = $CanvasLayer/Bg
		var bg_material: ShaderMaterial = bg.material
		bg_material.set_shader_parameter("color_one", value)
		bg_stripe_color_dark = value
var bg_stripe_color_light: Color = Color("663b00"):
	set(value):
		var bg:ColorRect = $CanvasLayer/Bg
		var bg_material: ShaderMaterial = bg.material
		bg_material.set_shader_parameter("color_two", value)
		bg_stripe_color_light = value

func change_bg_color() -> void:
	if bg_tween: bg_tween.kill()
	
	var new_colors := generate_new_color([bg_stripe_color_light, bg_stripe_color_dark])
	bg_tween = get_tree().create_tween()
	bg_tween.set_parallel(true)
	bg_tween.tween_property(self, "bg_stripe_color_dark", new_colors[1], 3).\
		set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	bg_tween.tween_property(self, "bg_stripe_color_light", new_colors[0], 3).\
		set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	bg_tween.finished.connect(
		change_bg_color
	)

func generate_new_color(colors: Array[Color]) -> Array[Color]:
	var new_colors: Array[Color]
	
	for color in colors:
		var variance := 0.1
		var new_color_1 := Color.from_hsv(
			color.h + randf_range(-variance, variance),
			color.s + randf_range(-variance, variance),
			min(color.v + randf_range(-variance, variance), 0.5)
		)
		new_color_1.lightened(randf_range(-variance, variance))
		new_colors.push_back(new_color_1)
	return new_colors

func change_texture(texture_item: TextureRect) -> void:
	var card_id := get_random_card_id()
	texture_item.texture = Registries.get_resource(Registries.CARDRESOURCE, card_id).texture
