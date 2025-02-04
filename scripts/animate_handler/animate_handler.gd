extends Node

signal animation_emptied()

class _TweenAnimate extends Animate:
	func define_tween(tween: Tween) -> void: tween.finished.connect(_on_tween_finished)
	func _on_tween_finished() -> void: end()

var default_speed: float = 1.0

var _queue: Array[Animate] = []
var _speed: float = 1.0

func _ready() -> void:
	reset_speed()

func reset_speed() -> void: _speed = default_speed
func speed() -> float: return _speed
func speed_up() -> void: _speed = min(_speed+0.1, 5)

func add_to_queue(animate: Animate) -> void:
	_queue.push_back(animate)
	animate.completed.connect(_on_animate_complete)

func create_tween_to_queue() -> Tween:
	var tween := get_tree().create_tween()
	tween.set_speed_scale(speed())
	add_tween_to_queue(tween)
	return tween

func add_tween_to_queue(tween: Tween) -> void:
	var animate:=_TweenAnimate.new()
	animate.define_tween(tween)
	add_to_queue(animate)

func _on_animate_complete(animate: Animate) -> void:
	if _queue.has(animate):
		_queue.erase(animate)
	if _queue.is_empty():
		animation_emptied.emit()

func is_animating() -> bool:
	return !_queue.is_empty()
