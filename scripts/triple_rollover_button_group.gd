extends Node2D

var buttons = []

func _ready():
	# debug
	$RolloverButton.set_rolloverbutton()
	buttons = [$RolloverButton, $RolloverButton2, $RolloverButton3]
	
func shift_right():
	var button_states = []
	for button in buttons:
		button_states.append(button.state)
		
	button_states.push_front(button_states[2])
	button_states.remove_at(3)
	
	for i in range(3):
		var new_state = button_states[i]
		var button = buttons[i]
		
		if button.state != new_state:
			if new_state == RolloverButton.RolloverButtonState.SET:
				button.set_rolloverbutton()
			else:
				button.reset_rolloverbutton()

func shift_left():
	var button_states = []
	for button in buttons:
		button_states.append(button.state)
		
	button_states.push_back(button_states[0])
	button_states.remove_at(0)
	
	for i in range(3):
		var new_state = button_states[i]
		var button = buttons[i]
		
		if button.state != new_state:
			if new_state == RolloverButton.RolloverButtonState.SET:
				button.set_rolloverbutton()
			else:
				button.reset_rolloverbutton()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		shift_right()
	elif event.is_action_pressed("ui_left"):
		shift_left()
