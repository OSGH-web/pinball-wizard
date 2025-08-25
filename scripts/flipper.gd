extends Node2D
class_name Flipper

# --- State definitions ---
enum FlipperState { IDLE, TRIGGERED, RISING, FALLING }  # Flipper motion phases
enum FlipperInput { NONE, PRESS, RELEASE }              # Player input events

# --- Constants ---
const FLIPPER_STRENGTH: float = 30
const TRIGGERED_COYOTE_FRAME_MAX: int = 3

# --- Runtime variables ---
var state: FlipperState = FlipperState.IDLE
var input: FlipperInput = FlipperInput.NONE
var triggered_coyote_frame_count: int = 0

@export var left_flipper: bool = true:
	set(lp):
		left_flipper = lp
		if left_flipper:
			scale = Vector2(1, 1)
		else:
			scale = Vector2(-1, 1)
			$ANGLE.scale = Vector2(-1, 1)
			$PERP_ANGLE.scale = Vector2(-1, 1)


func _ready():
	$AnimationPlayer.connect("animation_finished", func(anim_name: StringName):
		if anim_name == "fall":
			state = FlipperState.IDLE
		elif anim_name == "trigger":
			state = FlipperState.TRIGGERED
			triggered_coyote_frame_count = 0
		)
	
func _physics_process(delta: float) -> void:
	update_debug_labels()
	update_state()
	
	if state == FlipperState.TRIGGERED:
		triggered_coyote_frame_count += 1


func update_debug_labels() -> void:
	$Label.rotation_degrees = get_perpendicular_angle()
	$ANGLE.text = "%0.2d" % get_current_flipper_angle()
	$PERP_ANGLE.text = "%0.2d" % get_perpendicular_angle()


func apply_collision_force(ball: RigidBody2D):
	if state != FlipperState.RISING:
		if state != FlipperState.TRIGGERED:
			return
		elif triggered_coyote_frame_count >= TRIGGERED_COYOTE_FRAME_MAX:
			return

	var perpendicular_angle = get_perpendicular_angle()
	
	var force = Vector2(0, 1).rotated(deg_to_rad(perpendicular_angle)) * FLIPPER_STRENGTH
	
	ball.apply_central_impulse(force)

func get_current_flipper_angle():
	if not left_flipper:
		return 55 - $FlipperBody.rotation_degrees
	else:
		return $FlipperBody.rotation_degrees - 55

func get_perpendicular_angle():
	var current_flipper_angle = get_current_flipper_angle()
	# Flip perpendicular depending on left/right side
	var perpendicular_angle: float = current_flipper_angle - 90
	if not left_flipper:
		perpendicular_angle *= -1
		perpendicular_angle += 180
		
	return perpendicular_angle

func _input(event):
	var input_signal = _get_input_signal()
	if event.is_action_pressed(input_signal):
		input = FlipperInput.PRESS
		
	if event.is_action_released(input_signal):
		input = FlipperInput.RELEASE

func _get_input_signal():
	if left_flipper:
		return "ui_left"
	else:
		return "ui_right"
		
func update_state() -> void:
	if input == FlipperInput.NONE:
		return

	match state:
		FlipperState.IDLE:
			if input == FlipperInput.PRESS:
				$AnimationPlayer.play("trigger")
				$AudioStreamPlayer.play()
				state = FlipperState.RISING
				input = FlipperInput.NONE
		
		FlipperState.TRIGGERED:
			if input == FlipperInput.RELEASE:
				$AnimationPlayer.play("fall")
				state = FlipperState.FALLING
				input = FlipperInput.NONE
		
		FlipperState.FALLING:
			if input == FlipperInput.PRESS:
				var current_frame = $AnimatedSprite2D.frame
				var frame_rate = 60.0
				var start_time = current_frame / frame_rate
				$AnimationPlayer.play_section("trigger", start_time)
				$AudioStreamPlayer.play()
				state = FlipperState.RISING
	
				input = FlipperInput.NONE
