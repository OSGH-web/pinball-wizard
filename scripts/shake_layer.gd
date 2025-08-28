extends CanvasLayer

var rng := RandomNumberGenerator.new()
const SHAKE_STRENGTH = 4

func _input(event):
	if $ShakeCooldown.is_stopped():
		if event.is_action_pressed("shake_left"):
			shake_screen(true)
		elif event.is_action_pressed("shake_right"):
			shake_screen(false)


func shake_screen(is_left: bool, amount := 10.0, duration := 0.25):
	$ShakeCooldown.start()
	var tween := create_tween()
	$TableShakeSound.play()
	if is_left:
		var off := Vector2(
			rng.randf_range(-amount -5, -amount),
			rng.randf_range((-amount-5)/2, -amount/2)
		)
		tween.tween_property(self, "offset", off, duration)
		for ball in get_node("Balls").get_children(): 
			var force = Vector2(-1, 0) * rng.randf_range(SHAKE_STRENGTH - 1, SHAKE_STRENGTH + 1)
			ball.apply_central_impulse(force)
	else:
		var off := Vector2(
			rng.randf_range(amount, amount + 5),
			rng.randf_range(amount/2, (amount+5)/2)
		)
		tween.tween_property(self, "offset", off, duration)
		for ball in get_node("Balls").get_children(): 
			var force = Vector2(1, 0) * rng.randf_range(SHAKE_STRENGTH - 1, SHAKE_STRENGTH + 1)
			ball.apply_central_impulse(force)
	# return to neutral
	tween.tween_property(self, "offset", Vector2.ZERO, 0.08)
