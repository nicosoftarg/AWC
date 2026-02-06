extends Node

func set_bounces_steps(bounces_steps, bounces_dict):
	bounces_steps.append(bounces_dict.no_bounce)
	bounces_steps.append(bounces_steps[0] + bounces_dict.good_bounce)
	bounces_steps.append(bounces_steps[1] + bounces_dict.corner_bounce)
	bounces_steps.append(bounces_steps[2] + bounces_dict.bad_bounce)
	bounces_steps.append(bounces_steps[3] + bounces_dict.goal_bounce)
	


func set_player_level(self_gk):
	if self_gk.own_team == 0:
		self_gk.user_player_speed =	self_gk.get_parent().gk_player_speed
		self_gk.bounces_dict = self_gk.get_parent().bounces_dict.duplicate(true)
	else:
		self_gk.cpu_player_speed = self_gk.get_parent().gk_player_speed
		self_gk.bounces_dict = self_gk.get_parent().bounces_dict.duplicate(true)
		
		
