extends Transition

var animation_stage: int = 0
var fade_speed: float = 3.0
var fade_color: Color = Color.BLACK
@onready var fade_rect: ColorRect = $ColorRect

func _ready() -> void:
	pass

func set_params(params: Dictionary[String, Variant]) -> void:
	if params.has("color"): fade_color = params["color"]
	if params.has("speed"): fade_speed = params["speed"]

func _process(delta: float) -> void:
	match animation_stage:
		0:
			fade_rect.visible = true
			fade_rect.color = fade_color
			fade_rect.color.a = 0.0
			transition_started.emit()
			animation_stage = 1
		1:
			fade_rect.color.a += delta*fade_speed
			if fade_rect.color.a >= 1:
				transition_swap.emit()
				animation_stage = 2
		2:
			fade_rect.color.a -= delta*fade_speed
			if fade_rect.color.a <= 0:
				transition_completed.emit()
				animation_stage = 3
		3:
			fade_rect.visible = false
			queue_free()
