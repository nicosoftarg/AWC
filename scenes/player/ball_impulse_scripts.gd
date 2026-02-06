extends Node

#func throw_in(receiver): # KICK
	#impulse_type = ImpulseTypeMachine.PASS
	#Match.current_match_state = Match.MatchState.IN_GAME
	#Match.process_match_states()
	#can_move = false
	#look_at(receiver.global_position)
	#pass_target = receiver.global_position
	#receiver.current_player_state = PlayerState.RECEIVER
	#if ball.player_with_ball == self:
		#ball.player_with_ball = null
		##$DefenseZone.set_collision_mask_value(8, false) # TRIGGER
		#var dir = ball.global_position.direction_to(pass_target)
		#dir = dir.normalized()
		#var impulse = dir * pass_power
		#Match.match_state_changed.emit()
		#ball.linear_velocity = Vector2.ZERO
		#$AnimatedSprite2D.play("throw_in")
		#await get_tree().create_timer(0.1).timeout
		#ball.apply_central_impulse(impulse)
		#var distance = global_position.distance_to(pass_target)
		#ball.set_max_ball_height(distance, pass_power, impulse_type)
		##ball.set_ball_height(distance, pass_power) # PRobando nuevo sistema - ALTURA
		#await get_tree().create_timer(0.1).timeout
		#set_collision_mask_value(2, true)
		##for player in get_tree().get_nodes_in_group("player"):
			##player.get_node("DefenseZone").set_collision_mask_value(8, true) # TRIGGER
		#await get_tree().create_timer(0.2).timeout
		#can_move = true
		#move_animations()
		#await get_tree().create_timer(1.0).timeout
		#can_throw_in = true
#
#
#func choice_reveicer(): # KICK
	#var temporal_option_pass = option_pass.duplicate(true)
	#
	#if temporal_option_pass.size() > 2: 
		#if temporal_option_pass[2].current_player_state == PlayerState.NOT_AVAILABLE:
				#temporal_option_pass.erase(temporal_option_pass[2])
	#elif temporal_option_pass.size() > 1:
		#if temporal_option_pass[1].current_player_state == PlayerState.NOT_AVAILABLE:
				#temporal_option_pass.erase(temporal_option_pass[1])
	#elif temporal_option_pass.size() > 0:
		#if temporal_option_pass[0].current_player_state == PlayerState.NOT_AVAILABLE:
				#temporal_option_pass.erase(temporal_option_pass[0])
	#else:
		#print("No hay ninguna opción de pase")
		#
	#Match.receiver = temporal_option_pass.pick_random()	
	#
	#
#func pass_ball_user_controlled(receiver : Area2D): # KICK - 30 líneas
	#can_move = false
	#look_at(receiver.global_position)
	#pass_target = receiver.global_position
	#own_pass_receiver = receiver
	#receiver.current_player_state = PlayerState.RECEIVER
	#receiver.behavior_tree()
	#if ball.player_with_ball == self:
		#ball.player_with_ball = null
		#set_collision_mask_value(2, false)
		#var dir = ball.global_position.direction_to(pass_target)
		#dir = dir.normalized()
		#var impulse = dir * pass_power
		#if Match.current_match_state == Match.MatchState.RESTARTING:
			#Match.current_match_state = Match.MatchState.IN_GAME
			#Match.process_match_states()
		#ball.linear_velocity = Vector2.ZERO
		#$AnimatedSprite2D.play("pass")
		#Match.audio_shot.play()
		#ball.apply_central_impulse(impulse)
		#if get_parent().rival_goal.in_aerial_pass_zone:
			#impulse_type = ImpulseTypeMachine.CROSS
		#else:
			#impulse_type = ImpulseTypeMachine.PASS
		#var distance = global_position.distance_to(pass_target)
		#ball.set_max_ball_height(distance, pass_power, impulse_type)
		##ball.set_ball_height(distance, pass_power) # - ALTURA
		#await get_tree().create_timer(0.8).timeout # Estaba en 0.3
		#set_collision_mask_value(2, true)
		##$DefenseZone.set_collision_mask_value(8, true) # TRIGGER
		#await get_tree().create_timer(0.7).timeout
		#own_pass_receiver = null
		#can_move = true
		#
		#
#func pass_ball(receiver : Area2D): # KICK - 30 líneas
	#can_move = false
	#look_at(receiver.global_position)
	#pass_target = receiver.global_position
	#receiver.current_player_state = PlayerState.RECEIVER
	#receiver.behavior_tree()
	#own_pass_receiver = receiver
	#impulse_type = ImpulseTypeMachine.PASS
	#
	#if ball.player_with_ball == self:
		#ball.player_with_ball = null
		#set_collision_mask_value(2, false)
		#var dir = ball.global_position.direction_to(pass_target)
		#dir = dir.normalized()
		#var impulse = dir * pass_power
		#if Match.current_match_state != Match.MatchState.IN_GAME:
			#Match.current_match_state = Match.MatchState.IN_GAME
			#Match.process_match_states()
		#ball.linear_velocity = Vector2.ZERO
		#$AnimatedSprite2D.play("pass")
		#await get_tree().create_timer(0.1).timeout
		#Match.audio_shot.play()
		#ball.apply_central_impulse(impulse)
		#var distance = global_position.distance_to(pass_target)
		#ball.set_max_ball_height(distance, pass_power, impulse_type)
		#await get_tree().create_timer(0.8).timeout #Estaba en 0.3
		#set_collision_mask_value(2, true)
		#await get_tree().create_timer(0.5).timeout
		##$DefenseZone.set_collision_mask_value(8, true) # TRIGGER
		#current_player_state = PlayerState.GO_TO_POSITION
		#can_move = true
		#own_pass_receiver = null
		#behavior_tree()
		#move_animations()
		#
		#
#func gk_saving(): # KICK
	#var rival_gk
	#match own_team:
		#0:
			#rival_gk = Match.gk_1
		#_:
			#rival_gk = Match.gk_0
	#rival_gk.current_player_state = rival_gk.PlayerState.SAVING
	#rival_gk.shooter = self
	#Match.saver_goalkeeper = rival_gk
	#rival_gk.behavior_tree()
	#
	#
#func shot(target_goal): # KICK REFACTORIZAR - 25 líneas 
	#if ball.player_with_ball == self:
		#can_move = false
		#set_collision_mask_value(2, false)
		#ball.player_with_ball = null
		#var dir = ball.global_position.direction_to(target_goal)
		#dir = dir.normalized()
		#look_at(target_goal)
		#var impulse = dir * (shot_power * 1.2)
		#ball.linear_velocity = Vector2.ZERO
		#set_shoot_animation(ball.current_ball_height_machine)
		#if delay:
			#await get_tree().create_timer(delay_shoot).timeout
		#ball.apply_central_impulse(impulse)
		#Match.audio_shot.play()
		#Match.goal_scorer_position = global_position
		#gk_saving()
		#impact_x_gk_calculate(impulse)
		#await get_tree().create_timer(0.3).timeout
		#set_collision_mask_value(2, true)
		#await get_tree().create_timer(0.7).timeout
		#if Match.current_match_state != Match.MatchState.STOP_GAME:
			#current_player_state = PlayerState.GO_TO_POSITION
		#can_move = true
		#move_animations()
		#behavior_tree()
		#
		#
#func set_shoot_animation(ball_height : int): #KICK
	#if ball_height >= 2:
		#$AnimatedSprite2D.play("heading")
		#delay = false
		#ball.current_ball_arc_machine = ball.BallArcMachine.DESCENDING
		#ball.arc_machine()
	#else:
		#$AnimatedSprite2D.play("shot")
		#delay = true
#
#
#func shot_user_controlled(dir): # KICK REFACTORIZAR
	#if ball.player_with_ball == self:
		#impulse_type = ImpulseTypeMachine.SHOOT
		#ball.set_collision_layer_value(2, false)
		#can_move = false
		#set_collision_mask_value(2, false)
		#ball.player_with_ball = null
		#var impulse = dir * shot_power
		#ball.linear_velocity = Vector2.ZERO
		##$AnimatedSprite2D.play("shot") # Ya se puede borrar
		#set_shoot_animation(ball.current_ball_height_machine)
		#if delay:
			#await get_tree().create_timer(delay_shoot).timeout 
		#Match.audio_shot.play()
		#ball.apply_central_impulse(impulse)
		#Match.goal_scorer_position = global_position
		#gk_saving()
		#impact_x_gk_calculate(impulse)
		##ball.get_node("AnimatedSprite2D").play("shot_free")
		##Match.shadow_ball.play("shot_free")
		##Match.shadow_ball.get_node("AnimShadow").play("shot_free")
		#var distance = global_position.distance_to(get_parent().rival_goal.global_position) # No estaba activado
		#ball.set_max_ball_height(distance, pass_power, impulse_type)
		##ball.set_ball_height(distance, shot_power) por ahora desactivado
		#ball.set_collision_layer_value(2, true)
		#await get_tree().create_timer(0.3).timeout
		#set_collision_mask_value(2, true)
		#await get_tree().create_timer(0.7).timeout
		#behavior_tree()
		##current_player_state = PlayerState.GO_TO_POSITION
		#can_move = true
#
#
#func impact_x_gk_calculate(dir_ball): # KICK SUPPORT
	#var rival_gk
	#match own_team:
		#0:
			#rival_gk = Match.gk_1
		#_:
			#rival_gk = Match.gk_0
	#
	#var x0 = ball.global_position.x # posición x de la pelota
	#var y0 = ball.global_position.y  # posición y de la pelota
	#var Vx = dir_ball.x # dirección x de la pelota
	#var Vy = dir_ball.y # dirección y de la pelota
	#var y_gk = rival_gk.global_position.y # posición y del arquero
	##var impact_x = (x0 + Vx) * ((y0 - y_gk) / Vy)
	#
	#var t = (y_gk - y0) / Vy
	#var impact_x = x0 + Vx * t
	#
	#var impact = Vector2(impact_x, y_gk)
	#rival_gk.shooter = self
	#Match.impact_x.global_position = impact
	#Match.saver_goalkeeper.impact_point = impact
	#if impact_x > -30 and impact_x < 30: 
		#Match.saver_goalkeeper.current_player_state = Match.saver_goalkeeper.PlayerState.GO_TO_IMPACT_POINT
		#Match.saver_goalkeeper.behavior_tree()
	#else:
		#Match.saver_goalkeeper.current_player_state = Match.saver_goalkeeper.PlayerState.GO_TO_POSITION
		#Match.saver_goalkeeper.behavior_tree()
	#
#
#func choice_target_shot(goal): # KICK SUPPORT
	#randomize()
	#var rand_target = randi_range(1, 2) # VOLVER A 3
	#if rand_target == 1:
		#return goal.get_node("TargetShot/TargetShot1").global_position
	#elif rand_target == 2:
		#return goal.get_node("TargetShot/TargetShot2").global_position
	#else:
		#return goal.global_position
