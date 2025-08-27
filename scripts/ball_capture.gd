extends StaticBody2D
class_name BallCapture

const BALL_CAPTURE_STRENGTH = 20
const MAX_FORCE_MAGNITUDE = 5
# if the center of the ball is within this distance of the center of the ball capture, the ball will be locked
const LOCK_DISTANCE_THRESHOLD = 0.5

enum BallCaptureState { INACTIVE, ACTIVE, BALL_LOCKED, RELEASING }

var state: BallCaptureState = BallCaptureState.ACTIVE

# when a ball is locked, this variable stores a reference to the locked ball
var lockedBall: Ball = null

func apply_collision_force(ball: RigidBody2D, collision_pos: Vector2):
	if state == BallCaptureState.INACTIVE || state == BallCaptureState.BALL_LOCKED:
		return
	
	if state == BallCaptureState.RELEASING:
		ball.apply_central_impulse(Vector2(0, -1) * MAX_FORCE_MAGNITUDE * 5)
		state = BallCaptureState.ACTIVE
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
	$Timer.start()
	
	$AnimatedSprite2D.frame = 0 # show a red border around the ball capture

func release_ball():
	state = BallCaptureState.RELEASING
	lockedBall.unfreeze_requested = true
	lockedBall = null
	
	$AnimatedSprite2D.frame = 1 # return to default appearance -- gray border


func _on_timer_timeout() -> void:
	$Timer.stop()
	release_ball()
