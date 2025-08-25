extends Node2D
class_name Plunger

const PLUNGER_STRENGTH = 30

# Called when the node enters the scene tree for the first time.
enum PlungerState { RISING, FALLING, IDLE }  # Flipper motion phases
enum PlungerInput { NONE, PRESS, RELEASE }   

var state = PlungerState.IDLE

func apply_collision_force(ball: RigidBody2D):
	if state != PlungerState.FALLING and state != PlungerState.IDLE:
		var force = Vector2(0, -1) * PLUNGER_STRENGTH
		ball.apply_central_impulse(force)
		
	
func _input(event):
	if event.is_action_pressed("lower_plunger"):
		$AnimationPlayer.play_section("Lower")
		state = PlungerState.FALLING
	elif $PlungerSprites.frame == 3 and event.is_action_released("lower_plunger"):
		$AnimationPlayer.play_backwards("Lower")
		state = PlungerState.RISING
