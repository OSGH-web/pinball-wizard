extends RigidBody2D


func _on_body_entered(body: Node) -> void:
	if body.get_parent() is Paddle:
		body.get_parent().apply_collision_force(self)
