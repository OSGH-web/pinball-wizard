extends Area2D
class_name Spinner

enum SpinnerState {STATIC, SPINNING}

const MAX_ROTATIONS = 15 					# the maximum number of rotations the spinner can have on one collision
const BALL_VELOCITY_SCALE_FACTOR = 25		# the ball's speed is divided by this value to get the number of rotations
const ROTATIONS_SPEED_SCALE_FACTOR = 5		# the number of rotations remaining is divided by this value to get the animation speed scale
const MIN_SPEED_SCALE = 1					# the minimum animation speed scale
const MIN_ROTATIONS_ON_COLLISION = 2		# the minimum number of rotations produced when the ball collides with the spinner

var state = SpinnerState.STATIC
var rotations = 0:
	set(new_rotations):
		rotations = max(min(new_rotations, MAX_ROTATIONS), 0)

signal spin_points

func _get_speed_scale():
	return (rotations / ROTATIONS_SPEED_SCALE_FACTOR) + MIN_SPEED_SCALE

# Called from animation player
func _rotate():
	if state == SpinnerState.SPINNING:
		if $AnimatedSprite2D.frame == 0:
			spin_points.emit(50)
			rotations -= 1
			if rotations == 0:
				$AnimationPlayer.stop()
				state = SpinnerState.STATIC
			else:
				$AnimationPlayer.set_speed_scale(_get_speed_scale())


func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		var current_frame = $AnimatedSprite2D.frame
		var frame_rate = 60.0
		var start_time = current_frame / frame_rate

		var new_rotations = floor(abs(body.linear_velocity.y) / BALL_VELOCITY_SCALE_FACTOR)
		new_rotations = max(new_rotations, MIN_ROTATIONS_ON_COLLISION)
		rotations += new_rotations
		if rotations <= 0:
			rotations = 2

		if state == SpinnerState.STATIC:
			$AnimationPlayer.play_section("spinner", start_time, -1, -1, _get_speed_scale())
		elif state == SpinnerState.SPINNING:
			$AnimationPlayer.set_speed_scale(_get_speed_scale())
		state = SpinnerState.SPINNING
