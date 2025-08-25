extends RigidBody2D

const N_ANIMATION_FRAMES = 16
const BIN_SIZE = 360/N_ANIMATION_FRAMES

# debug variables
var debug_initial_click_position := Vector2.ZERO
var debug_final_click_position := Vector2.ZERO
var debug_velocity_reset_requested := false
var debug_update_velocity_requested := false
const debug_throw_strength_multiplier := 2.5
var score = 0


func _on_body_entered(body: Node) -> void:
	if body.get_parent() is Flipper:
		body.get_parent().apply_collision_force(self)
	elif body.get_parent() is Bumper && body.name == "Active":
		body.get_parent().apply_collision_force(self)
		score += 100
		%UI/Score.text = str(score)
	elif body is CircleBumper:
		body.apply_collision_force(self)
		score += CircleBumper.score
		%UI/Score.text = str(score)
	elif body.get_parent() is Plunger:
		body.get_parent().apply_collision_force(self)

func _physics_process(delta: float) -> void:
	_update_animation_frame()

	_debug_handle_mouse_input()

	move_and_collide(Vector2.ZERO)

# helper, called during _physics_process
func _update_animation_frame():
	var rotation_degrees_normalized = rotation_degrees
	# Mapping rotation within 360
	while rotation_degrees_normalized < 360:
		rotation_degrees_normalized += 360
	rotation_degrees_normalized = int(rotation_degrees_normalized) % 360
	var frame = int((N_ANIMATION_FRAMES - 1) -  (rotation_degrees_normalized/BIN_SIZE))
	$AnimatedSprite2D.frame = frame


# helper, called during _physics_process
func _debug_handle_mouse_input():
	if debug_velocity_reset_requested:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0

		debug_velocity_reset_requested = false
		global_position = debug_initial_click_position
		freeze = true

	if debug_update_velocity_requested:
		linear_velocity = debug_final_click_position - debug_initial_click_position
		linear_velocity *= debug_throw_strength_multiplier
		freeze = false
		debug_update_velocity_requested = false

		debug_initial_click_position = Vector2.ZERO
		debug_final_click_position = Vector2.ZERO


func _input(event):
	# DEBUG: listen for mouse clicks
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			debug_initial_click_position = event.position
			debug_velocity_reset_requested = true
		else:
			debug_final_click_position = event.position
			debug_update_velocity_requested = true
