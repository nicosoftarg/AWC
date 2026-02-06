extends Node

@onready var update_behavior_scripts = $".."

func in_game(self_player, match_root, ball):
	match self_player.current_player_state:
		self_player.PlayerState.GO_TO_POSITION:
			go_to_position(self_player)
		self_player.PlayerState.GO_TO_BALL_ATTACK:
			go_to_ball_attack(self_player, ball, match_root)
		self_player.PlayerState.RECEIVER:
			receiver(self_player, ball)
		self_player.PlayerState.GO_TO_BALL_DEFENSE:
			go_to_ball_defense(self_player, ball, match_root)
		self_player.PlayerState.USER_CONTROLLED:
			user_controlled(self_player, ball)


func go_to_position(self_player):
	if self_player.at_target:
		self_player.move = false
		self_player.get_node("AnimatedSprite2D").play("idle")
	else:
		self_player.move = true
		self_player.get_node("AnimatedSprite2D").play("run")
		
		
func go_to_ball_attack(self_player, ball, match_root):
	if ball.player_with_ball:
		if ball.player_with_ball == self_player:
			if ball.current_ball_height_machine > 1:
				print("Altura pelota, corrigiendo")
				print(ball.current_ball_height_machine)
			ball.current_ball_arc_machine = ball.BallArcMachine.IDLE
			ball.arc_machine()
	self_player.at_target = false
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
	self_player.look_at(self_player.target)
	#self_player.move = true
	
	
	if_ball_in_hand(self_player, ball, match_root)
		

func receiver(self_player, ball):
	if self_player.check_ftf():
		self_player.get_node("Node/PivotIBA").global_position = self_player.global_position
		self_player.get_node("Node/PivotIBA").look_at(ball.global_position)
		
		
func go_to_ball_defense(self_player, ball, match_root):
	if self_player.can_move:
		if match_root.current_team_posesion == self_player.own_team:
			if ball.player_with_ball != self_player:
				self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
				self_player.behavior_tree()
		else:
			if self_player.ball.ball_in_hand == false:
				self_player.target = ball.global_position
				self_player.look_at(self_player.target)
			else:
				if !(self_player.current_player_state == self_player.PlayerState.WITH_BALL and self_player.current_player_with_ball == self_player.PlayerWithBall.PASS):
					self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION


func user_controlled(self_player, ball):
	self_player.at_target = false
	self_player.move = true
	if ball.player_with_ball == self_player:
		if Input.is_action_just_released("shot"):
			if self_player.direction.length() > 0.01:
				self_player.shot_user_controlled(self_player.direction)
			else:
				self_player.shoot_whithout_direction()
		if Input.is_action_just_released("pass"):
			self_player.button_pass_pressed()

					
# SUPPORT FUNCTIONS
# -----------------

func if_ball_in_hand(self_player, ball, match_root):
	if ball.ball_in_hand == false:
		if match_root.current_team_posesion == self_player.own_team:
			if ball.player_with_ball != null:
				self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
				self_player.behavior_tree()
		else:
			self_player.target = ball.global_position
			self_player.move_animations()
	else:
		self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
		self_player.behavior_tree()
