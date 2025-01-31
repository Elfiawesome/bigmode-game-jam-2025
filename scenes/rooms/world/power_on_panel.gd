extends Panel

signal button_pressed()

@onready var button: ColorRect = $MarginContainer/Control/Button

var tween : Tween
func _ready() -> void:
	button.mouse_entered.connect(
		func() -> void:
			if tween: tween.kill()
			tween = get_tree().create_tween()
			var color := Color("fee761")
			color.a = .4
			tween.tween_property(button, "color", color, 0.3).set_trans(Tween.TRANS_LINEAR)
	)
	button.mouse_exited.connect(
		func() -> void:
			if tween: tween.kill()
			tween = get_tree().create_tween()
			var color:=Color.WHITE
			color.a = 0
			tween.tween_property(button, "color", color, .3).set_trans(Tween.TRANS_LINEAR)
	)
	button.gui_input.connect(
		func(event: InputEvent) -> void:
			if event is InputEventMouseButton:
				if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
					if tween: tween.kill()
					tween = get_tree().create_tween()
					tween.set_parallel(true)
					tween.tween_property(button, "color", Color.WHITE, 0.2).set_trans(Tween.TRANS_BACK)
					tween.chain()
					tween.tween_property(button, "color:a", 0, 0.2).set_trans(Tween.TRANS_LINEAR)
					button_pressed.emit()
	)
