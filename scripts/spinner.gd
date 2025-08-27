extends Area2D
class_name Spinner

enum SpinnerState {STATIC, SPINNING}

var state = SpinnerState.STATIC
var rotations = 0:
	set(new_rotations):
		if new_rotations < 0:
			rotations = 0
		elif new_rotations > 30:
			rotations = 30
		else:
			rotations = new_rotations

signal spin_points

# Called from animation player
func _rotate():
	if state == SpinnerState.SPINNING:
		if $AnimatedSprite2D.frame == 0:
			spin_points.emit(50)
			rotations -= 1
			if rotations == 0:
				$AnimationPlayer.stop()
				state = SpinnerState.STATIC
			#elif rotations % 5 == 0: 
				#$AnimationPlayer.set_speed_scale(max(0.75, $AnimationPlayer.get_speed_scale() - 0.25))
			else:
				var speed_scale = ((rotations / 7) + 1) * 0.5
				$AnimationPlayer.set_speed_scale(speed_scale)
				

func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		var animation_speed_scale = 0.5
		var current_frame = $AnimatedSprite2D.frame
		var frame_rate = 60.0
		var start_time = current_frame / frame_rate
		if state == SpinnerState.STATIC:
			animation_speed_scale = 0.5
		else:
			animation_speed_scale = $AnimationPlayer.get_speed_scale()
		var velocity = abs(body.linear_velocity.y)
		while velocity > 0:
			velocity -= 50
			# Could be an issue with the speed scale getting too high
			animation_speed_scale += 0.25
			rotations += 2
		if state == SpinnerState.STATIC:
			$AnimationPlayer.play_section("spinner", start_time, -1, -1, min(animation_speed_scale, 5.0))
		elif state == SpinnerState.SPINNING:
			$AnimationPlayer.set_speed_scale($AnimationPlayer.get_speed_scale() + animation_speed_scale)
		state = SpinnerState.SPINNING
