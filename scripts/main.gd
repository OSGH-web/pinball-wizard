extends Node2D
var timer: Timer
# The amount of time the timer will start with in milliseconds
var countdown_time := 180
var game_started := false


func _ready():
	%UI/TimerLabel.text = format_time(countdown_time)
	$Plunger.connect("game_started_signal", _on_game_started_signal)
	
	
func _on_game_started_signal():
	_start_countdown(countdown_time)
	
	
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
