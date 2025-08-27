extends Area2D

enum TripWireType { STEP_UP, STEP_DOWN }

@export var type: TripWireType = TripWireType.STEP_UP

func _on_body_entered(body: Node2D) -> void:
	if not body is Ball:
		return

	var ball: Ball = body

	match type:
		TripWireType.STEP_UP:
			ball.increment_collision_layer()
		TripWireType.STEP_DOWN:
			ball.decrement_collision_layer()
