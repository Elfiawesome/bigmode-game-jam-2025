extends Node2D

var tgt_global_pos: Vector2

func _ready() -> void:
	intro_animation()

func intro_animation() -> void:
	scale = Vector2.ZERO
	modulate.a = 0
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(8,8)+Vector2.ONE*randf_range(-0.5,0.5), 1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, .25).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 0, 1).set_trans(Tween.TRANS_BACK).set_delay(0.75)
	tween.finished.connect(func()->void: queue_free())
