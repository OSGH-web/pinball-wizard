extends BallCapture
var balls_locked = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	release_direction = Vector2(2, 5)
	state = BallCaptureState.ACTIVE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if balls_locked == 3:
		# begin multiball
		pass
	
	
func lock_ball(ball: Ball):
	state = BallCaptureState.BALL_LOCKED
	lockedBall = ball
	lockedBall.freeze_requested = true
	lockedBall.position = position
	lockedBall.modify_score.emit(score_value)
	$Timer.start()
	$BallCaptureSound.play()
	
	
func _on_timer_timeout():
	$Timer.stop()
	if state == BallCaptureState.BALL_LOCKED:
		balls_locked += 1
		# emit or ball.die()
		# Lock ball and 
		pass
