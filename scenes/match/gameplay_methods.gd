extends Node

@onready var root = $"../.."

func get_player_controlled() -> Area2D: # INPUT SCRIPTS
	var available_camera_players : Array[Area2D]
	var available_players : Array[Area2D]
	if root.players_in_camera.size() > 0:
		for player in root.players_in_camera:
			if player.current_player_state != player.PlayerState.NOT_AVAILABLE and player != $"../..".player_controlled:
				available_camera_players.append(player)
		if available_camera_players.size() > 0:
			return available_camera_players.pick_random()
		else:
			for player in root.players_team_0:
				if player.current_player_state != player.PlayerState.NOT_AVAILABLE:
					available_players.append(player)
			return available_players.pick_random()
	else:
		for player in root.players_team_0:
			if player.current_player_state != player.PlayerState.NOT_AVAILABLE:
				available_players.append(player)
		print(available_players)
		return available_players.pick_random()



func not_player_controlled_actions(): # GAMEPLAY SCRIPTS
	if root.ball.player_with_ball == null and root.current_team_posesion == 0: #or root.ball.player_with_ball.own_team == 1:
		var direction
		if root.player_controlled:
			direction = root.player_controlled.direction
		if root.in_input_buffer_zone:
			if Input.is_action_just_released("shot"):
				root.current_input_buffer_action = root.InputBufferActions.SHOOT
			
			if Input.is_action_pressed("ui_left"):
				root.current_input_buffer_direction = root.InputBufferDirection.LEFT
			if Input.is_action_pressed("ui_right"):
				root.current_input_buffer_direction = root.InputBufferDirection.RIGHT
			if Input.is_action_pressed("ui_up"):
				root.current_input_buffer_direction = root.InputBufferDirection.FORWARD
		else:
			if Input.is_action_just_released("pass"):
				print("Acá está el nuevo código")
				var leave_player_controlled = root.player_controlled
				root.player_controlled = leave_player_controlled.get_parent().search_nearest_player()
				if root.player_controlled:
					root.player_controlled.current_player_state = root.player_controlled.PlayerState.USER_CONTROLLED
				if leave_player_controlled:
					leave_player_controlled.current_player_state = leave_player_controlled.PlayerState.GO_TO_POSITION
					leave_player_controlled.behavior_tree()	
			
			
	elif root.ball.player_with_ball == null or root.current_team_posesion == 1:	
		if Input.is_action_just_released("pass"):
			var leave_player_controlled = root.player_controlled
			root.player_controlled = leave_player_controlled.get_parent().search_nearest_player()
			if root.player_controlled:
				root.player_controlled.current_player_state = root.player_controlled.PlayerState.USER_CONTROLLED
			if leave_player_controlled:
				leave_player_controlled.current_player_state = leave_player_controlled.PlayerState.GO_TO_POSITION
				leave_player_controlled.behavior_tree()	
