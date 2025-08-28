extends StaticBody2D
class_name BallCapture

const BALL_CAPTURE_STRENGTH = 15
const MAX_FORCE_MAGNITUDE = 15
# if the center of the ball is within this distance of the center of the ball capture, the ball will be locked
const RELEASE_FORCE_MAGNITUDE = 15
const LOCK_DISTANCE_THRESHOLD = 1
const score_value = 2000

enum BallCaptureState { INACTIVE, ACTIVE, BALL_LOCKED, RELEASING }

var state: BallCaptureState = BallCaptureState.INACTIVE

# when a ball is locked, this variable stores a reference to the locked ball
var lockedBall: Ball = null

signal update_timer_and_score_goal

# release_direction is normalized when the ball is released
# i.e. the magnitude of the release_direction vector has no effect on release
# force strength
@export var release_direction = Vector2(-2, 5)


func _process(delta: float) -> void:
	match state:
		BallCaptureState.ACTIVE:
			$AnimatedSprite2D.frame = 1 # return to default appearance -- gray border
		BallCaptureState.INACTIVE:
			$AnimatedSprite2D.frame = 2 # indicate that the ball capture is inactive
		BallCaptureState.BALL_LOCKED:
			$AnimatedSprite2D.frame = 0 # show a red border around the ball capture


func apply_collision_force(ball: RigidBody2D, collision_pos: Vector2):
	if state == BallCaptureState.INACTIVE || state == BallCaptureState.BALL_LOCKED:
		return

	if state == BallCaptureState.RELEASING:
		ball.apply_central_impulse(release_direction.normalized() * RELEASE_FORCE_MAGNITUDE)
		state = BallCaptureState.INACTIVE
		$Timer.start()
		return
	
	if state != BallCaptureState.ACTIVE:
		return
		 
	# if the ball is close enough to the center, lock its position
	var collision_distance_from_center = (position - collision_pos).length()
	if collision_distance_from_center < LOCK_DISTANCE_THRESHOLD:
		lock_ball(ball)
		return
	
	# Apply magnetic attraction	force to the ball
	var force_direction = (position - collision_pos).normalized()
	var force_magnitude = BALL_CAPTURE_STRENGTH / (collision_distance_from_center ** 2)
	if force_magnitude > MAX_FORCE_MAGNITUDE:
		force_magnitude = MAX_FORCE_MAGNITUDE

	ball.apply_central_impulse(force_direction * force_magnitude)


func lock_ball(ball: Ball):
	state = BallCaptureState.BALL_LOCKED
	lockedBall = ball
	lockedBall.freeze_requested = true
	lockedBall.position = position
	lockedBall.modify_score.emit(score_value)
	$Timer.start()
	$BallCaptureSound.play()


func release_ball():
	state = BallCaptureState.RELEASING
	lockedBall.unfreeze_requested = true
	lockedBall = null
	update_timer_and_score_goal.emit()


func _on_timer_timeout() -> void:
	$Timer.stop()
	if state == BallCaptureState.BALL_LOCKED:
		release_ball()
	elif state == BallCaptureState.INACTIVE:
		state = BallCaptureState.ACTIVE
