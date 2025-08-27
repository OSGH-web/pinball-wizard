extends Area2D

enum TripWireType { STEP_UP, STEP_DOWN }

@export var type: TripWireType = TripWireType.STEP_UP

func _ready():
	if type == TripWireType.STEP_UP:
		set_collision_layer_value(1, true)
		set_collision_mask_value(1, true)
		set_collision_layer_value(2, false)
		set_collision_mask_value(2, false)
	elif type == TripWireType.STEP_DOWN:
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		set_collision_layer_value(2, true)
		set_collision_mask_value(2, true)

func _on_body_entered(body: Node2D) -> void:
	if not body is Ball:
		return

	var ball: Ball = body

	match type:
		TripWireType.STEP_UP:
			ball.increment_collision_layer()
		TripWireType.STEP_DOWN:
			ball.decrement_collision_layer()
