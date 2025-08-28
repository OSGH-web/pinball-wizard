@tool
extends Node2D
class_name Bumper

const BUMPER_STRENGTH = 15
const score_value = 500

# derived from the bumper pixel art
# angle is relative to the UP direction
const BUMPER_ANGLE = 35

@export var left_bumper = true:
	set(lb):
		left_bumper = lb

		if left_bumper:
			scale = Vector2(1, 1)
		else:
			scale = Vector2(-1, 1)


func apply_collision_force(ball: RigidBody2D):
	var direction: Vector2

	if left_bumper:
		direction = Vector2.UP.rotated(deg_to_rad(BUMPER_ANGLE))
	else:
		direction = Vector2.UP.rotated(deg_to_rad(-1 * BUMPER_ANGLE))

	var force = direction * BUMPER_STRENGTH

	var variance_factor = randf_range(0.90, 1.10)
	force *= variance_factor


	ball.apply_central_impulse(force)

	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play()
	$AudioStreamPlayer2D.play()
