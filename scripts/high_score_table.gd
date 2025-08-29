@tool
extends HFlowContainer
class_name HighScoreTable


# Constants

const NAME_LABEL_WIDTH = 23
const TITLE_LABEL_WIDTH = 63
const SCORE_LABEL_WIDTH = 39

# if the player hasn't received a high score, the table is displayed for NO_HIGH_SCORE_DELAY_TIME
# seconds, and then the game is reset
const NO_HIGH_SCORE_DELAY_TIME = 5

# the pool of characters which can be used in the high score name entry
const CHARACTER_LIST = "_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!,*()"

# the color used for the active character when the player is entering their name for a new high score
const HIGHLIGHT_COLOR: Color = Color(0.996, 0.906, 0.38, 1.0)
# normal text color 
const NORMAL_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)


# State Variables

var high_score_data: HighScoreList = preload("res://resources/high_scores/default_scores.tres")

# state variable. set to true if the player is actively entering their name for a new high score
var entering_name: bool = false
# state variable. if the player has reached a new high score, this will be set to the index of 
# that score in `high_score_data.scores`
var new_high_score_idx = -1

# state variable. if the player has reached a new high score, this will be set to the position of their cursor
# in the name they are adding.
var name_position = 0:
	set(_np):
		name_position = min(max(_np, 0), 2)

# state variable. if the player has reached a high score, this will be be the index of the character
# at their cursor in the `CHARACTER_LIST` string
var character_idx = 0:
	set(_ci):
		character_idx = _ci % CHARACTER_LIST.length()


# Signals

# emitted when the player is done using the high score table
signal finished_entering_score


# This is the "Entry Point" to the high score table.
# the main script always calls this function after the game ends, even if the player's score is
# too low to earn a high score
func enter_high_score(score: int):
	_render()
	show()
	name_position = 0
	character_idx = 0
	
	# score data is assumed to be sorted from high to low
	for i in high_score_data.scores.size():
		var existing_high_score = high_score_data.scores[i]
		if score > existing_high_score.score:
			new_high_score_idx = i
			var new_high_score = HighScore.new()
			new_high_score.score = score
			new_high_score.name = "___"
			high_score_data.scores.insert(i, new_high_score)
			high_score_data.scores.remove_at(high_score_data.scores.size() - 1)
			
			entering_name = true
			
			_render()
			return
			
	# if we've reached this point, it means the player didn't get a high score
	# in this case, delay for a short period and reset the game
	await get_tree().create_timer(NO_HIGH_SCORE_DELAY_TIME).timeout
	reset()
	
	
# redraw every element in the high score table
func _render():
	for child in get_children():
		remove_child(child)
		child.queue_free()

	_create_title_label()

	for i in high_score_data.scores.size():
		var high_score: HighScore = high_score_data.scores[i]

		var active_score_entry = (i == new_high_score_idx)
		_create_name_label(high_score.name, active_score_entry)

		_create_score_label(high_score.score)

# helper for _render()
func _create_title_label():
	var title_label = Label.new()
	title_label.text = "Hi Scores:"
	title_label.custom_minimum_size.x = TITLE_LABEL_WIDTH
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title_label)

# helper for _render()
func _create_score_label(score: int):
	var score_label = Label.new()
	score_label.text = str(score)
	score_label.custom_minimum_size.x = SCORE_LABEL_WIDTH
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(score_label)

# helper for _render()
func _create_name_label(name: String, active: bool):
	var name_label = RichTextLabel.new()
	name_label.bbcode_enabled = true
	name_label.custom_minimum_size.x = NAME_LABEL_WIDTH

	# if the player is actively entering a score, display the active character in yellow
	if entering_name and active:
		var highlighted_name_string = ""
		for j in name.length():
			var active_character = name[j]
			if j == name_position:
				highlighted_name_string += _set_highlight_color(active_character)
			else:
				highlighted_name_string += _set_normal_color(active_character)
		
		name_label.text = highlighted_name_string
	else:
		name_label.text = name
		
	add_child(name_label)
	
# helper for _create_name_label
func _set_highlight_color(input_string: String):
	return "[color=%s]%s[/color]" % [HIGHLIGHT_COLOR.to_html(), input_string]

# helper for _create_name_label
func _set_normal_color(input_string: String):
	return "[color=%s]%s[/color]" % [NORMAL_COLOR.to_html(), input_string]


func _input(event: InputEvent):
	if not entering_name:
		return
		
	# if we are here that means the player has earned a new high score and needs to enter their name
	var score = high_score_data.scores[new_high_score_idx]
	
	if event.is_action_pressed("ui_up"):
		# increment the character at the player's cursor. 
		character_idx += 1
		var selected_character = CHARACTER_LIST[character_idx]
		score.name[name_position] = selected_character
	elif event.is_action_pressed("lower_plunger"):
		# decrement the character at the player's cursor
		character_idx -= 1
		var selected_character = CHARACTER_LIST[character_idx]
		score.name[name_position] = selected_character
	elif event.is_action_pressed("right_flipper"):
		# move the player's cursor to the right
		if name_position == 2:
			reset()
			return
			
		name_position += 1
		character_idx = CHARACTER_LIST.find(score.name[name_position])
	elif event.is_action_pressed("left_flipper"):
		# move the player's cursor to the left
		name_position -= 1
		character_idx = CHARACTER_LIST.find(score.name[name_position])

	_render()

# called when the player is finished with the high score screen
func reset():
	entering_name = false
	hide()
	finished_entering_score.emit()
