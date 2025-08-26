extends Node2D
class_name TripleRolloverButtonGroup



var buttons = []

signal modify_multiplier

func _ready():
	buttons = [$RolloverButton, $RolloverButton2, $RolloverButton3]

	for button: RolloverButton in buttons:
		button.connect("button_is_set", check_if_all_buttons_are_set)

func check_if_all_buttons_are_set():
	for button: RolloverButton in buttons:
		if button.state != RolloverButton.RolloverButtonState.SET:
			return

	modify_multiplier.emit(1)
	reset_all_buttons()

func reset_all_buttons():
	for button: RolloverButton in buttons:
		button.reset_rolloverbutton()

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
	if event.is_action_pressed("right_flipper"):
		shift_right()
	elif event.is_action_pressed("left_flipper"):
		shift_left()
