extends RigidBody2D
class_name Ball

const N_ANIMATION_FRAMES = 16
const BIN_SIZE = 360/N_ANIMATION_FRAMES

# debug variables
var debug_initial_click_position := Vector2.ZERO
var debug_final_click_position := Vector2.ZERO
var debug_velocity_reset_requested := false
var debug_update_velocity_requested := false
# This should probably go up as the game goes on.
var death_penalty = -1000
const debug_throw_strength_multiplier := 2.5
signal modify_score
	
var global_collision_pos : Vector2 = Vector2.ZERO

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.get_contact_count() > 0:
		var collider = state.get_contact_collider_object(0)

		if collider.name == "FlipperBodyActive" && collider.get_parent().get_parent() is Flipper:
			global_collision_pos = state.get_contact_local_position(0)
			collider.get_parent().get_parent().apply_collision_force(self)

		elif collider.get_parent() is Plunger:
			collider.get_parent().apply_collision_force(self)

func _on_body_entered(body: Node) -> void:
	if body.get_parent() is Bumper && body.name == "Active":
		body.get_parent().apply_collision_force(self)
		modify_score.emit(Bumper.score_value)
	elif body is CircleBumper:
		body.apply_collision_force(self)
		modify_score.emit(CircleBumper.score_value)
	elif body is Target:
		if body.state == Target.TargetState.RAISED:
			body.lower_target()
			modify_score.emit(body.score_value)
			body.target_is_hit.emit()

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
			
			
func die():
	modify_score.emit(death_penalty, true)
	self.queue_free()
	

func increment_collision_layer():
	if get_collision_layer_value(1):
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		set_collision_layer_value(2, true)
		set_collision_mask_value(2, true)
		print("moved ball to higher collision layer")

func decrement_collision_layer():
	if get_collision_layer_value(2):
		set_collision_layer_value(1, true)
		set_collision_mask_value(1, true)
		set_collision_layer_value(2, false)
		set_collision_mask_value(2, false)
		print("moved ball to lower collision layer")
