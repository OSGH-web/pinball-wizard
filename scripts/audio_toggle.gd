extends Button

enum AudioToggleState { NORMAL, MUTED }

var state: AudioToggleState = AudioToggleState.NORMAL


func _on_mouse_entered() -> void:
	if state == AudioToggleState.NORMAL:
		$AudioSheet.frame = 1 # show mute icon
	else:
		$AudioSheet.frame = 0 # show normal icon


func _on_mouse_exited() -> void:
	if state == AudioToggleState.NORMAL:
		$AudioSheet.frame = 0  # show normal icon
	else:
		$AudioSheet.frame = 1  # show mute icon


func _on_button_down() -> void:
	if state == AudioToggleState.NORMAL:
		state = AudioToggleState.MUTED
		$AudioSheet.frame = 1  # show mute icon
		mute()
	else:
		state = AudioToggleState.NORMAL
		$AudioSheet.frame = 0  # show normal icon
		unmute()


func mute():
	AudioServer.set_bus_mute(0, true)


func unmute():
	AudioServer.set_bus_mute(0, false)
