extends Node2D

const NEW_BALL_POSITION = Vector2(436.0, 301.25)
const SAVE_PATH = "user://high_score.tres"

var timer: Timer
# The amount of time the timer will start with in milliseconds
var countdown_time :=  120
var game_started := false
var game_round = 0
var score_goal = 0
var high_score = 0
var ball_scene = preload("res://scenes/ball.tscn")
var damage_number_scene = preload("res://scenes/damage_number.tscn")
var score := 0:
	set(new_score):
		if new_score < 0:
			score = 0
		else:
			score = new_score
var multiplier = 1:
	set(new_multiplier):
		if new_multiplier < 1:
			multiplier = 1
		else:
			multiplier = new_multiplier
			

func _ready():
	load_data()
	%UI/Hi_Score.text = "Hi Score:\n" + str(high_score)
	%UI/TimerLabel.text = format_time(countdown_time)
	%Plunger.connect("game_started_signal", _on_game_started_signal)
	%TargetBank.connect("add_time", _add_time)
	%TargetBank.connect("add_score_bonus", _modify_score)
	%Spinner.connect("spin_points", _modify_score)
	%Spinner2.connect("spin_points", _modify_score)
	%SpeedBoost.connect("modify_score", _modify_score)
	_calculate_and_set_score_goal()
	%BallCapture.connect("update_timer_and_score_goal", _update_timer_and_score_goal)
	_create_new_ball()
	
	
func _process(_delta: float) -> void:
	if game_started:
		var remaining = int(ceil(%UI/Timer.time_left))
		%UI/TimerLabel.text = format_time(remaining)
	# This will be called every frame when the score goal is reached. Could make more efficient.
	if score >= score_goal:
		%Gate.open_gate()
		if %BallCapture.state == BallCapture.BallCaptureState.INACTIVE:
			%BallCapture.state = BallCapture.BallCaptureState.ACTIVE
	elif score < score_goal and %CloseGateTimer.is_stopped():
		%CloseGateTimer.start()


const RESET_DELAY = 2

func _reset_game():
	save()
	$UI/ResettingLabel.show()
	countdown_time = 5
	score = 0
	%Score.text = "0"
	multiplier = 1
	var balls = $Shake_Layer/Balls
	for ball in balls.get_children():
		ball.queue_free()

	_create_new_ball()

	await get_tree().create_timer(RESET_DELAY).timeout

	$UI/ResettingLabel.hide()

	get_tree().paused = false
	$Shake_Layer/Plunger.game_started = false
	$Shake_Layer.show()
	countdown_time = 120
	$UI/TimerLabel.text = format_time(countdown_time)
	$UI/Timer.start()
	$UI/TimerLabel.show()
	$UI/Hi_Score.show()
	$UI/HBoxContainer.show()

	# reset target bank
	%TargetBank.reset_all_targets()

	# reset rollover buttons
	$Shake_Layer/TripleRolloverButtonGroup.reset_all_buttons()

	%BallCapture.state = BallCapture.BallCaptureState.INACTIVE
	$Shake_Layer/BallCapture.reset()
	$Shake_Layer/BallCapture2.reset()
	# TODO: reset UI elements
	 # - reset score entry
	 # - reset timer entry

func _create_new_ball():
	var ball = ball_scene.instantiate()
	ball.position = NEW_BALL_POSITION
	ball.connect("modify_score", _modify_score)
	ball.connect("add_time", _add_time)
	$Shake_Layer/Balls.add_child(ball)

	
func _on_game_started_signal():
	_start_countdown(countdown_time)
	

# time is in seconds	
func _add_time(time):
	%UI/Timer.set_wait_time(%UI/Timer.time_left + time)
	%UI/Timer.start()
	

# This should only be called when the ball is locked after reaching a score goal
func _calculate_and_set_score_goal():
	score_goal = ((2**game_round) * 16000)
	%ScoreGoal.text = "Goal: \n" + str(score_goal)
	game_round += 1
	
func _update_timer_and_score_goal():
	_add_time(60)
	_calculate_and_set_score_goal()

	
func _modify_score(score_value: int, _new_ball: bool = false):
	# Might need to change - right now the multiplier will also multipy the death penalty. 
	score += score_value * multiplier
	%UI/HBoxContainer/Score.text = str(score)
	if _new_ball:
		_modify_multiplier(-1)
		call_deferred("_create_new_ball")

	var ball_position = %Balls.get_child(0).position
	const vertical_damage_number_offset = 40

	var damage_number: Label = damage_number_scene.instantiate()
	damage_number.text = str(score_value * multiplier)
	damage_number.position.y = ball_position.y - vertical_damage_number_offset
	damage_number.position.x = ball_position.x - (damage_number.size.x / 2)
	$Shake_Layer.add_child(damage_number)
	
	
func _modify_multiplier(mult_value: int):
	multiplier += mult_value
	%UI/HBoxContainer/Multiplier.text = "x%d" % multiplier


func _start_countdown(duration: int):
	# Call this the first time the plunger is activated. 
	%UI/TimerLabel.text = format_time(duration)
	%UI/Timer.start(countdown_time)
	game_started = true
	
	
func _on_timer_timeout() -> void:
	# Player loses the game
	# print to catch potential game crash error. 
	print("END GAME")
	$Shake_Layer.hide()
	$UI/TimerLabel.hide()
	$"UI/Hi_Score".hide()
	$UI/HBoxContainer.hide()

	get_tree().paused = true

	$UI/Timer.stop()
	_reset_game()


func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [minutes, secs]


func _on_shake_layer_child_entered_tree(node: Node) -> void:
	if node is TripleRolloverButtonGroup:
		node.connect("modify_multiplier", _modify_multiplier)
		


func _on_close_gate_timer_timeout() -> void:
	%Gate.close_gate()
	%BallCapture.state = BallCapture.BallCaptureState.INACTIVE
	
	
func save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if score > high_score:
		file.store_var(score)
		$UI/Hi_Score.text = "Hi Score:\n" + str(score)
		
		
func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var attempt_high_score = file.get_var(score)
		if attempt_high_score != null:
			high_score = attempt_high_score
	else:
		high_score = 0
