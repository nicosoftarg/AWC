extends Node

@onready var with_ball = $WithBall


func in_game(self_player, Match, ball):
	match self_player.current_player_state:
		self_player.PlayerState.GO_TO_KICKOFF_POSITION_RESTARTER_2:
			go_to_kickoff_position_restarter_2(self_player, Match)
		self_player.PlayerState.GO_TO_KICKOFF_POSITION:
			self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
			self_player.behavior_tree()
		self_player.PlayerState.GO_TO_POSITION:
			get_parent().go_to_position(self_player, Match)
		self_player.PlayerState.RECEIVER:
			self_player.can_move = false
		self_player.PlayerState.WITH_BALL:
			with_ball.with_ball(self_player, Match, ball)
		self_player.PlayerState.NOT_AVAILABLE:
			not_available(self_player, Match)
		self_player.PlayerState.RESTARTER_THROW_IN:
			restarter_throw_in(self_player)

			

func go_to_kickoff_position_restarter_2(self_player, Match):
	if self_player.own_team == 0 and Match.current_game_mode == Match.GameMode.PLAYER_VS_CPU:
		self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
		self_player.behavior_tree()


func not_available(self_player, Match):
	self_player.can_move = false
	self_player.get_node("AnimatedSprite2D").play("fall")
	user_controlled_not_available(self_player, Match)
	self_player.set_collision_mask_value(2, false)
	self_player.target = self_player.global_position
	await get_tree().create_timer(2.0).timeout
	self_player.set_collision_mask_value(2, true)
	self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
	self_player.can_move = true
	self_player.behavior_tree()


func restarter_throw_in(self_player):
	await get_tree().create_timer(3.0).timeout
	self_player.set_collision_mask_value(2, true)
	self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
	self_player.can_move = true
	self_player.behavior_tree()

# SUPPORT FUNCTIONS
# -----------------
			
func if_user_controlled(self_player): 
	print("se activó el if_user_controlled")
	if self_player.Match.player_controlled != self_player:
		if self_player.current_player_state != self_player.PlayerState.NOT_AVAILABLE:
			self_player.current_player_state = self_player.PlayerState.USER_CONTROLLED
			self_player.move = true
			self_player.can_move = true
			
			
func user_controlled_not_available(self_player, Match):
	if self_player.Match.player_controlled == self_player:
		Match.player_controlled	= Match.get_player_controlled()
		if Match.player_controlled:
			Match.player_controlled.current_player_state = self_player.PlayerState.USER_CONTROLLED
			#Match.player_controlled.user_controlled = true
	else:
		if Match.player_controlled == self_player:
			print("Esto está mal")
