extends Node2D

func _physics_process(delta: float) -> void:
	pass
	#if $Ball.position[1] >= 358:
		#$Paddle2.input = $Paddle2.PADDLE_INPUTS.PRESS
	#if $Ball2.position[1] >= 358:
		#$Paddle.input = $Paddle.PADDLE_INPUTS.PRESS
