class_name MenuUI extends Control

signal closed

var is_closed: bool = false

func _menu_ready() -> void:
	pass

func emit_close() -> void:
	if !is_closed:
		closed.emit()
		is_closed = true
