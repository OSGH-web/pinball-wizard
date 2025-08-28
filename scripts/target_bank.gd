extends Node2D
class_name TargetBank

var targets = []
var time_bonus := 15.0
var score_bonus = 5000

signal add_time
signal add_score_bonus

func _ready():
	targets = [$Target, $Target2, $Target3]
	
	for target: Target in targets:
		target.connect("target_is_hit", check_if_targets_hit)
		

func check_if_targets_hit():
	var target_hit_count = 0
	for target: Target in targets:
		if target.state == Target.TargetState.LOWERED:
			target_hit_count += 1
	
	if target_hit_count == 1:
		$KnockdownTimer.start()
		return
	
	if target_hit_count == 3:
		add_time.emit(time_bonus)
		add_score_bonus.emit(score_bonus)

		$TargetBankCompleteSound.play()

		await get_tree().create_timer(2).timeout
		reset_all_targets()
	
	
func reset_all_targets():
	for target: Target in targets:
		target.raise_target()
	

func _on_knockdown_timer_timeout() -> void:
	reset_all_targets()
