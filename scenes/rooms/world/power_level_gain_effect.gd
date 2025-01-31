extends Control

@onready var power: Label = $HBoxContainer/Power

func _ready() -> void:
	var tween := get_tree().create_tween()
	modulate.a = 0
	tween.set_parallel(true)
	position += Vector2(randi_range(0,25),randi_range(-10,10))
	tween.tween_property(self, "position:y", position.y-100, 1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ONE*1.1, 1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1, 0.7).set_trans(Tween.TRANS_CUBIC)
	tween.chain()
	tween.tween_property(self, "modulate:a", 0.0, 1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ONE*0.5, 1).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(
		func() -> void: queue_free()
	)

func set_value(value: float) -> void:
	power.text = str(value)
