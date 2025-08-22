extends RigidBody2D

const N_ANIMATION_FRAMES = 16
const BIN_SIZE = 360/N_ANIMATION_FRAMES

func _on_body_entered(body: Node) -> void:
	if body.get_parent() is Paddle:
		body.get_parent().apply_collision_force(self)

func _physics_process(delta: float) -> void:
	var rotation_degrees_normalized = rotation_degrees
	while rotation_degrees_normalized < 360:
		rotation_degrees_normalized += 360
	rotation_degrees_normalized = int(rotation_degrees_normalized) % 360
	var frame = int((N_ANIMATION_FRAMES - 1) -  (rotation_degrees_normalized/BIN_SIZE))
	$AnimatedSprite2D.frame = frame
