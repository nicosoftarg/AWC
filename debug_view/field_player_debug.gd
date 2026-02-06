extends Control

@export var debugged_node : Node

func _process(_delta):
	set_labels()
	
func set_labels():
	if debugged_node.player_controlled and debugged_node.player_controlled.field_player:
		$Col/TitileContainer/Title1.text = "current_player_state"
		$Col/VarContainer/Var1.text = debugged_node.player_controlled.PlayerState.keys()[debugged_node.player_controlled.current_player_state]
		$Col/TitileContainer/Title2.text = "current_player_with_ball"
		$Col/VarContainer/Var2.text = debugged_node.player_controlled.PlayerWithBall.keys()[debugged_node.player_controlled.current_player_with_ball]
		$Col/TitileContainer/Title3.text = "impulse_type"
		$Col/VarContainer/Var3.text = debugged_node.player_controlled.ImpulseTypeMachine.keys()[debugged_node.player_controlled.impulse_type]
		$Col/TitileContainer/Title4.text = "move"
		$Col/VarContainer/Var4.text = str(debugged_node.player_controlled.move)
		$Col/TitileContainer/Title5.text = "can_move"
		$Col/VarContainer/Var5.text = str(debugged_node.player_controlled.can_move)
		$Col/TitileContainer/Title6.text = "at_target"
		$Col/VarContainer/Var6.text = str(debugged_node.player_controlled.at_target)
	
