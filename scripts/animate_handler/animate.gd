class_name Animate extends RefCounted

signal completed(animate: Animate)

func end() -> void:
	completed.emit(self)
