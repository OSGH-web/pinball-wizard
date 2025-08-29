extends Node2D

const NEW_BALL_POSITION = Vector2(436.0, 301.25)

var timer: Timer
# The amount of time the timer will start with in milliseconds
var countdown_time :=  180
var game_started := false
var game_round = 0
var score_goal = 0
var ball_scene = preload("res://scenes/ball.tscn")
var damage_number_scene = preload("res://scenes/damage_number.tscn")
var score := 16000:
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
	
	
func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [minutes, secs]


func _on_shake_layer_child_entered_tree(node: Node) -> void:
	if node is TripleRolloverButtonGroup:
		node.connect("modify_multiplier", _modify_multiplier)
		
		
func _on_timer_timeout() -> void:
	# Player loses the game
	# print to catch potential game crash error. 
	print("END GAME")


func _on_close_gate_timer_timeout() -> void:
	%Gate.close_gate()
	%BallCapture.state = BallCapture.BallCaptureState.INACTIVE
