extends Panel

#signal shoot_pressed

func _on_action_button_button_down() -> void:
	#shoot_pressed.emit()
	#print("Botón apretado")
	pass # Replace with function body.


func _on_action_button_button_up() -> void:
	$"../..".player_controlled._on_shot_button_pressed()
	#shoot_pressed.emit()
	pass # Replace with function body.


func _on_action_button_pressed() -> void:
	$"../..".player_controlled._on_shot_button_pressed()
