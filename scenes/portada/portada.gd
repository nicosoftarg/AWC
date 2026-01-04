extends Control

@export_file('*.tscn') var new_game

func _ready():
	get_tree().paused = false
	Global.dbase_create()
	$AnimationPlayer.play("fade_in")
	$AnimationPlayer2.play("stadium_move")
	await get_tree().create_timer(2.0).timeout
	$Timer.start()

func _on_timer_timeout():
	if $StartLabel.visible == true:
		$StartLabel.visible = false
	else:
		$StartLabel.visible = true


func _on_button_pressed():
	get_tree().change_scene_to_file.call_deferred(new_game)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pass"):
		get_tree().change_scene_to_file.call_deferred(new_game)
