extends Control

@export var debugged_node : Node

func _process(_delta):
	set_labels()
	
func set_labels():
	$Col/TitileContainer/Title1.text = "current_match_state"
	$Col/VarContainer/Var1.text = debugged_node.MatchState.keys()[debugged_node.current_match_state]
	$Col/TitileContainer/Title2.text = "current_team_posesion"
	$Col/VarContainer/Var2.text = str(debugged_node.current_team_posesion)
	if debugged_node.player_controlled:
		$Col/TitileContainer/Title3.text = "player_controlled"
		$Col/VarContainer/Var3.text = debugged_node.player_controlled.name
	$Col/TitileContainer/Title4.text = "current_input_buffer_action"
	$Col/VarContainer/Var4.text = debugged_node.InputBufferActions.keys()[debugged_node.current_input_buffer_action]
	$Col/TitileContainer/Title5.text = "current_input_buffer_direction"
	$Col/VarContainer/Var5.text = debugged_node.InputBufferDirection.keys()[debugged_node.current_input_buffer_direction]
	$Col/TitileContainer/Titile6.text = "in_input_buffer_zone"
	$Col/VarContainer/Var6.text = str(debugged_node.in_input_buffer_zone)
	$Col/TitileContainer/Titile7.text = "receiver"
	$Col/VarContainer/Var7.text = str(debugged_node.receiver)
	$Col/TitileContainer/Titile9.text = "last_player_touch_ball"
	#if debugged_node.last_player_touch_ball:
		#$Col/TitileContainer/Var9.text = debugged_node.last_player_touch_ball.name

	
