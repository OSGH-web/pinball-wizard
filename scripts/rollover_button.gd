extends Node2D
class_name RolloverButton


enum RolloverButtonState { UNSET, SET }

var state = RolloverButtonState.UNSET

const score_value = 500

signal button_is_set


func _on_body_entered(body: Node2D) -> void:
	if state == RolloverButtonState.UNSET:
		set_rolloverbutton()

		if body is Ball:
			body.modify_score.emit(score_value)
			button_is_set.emit()

			$RolloverButtonSound.play()


func reset_rolloverbutton():
	state = RolloverButtonState.UNSET
	$AnimatedSprite2D.frame = 0


func set_rolloverbutton():
	if state == RolloverButtonState.SET:
		return

	state = RolloverButtonState.SET
	$AnimatedSprite2D.frame = 1
