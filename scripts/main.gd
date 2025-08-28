extends Node2D

const NEW_BALL_POSITION = Vector2(436.0, 301.25)

var timer: Timer
# The amount of time the timer will start with in milliseconds
var countdown_time :=  180
var game_started := false
var ball_scene = preload("res://scenes/ball.tscn")
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

var damage_number_scene = preload("res://scenes/damage_number.tscn")

func _ready():
	%UI/TimerLabel.text = format_time(countdown_time)
	%Plunger.connect("game_started_signal", _on_game_started_signal)
	%TargetBank.connect("add_time", _add_time)
	%TargetBank.connect("add_score_bonus", _modify_score)
	%Spinner.connect("spin_points", _modify_score)
	%Spinner2.connect("spin_points", _modify_score)
	%SpeedBoost.connect("modify_score", _modify_score)
	_create_new_ball()

	%UI/HighScoreTable.connect("finished_entering_score", _reset_game)

const RESET_DELAY = 2

func _reset_game():
	$UI/ResettingLabel.show()
	countdown_time = 5
	score = 0
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
	$UI/TimerLabel.text = format_time(countdown_time)
	$UI/TimerLabel.show()
	$"UI/Hi Score".show()
	$UI/HBoxContainer.show()



func _create_new_ball():
	var ball = ball_scene.instantiate()
	ball.position = NEW_BALL_POSITION
	ball.connect("modify_score", _modify_score)
	ball.connect("add_time", _add_time)
	$Shake_Layer/Balls.add_child(ball)

	
func _on_game_started_signal():
	_start_countdown(countdown_time)
	
	
func _add_time(time):
	%UI/Timer.set_wait_time(%UI/Timer.time_left + time)
	%UI/Timer.start()
	
	
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
	
	
func _process(_delta: float) -> void:
	if game_started:
		var remaining = int(ceil(%UI/Timer.time_left))
		%UI/TimerLabel.text = format_time(remaining)


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
	$"UI/Hi Score".hide()
	$UI/HBoxContainer.hide()

	get_tree().paused = true

	$"UI/HighScoreTable".enter_high_score(score)
	$UI/Timer.stop()


func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [minutes, secs]


func _on_shake_layer_child_entered_tree(node: Node) -> void:
	if node is TripleRolloverButtonGroup:
		node.connect("modify_multiplier", _modify_multiplier)
