extends Control

@export var debugged_node : Node

func _process(_delta):
	set_labels()
	
func set_labels():
	$Col/TitileContainer/Title1.text = "current_player_state"
	$Col/VarContainer/Var1.text = debugged_node.PlayerState.keys()[debugged_node.current_player_state]
		
		
