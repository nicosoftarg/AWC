extends Node


func restarting(self_player, Match, ball):
	match self_player.current_player_state:
		self_player.PlayerState.USER_RESTARTING:
			if Match.current_game_mode != Match.GameMode.CPU_VS_CPU and \
				Match.current_team_posesion == 0:
				match Match.current_restarting_state:
					Match.RestartingState.GOAL_KICK_0:
						user_goal_kick_restarter(self_player, ball, 270.0)
					Match.RestartingState.THROW_IN_L_0:
						user_throw_in_restarter(self_player, ball, "left", 0.0)
					Match.RestartingState.THROW_IN_R_0:
						user_throw_in_restarter(self_player, ball, "right", 180.0)
					_:
						user_restarting(self_player, ball)	
		self_player.PlayerState.GO_TO_BALL_ATTACK:
			go_to_ball_attack(self_player, ball)
		self_player.PlayerState.GO_TO_CORNER_POSITION:
			if self_player.distance_to_target_general < 1:
				self_player.at_target = true
			else:
				self_player.at_target = false	
			if self_player.at_target:
				self_player.move = false
				self_player.get_node("AnimatedSprite2D").play("idle")
			else:
				self_player.move = true
				
			self_player.move_animations()

func user_throw_in_restarter(self_player, ball, throw_in_side, rot : float):
	self_player.get_node("AnimatedSprite2D").speed_scale = 0.0
	self_player.get_node("AnimatedSprite2D").play("throw_in")
	if throw_in_side == "left":
		if Input.is_action_pressed("ui_up"):
			rot = 315
		elif Input.is_action_pressed("ui_down"):
			rot = 45
		elif Input.is_action_pressed("ui_right"):
			rot = 0
	else:
		if Input.is_action_pressed("ui_up"):
			rot = 225
		elif Input.is_action_pressed("ui_down"):
			rot = 135
		elif Input.is_action_pressed("ui_right"):
			rot = 180
	
	#print("Rot: ", deg_to_rad(rot))
	ball.global_rotation = deg_to_rad(rot)
	self_player.rotation = deg_to_rad(rot)
	ball.global_position = self_player.hand_throw_in.global_position
	if Input.is_action_just_released("pass"):
		self_player.get_node("AnimatedSprite2D").speed_scale = 1.0
		ball.get_node("BallAnimSpr").position.x = 0
		self_player.restarter_throw_in_behaviour_user_team(self_player) # Poner el player acá está bien?


func user_goal_kick_restarter(self_player, ball, rot : float):

	if Input.is_action_pressed("ui_right"):
		rot = 315
	elif Input.is_action_pressed("ui_left"):
		rot = 225
	elif Input.is_action_pressed("ui_up"):
		rot = 270


	ball.global_rotation = deg_to_rad(rot)


	if Input.is_action_just_released("pass"):
		ball.goal_kick_arrow.visible = false
		user_restarting(self_player, ball)
				
func user_restarting(self_player, ball):
	self_player.target = ball.global_position
	if Input.is_action_just_released("pass"):
		self_player.can_move = true
		if self_player.distance_to_target_general < 1:
			self_player.at_target = true
		else:
			self_player.at_target = false	
		if self_player.at_target:
			self_player.move = false
			self_player.get_node("AnimatedSprite2D").play("idle")
		else:
			self_player.move = true
		self_player.move_animations()

func go_to_ball_attack(self_player, ball):
	self_player.target = ball.global_position
	if self_player.distance_to_target_general < 1:
		self_player.at_target = true
	else:
		self_player.at_target = false	
	if self_player.at_target:
		self_player.move = false
		self_player.get_node("AnimatedSprite2D").play("idle")
	else:
		self_player.move = true
		
	self_player.move_animations()
