extends Node2D
class_name Plunger

const PLUNGER_STRENGTH = 30

# Called when the node enters the scene tree for the first time.
enum PlungerState { RISING, FALLING, IDLE }  # Plunger motion phases
enum PlungerInput { NONE, PRESS, RELEASE }

var state = PlungerState.IDLE
var input := PlungerInput.NONE

# The game starts upon the first plunger activation.
var game_started = false
signal game_started_signal

func apply_collision_force(ball: RigidBody2D):
	if state == PlungerState.RISING:
		var force = Vector2(0, -1) * PLUNGER_STRENGTH
		ball.apply_central_impulse(force)


func _input(event):
	if event.is_action_pressed("lower_plunger"):
		input = PlungerInput.PRESS
		if game_started == false:
			game_started = true
			game_started_signal.emit()
	elif event.is_action_released("lower_plunger"):
		input = PlungerInput.RELEASE


func _ready():
	$AnimationPlayer.connect("animation_finished", func(anim_name: StringName):
		if anim_name == "Lower" && $PlungerSprites.frame == 0:
			state = PlungerState.IDLE
		)


func _physics_process(delta: float):
	match state:
		PlungerState.IDLE:
			if input == PlungerInput.PRESS:
				$AnimationPlayer.play("Lower")
				state = PlungerState.FALLING
				input = PlungerInput.NONE
		PlungerState.FALLING:
			if $PlungerSprites.frame == 3 and input == PlungerInput.RELEASE:
				$AnimationPlayer.play_backwards("Lower")
				state = PlungerState.RISING
				input = PlungerInput.NONE
		PlungerState.RISING:
			pass
