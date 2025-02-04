extends MenuUI

@onready var approved_stamp: Sprite2D = $Control/MarginContainer/VBoxContainer/HBoxContainer/SignatureLabel/ApprovedStamp
@onready var failure_stamp: Sprite2D = $Control/MarginContainer/VBoxContainer/HBoxContainer/SignatureLabel/FailureStamp
@onready var rubber_stamp: Sprite2D = $Control/MarginContainer/VBoxContainer/HBoxContainer/SignatureLabel/RubberStamp
@onready var power_label: Label = $Control/MarginContainer/VBoxContainer/Control/VBoxContainer/HBoxContainer/Label
@onready var quota_label: Label = $Control/MarginContainer/VBoxContainer/Control/VBoxContainer/HBoxContainer/Label3

@onready var best_performer_sprite_1: TextureRect = $Control/MarginContainer/VBoxContainer/Control/VBoxContainer/HBoxContainer2/VBoxContainer/TextureRect
@onready var best_performer_desc_1: Label = $Control/MarginContainer/VBoxContainer/Control/VBoxContainer/HBoxContainer2/VBoxContainer/Label

@onready var best_performer_sprite_2: TextureRect = $Control/MarginContainer/VBoxContainer/Control/VBoxContainer/HBoxContainer2/VBoxContainer2/TextureRect
@onready var best_performer_desc_2: Label = $Control/MarginContainer/VBoxContainer/Control/VBoxContainer/HBoxContainer2/VBoxContainer2/Label
@onready var okay_button: ColorRect = $Control/MarginContainer/VBoxContainer/OkayButton/MarginContainer/ColorRect


var tween: Tween 
var button_tween:Tween
var finished:bool = false
var exit_ani_now:bool = false
@warning_ignore("unused_private_class_variable")
var _power_amt: float:
	set(value):
		power_label.text = str(snapped(value,0.01))
@warning_ignore("unused_private_class_variable")
var _qouta_amt: float:
	set(value):
		quota_label.text = str(snapped(value,0.01))

func _ready() -> void:
	okay_button.mouse_entered.connect(
		func()->void:
			if button_tween: button_tween.kill()
			button_tween = get_tree().create_tween()
			button_tween.set_parallel(true)
			okay_button.color.a = 0.0
			button_tween.tween_property(okay_button,"color:a", .5, 1.0)
	)
	okay_button.mouse_exited.connect(
		func()->void:
			if button_tween: button_tween.kill()
			button_tween = get_tree().create_tween()
			button_tween.set_parallel(true)
			button_tween.tween_property(okay_button,"color:a", 0.0, 1.0)
	)
	okay_button.gui_input.connect(
		func(event: InputEvent) -> void:
			if event is InputEventMouseButton:
				if event.pressed:
					exit_animation()
	)

var power_amount:float
var quota_amount: float
var status:int = 0
var best_performers: Array[Dictionary] = []
func set_values(_power_amount:float, _quota_amount: float, _status:int = 0, _best_performers: Array[Dictionary] = []) -> void:
	self.power_amount = _power_amount
	self.quota_amount = _quota_amount
	self.status = _status
	self.best_performers = _best_performers

func _menu_ready() -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	position = get_viewport_rect().size/2 - Vector2(0, get_viewport_rect().size.y*1.5)
	rotation = deg_to_rad(15)
	var target_position := get_viewport_rect().size/2 - size/2
	tween.tween_property(self, "position", target_position, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", 0, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.chain()
	tween.tween_property(self,"_power_amt",power_amount, 1).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self,"_qouta_amt",quota_amount, .5).set_trans(Tween.TRANS_CIRC)
	if status == 0:
		tween.finished.connect(stamp_animation.bind(failure_stamp))
	else:
		tween.finished.connect(stamp_animation.bind(approved_stamp))
	
	var _i: int = 0
	for best_performer in best_performers:
		if _i == 0:
			best_performer_sprite_1.get_parent().visible = true
			best_performer_sprite_1.texture = Registries.get_resource(Registries.CARDRESOURCE, best_performers[0]["card_id"]).texture
			best_performer_desc_1.text = str(snapped(best_performers[0]["score"], 0.01))
		else:
			best_performer_sprite_2.get_parent().visible = true
			best_performer_sprite_2.texture = Registries.get_resource(Registries.CARDRESOURCE, best_performers[1]["card_id"]).texture
			best_performer_desc_2.text = str(snapped(best_performers[1]["score"],0.01))
			break
		_i += 1


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if finished:
				exit_animation()


func stamp_animation(stamp_sprite: Sprite2D, start_position:Vector2 = Vector2(175,-40)) -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	okay_button.visible = true
	okay_button.modulate.a = 0
	tween.tween_property(okay_button, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	
	rubber_stamp.position = start_position + Vector2(100,-200)
	rubber_stamp.modulate.a = 0
	rubber_stamp.rotation = deg_to_rad(15)
	rubber_stamp.visible = true
	stamp_sprite.modulate.a = 0
	stamp_sprite.scale = Vector2.ZERO
	stamp_sprite.rotation = -deg_to_rad(30)
	stamp_sprite.visible = true
	tween.tween_property(rubber_stamp, "modulate:a", 1, .1)
	tween.tween_property(rubber_stamp, "position", start_position, 1.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(rubber_stamp, "scale", Vector2(1,1)*1.2, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(rubber_stamp, "rotation", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(stamp_sprite, "modulate:a", 1, .2).set_delay(.65)
	tween.tween_property(stamp_sprite, "scale", Vector2(1,1), .7).set_delay(.55).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(stamp_sprite, "rotation", 0, .7).set_delay(.55).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.chain()
	tween.tween_callback(func()->void:
		SoundManager.play_sound_effect("stamp_slam", 0.1, -5)
	)
	tween.tween_property(rubber_stamp, "scale", Vector2(1,1)*1.8, 3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(rubber_stamp, "modulate:a", 0, 3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(rubber_stamp, "position", rubber_stamp.position, 3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func()->void:
		if stamp_sprite == approved_stamp:
			SoundManager.play_sound_effect("success", 0.1, -5)
		else:
			SoundManager.play_sound_effect("failure", 0.1, -5)
	).set_delay(0.5)
	tween.finished.connect(func()->void:finished=true)

func exit_animation() -> void:
	if is_closed: return
	emit_close()
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	var target_position := get_viewport_rect().size/2 - size/2 + Vector2(0, get_viewport_rect().size.y*1.5)
	tween.tween_property(self, "position", target_position, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", deg_to_rad(-5), 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 0, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.finished.connect(
		func()->void:queue_free()
	)
