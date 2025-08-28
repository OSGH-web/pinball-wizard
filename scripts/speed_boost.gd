extends Node2D
class_name SpeedBoost

const SPEED_BOOST_STRENGTH = 30
const score_value = 50
signal modify_score

func apply_collision_force(ball: RigidBody2D):
	var direction = Vector2.UP
	var force = direction * SPEED_BOOST_STRENGTH
	ball.apply_central_impulse(force)


func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		if body.linear_velocity.y < 0:
			apply_collision_force(body)
			modify_score.emit(score_value)
