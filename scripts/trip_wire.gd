extends Area2D

enum TripWireType { STEP_UP, STEP_DOWN }

@export var type: TripWireType = TripWireType.STEP_UP

func _ready():
	var is_step_up = (type == TripWireType.STEP_UP)
	var is_step_down = (type == TripWireType.STEP_DOWN)
	set_collision_layer_value(1, is_step_up)
	set_collision_mask_value(1, is_step_up)
	set_collision_layer_value(2, is_step_down)
	set_collision_mask_value(2, is_step_down)



func _on_body_entered(body: Node2D) -> void:
	if not body is Ball:
		return

	var ball: Ball = body

	match type:
		TripWireType.STEP_UP:
			ball.increment_collision_layer()
		TripWireType.STEP_DOWN:
			ball.decrement_collision_layer()
