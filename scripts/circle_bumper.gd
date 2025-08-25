extends StaticBody2D
class_name CircleBumper


const score_value = 750

const CIRCLE_BUMPER_STRENGTH = 10

func apply_collision_force(ball: RigidBody2D):
	var direction: Vector2

	direction = (ball.position - position).normalized()

	var force = direction * CIRCLE_BUMPER_STRENGTH

	ball.apply_central_impulse(force)
	
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play()
