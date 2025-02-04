extends Node

var streams: Array[AudioStreamPlayer]
var _ambience_stream := AudioStreamPlayer.new()
var _default_sound_effect_db := -27

func _ready() -> void:
	Registries.register_resource(Registries.SOUND, "electric_buzz", load("res://assets/sound/electric_buzz.mp3"))
	Registries.register_resource(Registries.SOUND, "shop_bell", load("res://assets/sound/shop_bell.mp3"))
	Registries.register_resource(Registries.SOUND, "stamp_slam", load("res://assets/sound/stamp_slam.mp3"))
	Registries.register_resource(Registries.SOUND, "factory_ambience", load("res://assets/sound/factory_ambience.mp3"))
	Registries.register_resource(Registries.SOUND, "success", load("res://assets/sound/glockenspiel_success.mp3"))
	Registries.register_resource(Registries.SOUND, "failure", load("res://assets/sound/failure.mp3"))
	Registries.register_resource(Registries.SOUND, "whoosh", load("res://assets/sound/whoosh.mp3"))
	Registries.register_resource(Registries.SOUND, "book_turn", load("res://assets/sound/book_turn.mp3"))
	Registries.register_resource(Registries.SOUND, "hover_button", load("res://assets/sound/hover_button.mp3"))
	Registries.register_resource(Registries.SOUND, "coin_drop", load("res://assets/sound/coin_drop.mp3"))
	
	add_child(_ambience_stream)
	_ambience_stream.stream = Registries.get_resource(Registries.SOUND, "factory_ambience")
	_ambience_stream.volume_db = -20
	_ambience_stream.play()
	
	
	for i in 10:
		var _stream := AudioStreamPlayer.new()
		streams.push_back(_stream)
		add_child(_stream)
		_stream.max_polyphony = 10
		_stream.volume_db = _default_sound_effect_db

func play_sound_effect(sound_id: String, pitch_variance: float = 0.1, volume_db := _default_sound_effect_db) -> void:
	var resource := Registries.get_resource(Registries.SOUND, sound_id)
	if !resource: return
	for stream in streams:
		stream.volume_db = volume_db
		if stream.stream == resource:
			stream.play()
			stream.pitch_scale = 1 + randf_range(-pitch_variance,pitch_variance)
			stream.finished.connect(
				func() -> void:
					stream.stream = null
			)
			break
		else:
			if !stream.playing:
				stream.pitch_scale = 1 + randf_range(-pitch_variance,pitch_variance)
				stream.stream = resource
				stream.play()
				break

func play_song() -> void:
	pass
