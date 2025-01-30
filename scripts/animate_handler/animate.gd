class_name Animate extends RefCounted

signal completed(animate: Animate)
signal poi(index: int)

func end() -> void:
	completed.emit(self)
