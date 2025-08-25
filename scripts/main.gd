extends Node2D
var timer: Timer
# The amount of time the timer will start with in milliseconds
var countdown_time := 180
var game_started := false
var score = 0
var multiplier = 1


func _ready():
	%UI/TimerLabel.text = format_time(countdown_time)
	$Plunger.connect("game_started_signal", _on_game_started_signal)
	
	
func _on_game_started_signal():
	_start_countdown(countdown_time)
	

func _modify_score(score_value):
	score += score_value * multiplier
	%UI/Score.text = str(score)
	
func _increment_multiplier():
	multiplier += 1
	%UI/Multiplier.text = "Mult: x%d" % multiplier
	
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
	get_tree().quit()
	
	
func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [minutes, secs]


func _on_child_entered_tree(node: Node) -> void:
	if node is Ball:
		node.connect("add_to_score", _modify_score)

	if node is TripleRolloverButtonGroup:
		node.connect("increment_multiplier", _increment_multiplier)
