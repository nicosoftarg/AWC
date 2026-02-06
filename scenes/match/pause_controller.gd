extends Node

var can_despause : bool = true

func _physics_process(_delta):
	if can_despause:
		if $"..".time > 1:
			if get_tree().paused == true:
				$"..".restarting_label.rotation = 0.0
				$"..".restarting_label.text = "PAUSED"
				$"..".restarting_label.visible = true
				despause_game()


func despause_game():
	if Input.is_action_just_pressed("pause"):
		can_despause = false
		$"..".restarting_label.visible = false
		get_tree().paused = false
		await get_tree().create_timer(1.0).timeout
		can_despause = true
		$"..".can_pause = true
		
