extends AudioStreamPlayer2D

const regular_background_music = preload("res://assets/audio/aguas_de_marco_2.wav")
const high_pitch_background_music = preload("res://assets/audio/aguas_de_marco_2_high_pitch.wav")


const regular_background_music_basename = "aguas_de_marco_2"

func _on_finished() -> void:
	var basename = stream.resource_path.get_file().get_basename()
	if basename == regular_background_music_basename:
		stream = high_pitch_background_music
	else:
		stream = regular_background_music
		
	play()
