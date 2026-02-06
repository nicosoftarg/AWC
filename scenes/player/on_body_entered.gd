extends Node

@onready var root : Area2D = $"../.."

func on_body_entered(body):
	if body is RigidBody2D:
		arc_ball_restart(body)
		gk_restart(root.Match)
		root.Match.last_player_touch_ball = root
		root.Match.current_team_posesion = root.own_team
		match root.own_team:
			1:
				player_ia_body_entered(body)
			_:
				if root.Match.current_game_mode == root.Match.GameMode.CPU_VS_CPU:
					player_ia_body_entered(body)
				else:
					match root.Match.current_match_state:
						root.Match.MatchState.RESTARTING:
							user_restarting(body, root.Match)
						root.Match.MatchState.IN_GAME:
							if root.Match.player_controlled:
								if_player_controlled_exist(root.Match.player_controlled)
							if root.Match.current_input_buffer_action == root.Match.InputBufferActions.NOTHING:
								input_buffer_is_nothing(body)
							else:
								match root.Match.current_input_buffer_action:
									root.Match.InputBufferActions.SHOOT:
										player_user_ftf_body_entered(body, root.Match)


func arc_ball_restart(ball):
	ball.current_ball_arc_machine = ball.BallArcMachine.IDLE
	ball.arc_machine()


func arc_height_restart(ball):
	ball.current_ball_height_machine = ball.BallHeightMachine.GROUND # ALTURA
	ball.height_machine()


func gk_restart(Match):
	if Match.gk_0.current_player_state != Match.gk_0.PlayerState.SAVING or Match.gk_0.current_player_state != Match.gk_0.PlayerState.BOUNCING:
		Match.gk_0.current_player_state = Match.gk_0.PlayerState.GO_TO_GK_POSITION
		Match.gk_0.behavior_tree()
	if Match.gk_1.current_player_state != Match.gk_1.PlayerState.SAVING or Match.gk_1.current_player_state != Match.gk_1.PlayerState.BOUNCING:
		Match.gk_1.current_player_state = Match.gk_1.PlayerState.GO_TO_GK_POSITION
		Match.gk_1.behavior_tree()	


func input_buffer_restart(match_root):
	match_root.current_input_buffer_action = match_root.InputBufferActions.NOTHING
	match_root.current_input_buffer_direction = match_root.InputBufferDirection.FORWARD


func player_ia_body_entered(ball):
	root.can_move = true
	arc_height_restart(ball)
	input_buffer_restart(root.Match)
	match root.Match.current_match_state:
		root.Match.MatchState.RESTARTING:
			ia_restarting(root.Match)
		root.Match.MatchState.IN_GAME:
			if ball.player_with_ball == null:
				ia_ball_was_in_possession(ball, root.Match)
			else:
				ia_ball_was_not_in_possession(ball, root.Match)
				
				
func ia_restarting(root_match):
	root.ball.player_with_ball = root
	root_match.receiver = root.set_set_pieces_receiver()
	root.pass_ball(root_match.receiver)
	root_match.current_match_state = root_match.MatchState.IN_GAME
	root_match.process_match_states()
	root_match.match_state_changed.emit()


func ia_ball_was_in_possession(ball, root_match):
	ball.player_with_ball = root
	if root_match.receiver == root:
		root_match.receiver = null
	else:
		if root_match.receiver:
			root_match.receiver.can_move = true
			root_match.receiver.current_player_state = root_match.receiver.PlayerState.GO_TO_POSITION
	root.can_move = true
	root.current_player_state = root.PlayerState.WITH_BALL
	root.current_player_with_ball = root.PlayerWithBall.GO_TO_ATTACK_POSITION
	root.behavior_tree()
	root_match.match_state_changed.emit()


func ia_ball_was_not_in_possession(ball, root_match):
	if ball.player_with_ball.field_player:
		root.can_move = true
		ball.player_with_ball.get_node("TimerDecision").stop()
		if root_match.saver_goalkeeper:
			if root_match.saver_goalkeeper.can_move:
				root_match.saver_goalkeeper.current_player_state = root_match.saver_goalkeeper.PlayerState.GO_TO_GK_POSITION
				root_match.saver_goalkeeper.behavior_tree()
				root_match.saver_goalkeeper = null
	if root.own_team != ball.player_with_ball.own_team:
		var loose_ball = ball.player_with_ball
		loose_ball.current_player_state = loose_ball.PlayerState.NOT_AVAILABLE
		loose_ball.behavior_tree()		
	else:
		ball.player_with_ball.current_player_state = root.PlayerState.GO_TO_POSITION
		ball.player_with_ball.behavior_tree()
	ball.player_with_ball = root
	root.current_player_state = root.PlayerState.WITH_BALL
	root.current_player_with_ball = root.PlayerWithBall.GO_TO_ATTACK_POSITION
	root_match.match_state_changed.emit()


func if_player_controlled_exist(player_controlled):
	if player_controlled.own_team == root.own_team:					
		#player_controlled.user_controlled = false
		player_controlled.current_player_state = root.PlayerState.GO_TO_POSITION
		player_controlled.behavior_tree()
	else:
		player_controlled.current_player_state = root.PlayerState.NOT_AVAILABLE
		player_controlled.behavior_tree()


func input_buffer_is_nothing(ball):
	arc_height_restart(ball)
	root.Match.player_controlled = root
	root.current_player_state = root.PlayerState.USER_CONTROLLED
	#root.user_controlled = true
	root.can_move = true
	root.move = true
	player_user_body_entered(ball, root.Match)

	
func player_user_body_entered(ball, root_match):
	root_match.last_player_touch_ball = root
	if ball.player_with_ball == null:
		user_ball_was_in_possession(ball, root_match)
	else:
		user_ball_in_possesion(ball, root_match)
	#root_match.match_state_changed.emit()

			
func user_restarting(ball, _root_match):
	ball.player_with_ball = root
	root.button_pass_pressed()
	#ball.player_with_ball = root
	#root_match.receiver = root.set_set_pieces_receiver()
	#root.pass_ball(root_match.receiver)
	root.Match.current_match_state = root.Match.MatchState.IN_GAME
	root.Match.process_match_states()
	root.Match.match_state_changed.emit() 
	
	
func user_ball_was_in_possession(ball, root_match):
	ball.player_with_ball = root
	root_match.current_input_buffer_action = root_match.InputBufferActions.NOTHING
	root_match.current_input_buffer_direction = root_match.InputBufferDirection.FORWARD
	match root_match.current_match_state:
		root_match.MatchState.IN_GAME:
			if root_match.receiver == root:
				root_match.receiver = null
				root.can_move = true
			else:
				if root_match.receiver:
					if root_match.receiver == root:
						root_match.receiver = null
						root.current_player_state = root.PlayerState.USER_CONTROLLED
						root.can_move = true
					else:
						root_match.receiver.current_player_state = root.PlayerState.GO_TO_POSITION
	#root_match.match_state_changed.emit() # Esto estaría duplicado


func user_ball_in_possesion(ball, root_match):
	if ball.player_with_ball.field_player:
		ball.player_with_ball.get_node("TimerDecision").stop()
		if root_match.saver_goalkeeper:
			root_match.saver_goalkeeper.current_player_state = root.PlayerState.GO_TO_POSITION
			root_match.saver_goalkeeper.behavior_tree()
			root_match.saver_goalkeeper = null
	if root.own_team != ball.player_with_ball.own_team:
		ball.player_with_ball.current_player_state = root.PlayerState.NOT_AVAILABLE
		ball.player_with_ball.behavior_tree()
	else:
		ball.player_with_ball.current_player_state = root.PlayerState.GO_TO_POSITION
		ball.player_with_ball.behavior_tree()
	ball.player_with_ball = root


func player_user_ftf_body_entered(ball, root_match):
	root_match.last_player_touch_ball = root
	if ball.player_with_ball == null:
		ball.player_with_ball = root
		if root_match.receiver == root:
			root_match.receiver = null
			if root_match.current_input_buffer_action == root_match.InputBufferActions.SHOOT:
				root.current_player_state = root.PlayerState.WITH_BALL
				root.current_player_with_ball = root.PlayerWithBall.SHOT_FTF
				root.behavior_tree()
		else:
			if root_match.receiver:
				if root_match.receiver == root:
					root_match.receiver = null
					if root_match.current_input_buffer_action == root_match.InputBufferActions.SHOOT:
						root.current_player_state = root.PlayerState.WITH_BALL
						root.current_player_with_ball = root.PlayerWithBall.SHOT_FTF
						root.behavior_tree()
				else:
					if root_match.current_input_buffer_action == root_match.InputBufferActions.SHOOT:
						root.current_player_state = root.PlayerState.WITH_BALL
						root.current_player_with_ball = root.PlayerWithBall.SHOT_FTF
						root.behavior_tree()
					else:				
						root_match.receiver.current_player_state = root.PlayerState.GO_TO_POSITION
						root_match.receiver.behavior_tree()

	
	
	
