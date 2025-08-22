extends Node2D
class_name Paddle

# --- State definitions ---
enum PaddleState { IDLE, TRIGGERED, RISING, FALLING }  # Paddle motion phases
enum PaddleInput { NONE, PRESS, RELEASE }              # Player input events

# --- Constants ---
const PADDLE_STRENGTH: float = 15
const TRIGGERED_COYOTE_FRAME_MAX: int = 3

# --- Runtime variables ---
var state: PaddleState = PaddleState.IDLE
var input: PaddleInput = PaddleInput.NONE
var triggered_coyote_frame_count: int = 0

@export var left_paddle: bool = true:
	set(lp):
		left_paddle = lp
		if left_paddle:
			scale = Vector2(1, 1)
		else:
			scale = Vector2(-1, 1)
			$ANGLE.scale = Vector2(-1, 1)
			$PERP_ANGLE.scale = Vector2(-1, 1)


func _ready():
	$AnimationPlayer.connect("animation_finished", func(anim_name: StringName):
		if anim_name == "fall":
			state = PaddleState.IDLE
		elif anim_name == "trigger":
			state = PaddleState.TRIGGERED
			triggered_coyote_frame_count = 0
		)
	
func _physics_process(delta: float) -> void:
	update_debug_labels()
	update_state()
	
	if state == PaddleState.TRIGGERED:
		triggered_coyote_frame_count += 1


func update_debug_labels() -> void:
	$Label.rotation_degrees = get_perpendicular_angle()
	$ANGLE.text = str(get_current_paddle_angle())
	$PERP_ANGLE.text = str(get_perpendicular_angle())


func apply_collision_force(ball: RigidBody2D):
	if state != PaddleState.RISING:
		if state != PaddleState.TRIGGERED:
			return
		elif triggered_coyote_frame_count >= TRIGGERED_COYOTE_FRAME_MAX:
			return

	var perpendicular_angle = get_perpendicular_angle()
	
	var force = Vector2(0, 1).rotated(deg_to_rad(perpendicular_angle)) * PADDLE_STRENGTH
	
	ball.apply_central_impulse(force)

func get_current_paddle_angle():
	if not left_paddle:
		return 55 - $StaticBody2D.rotation_degrees
	else:
		return $StaticBody2D.rotation_degrees - 55

func get_perpendicular_angle():
	var current_paddle_angle = get_current_paddle_angle()
	# Flip perpendicular depending on left/right side
	var perpendicular_angle: float = current_paddle_angle - 90
	if not left_paddle:
		perpendicular_angle *= -1
		perpendicular_angle += 180
		
	return perpendicular_angle

func _input(event):
	var input_signal = _get_input_signal()
	if event.is_action_pressed(input_signal):
		input = PaddleInput.PRESS
		
	if event.is_action_released(input_signal):
		input = PaddleInput.RELEASE

func _get_input_signal():
	if left_paddle:
		return "ui_left"
	else:
		return "ui_right"
		
func update_state() -> void:
	if input == PaddleInput.NONE:
		return

	match state:
		PaddleState.IDLE:
			if input == PaddleInput.PRESS:
				$AnimationPlayer.play("trigger")
				state = PaddleState.RISING
				input = PaddleInput.NONE
		
		PaddleState.TRIGGERED:
			if input == PaddleInput.RELEASE:
				$AnimationPlayer.play("fall")
				state = PaddleState.FALLING
				input = PaddleInput.NONE
		
		PaddleState.FALLING:
			if input == PaddleInput.PRESS:
				var current_frame = $AnimatedSprite2D.frame
				var frame_rate = 60.0
				var start_time = current_frame / frame_rate
				$AnimationPlayer.play_section("trigger", start_time)
				state = PaddleState.RISING
	
				input = PaddleInput.NONE
