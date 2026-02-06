extends Control

@export var debugged_node : Node

func _process(_delta):
	set_labels()
	
func set_labels():
	if debugged_node.player_with_ball:
		$Col/TitileContainer/Title1.text = "player_with_ball"
		$Col/VarContainer/Var1.text = debugged_node.player_with_ball.name
	$Col/TitileContainer/Title2.text = "ball_in_hand"
	$Col/VarContainer/Var2.text = str(debugged_node.ball_in_hand)
	$Col/TitileContainer/Title3.text = "current_ball_height_machine"
	$Col/VarContainer/Var3.text = debugged_node.BallHeightMachine.keys()[debugged_node.current_ball_height_machine]
	$Col/TitileContainer/Title4.text = "current_ball_move_machine"
	$Col/VarContainer/Var4.text = debugged_node.BallMoveMachine.keys()[debugged_node.current_ball_move_machine]
	$Col/TitileContainer/Title5.text = "current_ball_arc_machine"
	$Col/VarContainer/Var5.text = debugged_node.BallArcMachine.keys()[debugged_node.current_ball_arc_machine]
