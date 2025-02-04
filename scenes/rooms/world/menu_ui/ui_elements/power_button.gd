extends Control

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@export var button_text: String:
	set(value):
		button_text = value
		$Label.text = button_text
signal clicked()

var tween: Tween

func _ready() -> void:
	$Label.text = button_text
	mouse_entered.connect(
		func()->void:
			if tween: tween.kill()
			tween = get_tree().create_tween()
			var new_color := Color("fee761")
			tween.tween_property(nine_patch_rect, "modulate", new_color, .25)
	)
	mouse_exited.connect(
		func()->void:
			if tween: tween.kill()
			tween = get_tree().create_tween()
			var new_color := Color.WHITE
			tween.tween_property(nine_patch_rect, "modulate", new_color, .25)
	)
	gui_input.connect(
		func(event: InputEvent)->void:
			if event is InputEventMouseButton:
				if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
					_on_mouse_clicked()
	)
func _on_mouse_clicked() -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween()
	var new_color := Color.YELLOW
	tween.tween_property(nine_patch_rect, "modulate", new_color, .25)
	tween.tween_property(nine_patch_rect, "modulate", Color.WHITE, .25)
	clicked.emit()
