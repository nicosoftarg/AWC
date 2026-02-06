extends Node

func signals_connect(Match, self_player, goals): 
	Match.match_state_changed.connect(self_player._on_match_state_changed)
	goals[0].Goal.connect(self_player._on_goal_scored)
	goals[1].Goal.connect(self_player._on_goal_scored)	
	
	
func set_initial_kick_off(Match, self_player, ball): 
	if Match.current_team_posesion == self_player.own_team:
		if self_player.get_parent().restarter1 == self_player:
			self_player.global_position = Match.restarter_point_1.global_position
			self_player.look_at(self_player.ball.global_position)
		elif self_player.get_parent().restarter2 == self_player:
			self_player.global_position = Match.restarter_point_2.global_position	
			self_player.look_at(self_player.ball.global_position)
			
			
func set_shirt_palette(sprite, self_player): 
	var mat = sprite.material.duplicate()
	sprite.material = mat
	sprite.material.set_shader_parameter("palette_to", self_player.get_parent().team_palette)

	
func set_player_level(self_player): # READY SETS
	self_player.user_player_speed = self_player.get_parent().user_player_speed
	self_player.cpu_player_speed = self_player.get_parent().cpu_player_speed
	self_player.time_decision = self_player.get_parent().time_decision 	
