extends CanvasLayer

var rng := RandomNumberGenerator.new()

func _input(event):
	if event.is_action_pressed("shake_left"):
		shake_screen(true)
	elif event.is_action_pressed("shake_right"):
		shake_screen(false)


func shake_screen(is_left: bool, amount := 10.0, duration := 0.25):
	var tween := create_tween()
	if is_left:
		var off := Vector2(
			rng.randf_range(-amount -5, -amount),
			rng.randf_range((-amount-5)/2, -amount/2)
		)
		tween.tween_property(self, "offset", off, duration)
	else:
		var off := Vector2(
			rng.randf_range(amount, amount + 5),
			rng.randf_range(amount/2, (amount+5)/2)
		)
		tween.tween_property(self, "offset", off, duration)	
	# return to neutral
	tween.tween_property(self, "offset", Vector2.ZERO, 0.08)
