extends Area2D

# ENUMS
enum PlayerState {
	GO_TO_POSITION,
	GO_TO_BALL_ATTACK,
	GO_TO_BALL_DEFENSE,
	WITH_BALL,
	RECEIVER,
	NOT_AVAILABLE,
	GO_TO_CELEBRATION,
	USER_CONTROLLED,
	GO_TO_KICKOFF_POSITION,
	RESTARTER,
	RESTARTER_THROW_IN,
	GO_TO_KICKOFF_POSITION_RESTARTER_1,
	GO_TO_KICKOFF_POSITION_RESTARTER_2,
	GO_TO_CORNER_POSITION,
	USER_RESTARTING,
}

enum PlayerWithBall {
	GO_TO_ATTACK_POSITION,
	PASS,
	SHOT,
	SHOT_FTF,
}

enum ImpulseTypeMachine {
	PASS,
	SHOOT,
	CROSS,
}

#Variables externas
@export var user_player_speed : float = 40.0
@export var cpu_player_speed : float = 35.0
@export var time_decision : float = 1.0


# VARIABLES EXPORTADAS
@export var static_position : bool = false
@export var corner_defender : bool = false
@export var own_team : int = 0
@export var pass_power : float = 75.0
@export var shot_power : float = 120.0
@export var sweeper : bool = false


var own_pass_receiver : Area2D
var field_player : bool = true
var option_pass : Array[Area2D]
var in_shot_area : bool = false
var can_move : bool = true
var move : bool = false
var direction : Vector2
#var user_controlled : bool = false
var velocity : Vector2
var distance_to_target_general : float
var can_throw_in : bool = true
var current_player_state : PlayerState = PlayerState.GO_TO_KICKOFF_POSITION
var current_player_with_ball : PlayerWithBall =  PlayerWithBall.GO_TO_ATTACK_POSITION
var impulse_type : ImpulseTypeMachine = ImpulseTypeMachine.PASS
var target : Vector2
var pass_target : Vector2
var at_target : bool = false
var delay_shoot : float = 0.1
var delay : bool = true
var kick_off_position : Vector2

# Verificar si está en Firs Time Finish Zone
var in_ftfc : bool = false
var in_ftfl : bool = false
var in_ftfr : bool = false

@onready var dinamic_position = get_node("Positions/Position")
@onready var default_position = get_node("Positions/Position").global_position
@onready var ball = get_tree().get_first_node_in_group("ball")
@onready var Match = get_tree().get_first_node_in_group("match")
#@onready var left_controls = get_tree().get_first_node_in_group("left_controls")
@onready var left_controls = get_tree().get_first_node_in_group("stick")
@onready var defense_points = get_tree().get_nodes_in_group("defense_points")
@onready var goals = get_tree().get_nodes_in_group("goal")
@onready var foot: Marker2D = $Foot
@onready var hand_throw_in = $HandThrowIn
@onready var own_goal : Node2D = get_parent().own_goal
#@onready var players_team_0 = get_tree().get_nodes_in_group("player_team_0")

# SECONDARY SCRIPTS
# -----------------
@onready var triggers_script = $SecondaryScripts/Triggers
@onready var on_body_entered_script = $SecondaryScripts/OnBodyEntered
@onready var behavior_scripts = $SecondaryScripts/BehaviorScripts
@onready var ready_sets_scripts = $SecondaryScripts/ReadySets
@onready var ball_impulse_scripts = $SecondaryScripts/BallImpulseScripts


func _ready() -> void:
	initialize()
	call_deferred("ready_sets")


func initialize():
	kick_off_position = global_position
	own_team = get_parent().team
	set_option_pass() # Esto se modificará cuando se elija la táctica


func ready_sets():
	behavior_tree()
	ready_sets_scripts.set_initial_kick_off(Match, self, ball)
	ready_sets_scripts.signals_connect(Match, self, goals)
	await get_tree().create_timer(0.1).timeout
	ready_sets_scripts.set_shirt_palette($AnimatedSprite2D, self)
	ready_sets_scripts.set_player_level(self)


func _physics_process(delta):
	set_distance_behavior()
	set_shadow_player_position()
	update_behavior_tree(delta)
	

func set_distance_behavior():
	distance_to_target_general = global_position.distance_to(target)
	if current_player_state == PlayerState.GO_TO_POSITION:
		if distance_to_target_general < 3:
			at_target = true
		else:
			at_target = false


func set_shadow_player_position():
	$Node/ShadowPlayer.global_position = Vector2(global_position.x + 2, global_position.y)
	

func set_option_pass(): # 45 líneas
	match name:
		"FieldPlayer1":
			option_pass.append(get_parent().get_node("FieldPlayer4"))
			option_pass.append(get_parent().get_node("FieldPlayer5"))
			option_pass.append(get_parent().get_node("FieldPlayer8"))
		"FieldPlayer2":
			option_pass.append(get_parent().get_node("FieldPlayer4"))
			option_pass.append(get_parent().get_node("FieldPlayer7"))
			option_pass.append(get_parent().get_node("FieldPlayer5"))
		"FieldPlayer3":
			option_pass.append(get_parent().get_node("FieldPlayer5"))
			option_pass.append(get_parent().get_node("FieldPlayer7"))
			option_pass.append(get_parent().get_node("FieldPlayer10"))
		"FieldPlayer4":
			option_pass.append(get_parent().get_node("FieldPlayer8"))
			option_pass.append(get_parent().get_node("FieldPlayer9"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
		"FieldPlayer5":
			option_pass.append(get_parent().get_node("FieldPlayer4"))
			option_pass.append(get_parent().get_node("FieldPlayer7"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
		"FieldPlayer6":
			option_pass.append(get_parent().get_node("FieldPlayer8"))
			option_pass.append(get_parent().get_node("FieldPlayer9"))
			option_pass.append(get_parent().get_node("FieldPlayer10"))
		"FieldPlayer7":
			option_pass.append(get_parent().get_node("FieldPlayer10"))
			option_pass.append(get_parent().get_node("FieldPlayer9"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
		"FieldPlayer8":
			option_pass.append(get_parent().get_node("FieldPlayer10"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
			option_pass.append(get_parent().get_node("FieldPlayer9"))
		"FieldPlayer9":
			option_pass.append(get_parent().get_node("FieldPlayer8"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
			option_pass.append(get_parent().get_node("FieldPlayer10"))
		"FieldPlayer10":
			option_pass.append(get_parent().get_node("FieldPlayer8"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
			option_pass.append(get_parent().get_node("FieldPlayer9"))
	

func ia_pass_before_line_goal(): # SUPPORT
	if own_team == 0:
		if current_player_state == PlayerState.WITH_BALL and \
			current_player_with_ball == PlayerWithBall.GO_TO_ATTACK_POSITION and \
			ball.global_position.y <= Match.limit_line * get_parent().team_multip and \
			in_shot_area == false:
				current_player_with_ball = PlayerWithBall.PASS
				behavior_tree()
				return
	else:
		if current_player_state == PlayerState.WITH_BALL and \
			current_player_with_ball == PlayerWithBall.GO_TO_ATTACK_POSITION and \
			ball.global_position.y >= Match.limit_line * get_parent().team_multip and \
			in_shot_area == false:
				current_player_with_ball = PlayerWithBall.PASS
				behavior_tree()
				return


func update_behavior_tree(delta):
	ia_pass_before_line_goal()	
	behavior_scripts.update_behavior_tree(self, Match, ball)
	if move and can_move:
		movement(delta)


func button_pass_pressed():
	if direction.length() > 0.01:
		if get_parent().in_pass_area.size() > 0:
			if Match.current_match_state == Match.MatchState.RESTARTING:
				if Match.current_team_posesion == own_team:
					if Match.current_restarting_state == Match.RestartingState.KICK_OFF:
						Match.receiver = set_set_pieces_receiver()
					else:
						Match.receiver = get_parent().in_pass_area.pick_random()
			elif Match.current_match_state == Match.MatchState.IN_GAME:
				Match.receiver = get_parent().in_pass_area.pick_random()
			pass_ball_user_controlled(Match.receiver)
		else:
			shot_user_controlled(direction)
	else:
		shoot_whithout_direction()


func shoot_whithout_direction():
	var angle = rotation
	var direction2 = Vector2.RIGHT.rotated(angle)
	shot_user_controlled(direction2)


func move_animations_user_controlled():
	if velocity == Vector2.ZERO and ball.player_with_ball == self:
		$AnimatedSprite2D.play("pass")
		ball.get_node("AnimationPlayer").stop()
		ball.current_ball_move_machine = ball.BallMoveMachine.IDLE
		ball.move_machine()
	else:
		if can_move:
			if velocity == Vector2.ZERO:
				$AnimatedSprite2D.play("idle")
			else:
				$AnimatedSprite2D.play("run")
				ball.current_ball_move_machine = ball.BallMoveMachine.ROLLING
				ball.move_machine()


func move_animations():
	if can_move:
		if move:
			#match current_player_state:
				#PlayerState.GO_TO_POSITION:
					#$AnimatedSprite2D.play("run")
					#look_at(target)
					#
					#
					#
			if current_player_state != PlayerState.GO_TO_CELEBRATION or !(current_player_state == PlayerState.WITH_BALL and current_player_with_ball == PlayerWithBall.PASS): 
				$AnimatedSprite2D.play("run")
				if can_throw_in == true:
					look_at(target)
		else:
			if current_player_state != PlayerState.WITH_BALL or \
				current_player_state != PlayerState.NOT_AVAILABLE or \
				current_player_state != PlayerState.RESTARTER_THROW_IN:
					$AnimatedSprite2D.play("idle")
					look_at(ball.global_position)
	else:
		if can_throw_in == false:
			if own_pass_receiver:
				look_at(own_pass_receiver.global_position)
		else:
			if own_pass_receiver:
				look_at(own_pass_receiver.global_position)
			else:
				if current_player_state == PlayerState.RECEIVER:
					$AnimatedSprite2D.play("idle")
					look_at(ball.global_position)
			

func behavior_tree(): 
	behavior_scripts.event_behavior_tree(self, Match, ball)

 
func restarter_throw_in_behaviour_user_team(restarter):
	if restarter == self:
		Match.receiver = choice_in_pass_area_receiver()
		print("El receptor de lateral es: ", Match.receiver.name)
		if can_throw_in:
			can_throw_in = false
			ball.player_with_ball = self
			current_player_state = PlayerState.RESTARTER_THROW_IN
			throw_in(Match.receiver)


func restarter_throw_in_behaviour_cpu_team(restarter):
	if restarter == self:
		Match.receiver = choice_reveicer()
		if can_throw_in:
			can_throw_in = false
			current_player_state = PlayerState.RESTARTER_THROW_IN
			ball.player_with_ball = self
			throw_in(Match.receiver)


func restarter_behaviour_user_team(restarter : Area2D):
	if Match.current_game_mode == Match.GameMode.CPU_VS_CPU:
		if restarter == self:
			current_player_state = PlayerState.GO_TO_BALL_ATTACK
	else:
		if restarter == self:
			current_player_state = PlayerState.USER_RESTARTING


func restarter_behaviour_cpu_team(restarter : Area2D):
	if restarter == self:
		current_player_state = PlayerState.GO_TO_BALL_ATTACK


func throw_in(receiver): # KICK
	#impulse_type = ImpulseTypeMachine.PASS
	set_impulse_type(ImpulseTypeMachine.PASS)
	set_match_state(Match.MatchState.IN_GAME)
	#Match.current_match_state = Match.MatchState.IN_GAME
	#Match.process_match_states()
	can_move = false
	look_at(receiver.global_position)
	pass_target = receiver.global_position
	receiver.current_player_state = PlayerState.RECEIVER
	#if user_controlled:
		#user_controlled = false
	Match.last_player_touch_ball = self
	if ball.player_with_ball == self:
		impulse_ball("throw_in")
		Match.get_player_controlled()
	await get_tree().create_timer(0.5).timeout
	can_throw_in = true
	can_move = true
	


func set_impulse_type(type):
	impulse_type = type
	
func set_match_state(state):
	Match.current_match_state = state
	Match.process_match_states()

func impulse_ball(animation):
	ball.player_with_ball = null
	var dir = ball.global_position.direction_to(pass_target)
	dir = dir.normalized()
	var impulse = dir * pass_power
	Match.match_state_changed.emit()
	ball.linear_velocity = Vector2.ZERO
	$AnimatedSprite2D.play(animation)
	await get_tree().create_timer(0.1).timeout
	ball.apply_central_impulse(impulse)
	var distance = global_position.distance_to(pass_target)
	ball.set_max_ball_height(distance, pass_power, impulse_type)
	await get_tree().create_timer(0.1).timeout
	set_collision_mask_value(2, true)
	await get_tree().create_timer(0.2).timeout
	can_move = true
	move_animations()

func choice_in_pass_area_receiver() -> Area2D:
	if get_parent().in_pass_area.size() > 0: 
		return get_parent().in_pass_area.pick_random()
	else:
		return choice_reveicer()


func choice_reveicer() -> Area2D: # KICK
	var temporal_option_pass = option_pass.duplicate(true)
	
	if temporal_option_pass.size() > 2: 
		if temporal_option_pass[2].current_player_state == PlayerState.NOT_AVAILABLE:
				temporal_option_pass.erase(temporal_option_pass[2])
	elif temporal_option_pass.size() > 1:
		if temporal_option_pass[1].current_player_state == PlayerState.NOT_AVAILABLE:
				temporal_option_pass.erase(temporal_option_pass[1])
	elif temporal_option_pass.size() > 0:
		if temporal_option_pass[0].current_player_state == PlayerState.NOT_AVAILABLE:
				temporal_option_pass.erase(temporal_option_pass[0])
	else:
		print("No hay ninguna opción de pase")
		
	return temporal_option_pass.pick_random()	
	
		
func dinamic_position_corrected(position_to_correct): # SUPPORT
	if position_to_correct.x > Match.GAME_FIELD_MARGIN.x:
		dinamic_position.global_position.x = Match.GAME_FIELD_MARGIN.x
	if position_to_correct.x < -Match.GAME_FIELD_MARGIN.x:
		dinamic_position.global_position.x = -Match.GAME_FIELD_MARGIN.x
	if position_to_correct.y > Match.GAME_FIELD_MARGIN.y:
		dinamic_position.global_position.y = Match.GAME_FIELD_MARGIN.y
	if position_to_correct.y < -Match.GAME_FIELD_MARGIN.y:
		dinamic_position.global_position.y = -Match.GAME_FIELD_MARGIN.y


func movement(delta): # REFACTORIZAR
	if current_player_state != PlayerState.USER_CONTROLLED: 
		direction = global_position.direction_to(target)
		direction = direction.normalized()
	else:
		direction = Vector2.ZERO
		if Match.touch_gamepad == false:
			if Input.is_action_pressed("ui_up") or left_controls.direction.y < -0.1:
				direction.y -= 1
				#rotation = -90.0
			if Input.is_action_pressed("ui_down") or left_controls.direction.y > 0.1:
				direction.y += 1
				#rotation = 90.0
			if Input.is_action_pressed("ui_right") or left_controls.direction.x > 0.1:
				direction.x += 1
				#rotation = 0.0
			if Input.is_action_pressed("ui_left") or left_controls.direction.x < - 0.1:
				direction.x -= 1
				#rotation = 180.0
			move_animations_user_controlled()
		else:
			direction = left_controls.direction
			direction = direction.normalized()
			direction *= 1.25
			move_animations_user_controlled()
		
		if can_move:
			look_at(global_position + direction)
		
	var speed : float
	if own_team == 0:
		speed = user_player_speed
	else:
		speed = cpu_player_speed
	
	velocity = direction * speed * delta
	global_position += velocity


func pass_ball_user_controlled(receiver : Area2D): # KICK - 30 líneas
	can_move = false
	look_at(receiver.global_position)
	pass_target = receiver.global_position
	own_pass_receiver = receiver
	receiver.current_player_state = PlayerState.RECEIVER
	receiver.behavior_tree()
	if ball.player_with_ball == self:
		ball.player_with_ball = null
		set_collision_mask_value(2, false)
		var dir = ball.global_position.direction_to(pass_target)
		dir = dir.normalized()
		var impulse = dir * pass_power
		if Match.current_match_state == Match.MatchState.RESTARTING:
			Match.current_match_state = Match.MatchState.IN_GAME
			Match.process_match_states()
		ball.linear_velocity = Vector2.ZERO
		$AnimatedSprite2D.play("pass")
		Match.audio_shot.play()
		ball.apply_central_impulse(impulse)
		if get_parent().rival_goal.in_aerial_pass_zone:
			impulse_type = ImpulseTypeMachine.CROSS
		else:
			impulse_type = ImpulseTypeMachine.PASS
		var distance = global_position.distance_to(pass_target)
		ball.set_max_ball_height(distance, pass_power, impulse_type)
		#ball.set_ball_height(distance, pass_power) # - ALTURA
		await get_tree().create_timer(0.5).timeout # Estaba en 0.3
		set_collision_mask_value(2, true)
		await get_tree().create_timer(0.3).timeout
		own_pass_receiver = null
		can_move = true
	
	 
func pass_ball(receiver : Area2D): # KICK - 30 líneas
	can_move = false
	look_at(receiver.global_position)
	pass_target = receiver.global_position
	receiver.current_player_state = PlayerState.RECEIVER
	receiver.behavior_tree()
	own_pass_receiver = receiver
	impulse_type = ImpulseTypeMachine.PASS
	
	if ball.player_with_ball == self:
		ball.player_with_ball = null
		set_collision_mask_value(2, false)
		var dir = ball.global_position.direction_to(pass_target)
		dir = dir.normalized()
		var impulse = dir * pass_power
		if Match.current_match_state != Match.MatchState.IN_GAME:
			Match.current_match_state = Match.MatchState.IN_GAME
			Match.process_match_states()
		ball.linear_velocity = Vector2.ZERO
		$AnimatedSprite2D.play("pass")
		await get_tree().create_timer(0.1).timeout
		Match.audio_shot.play()
		ball.apply_central_impulse(impulse)
		var distance = global_position.distance_to(pass_target)
		ball.set_max_ball_height(distance, pass_power, impulse_type)
		await get_tree().create_timer(0.8).timeout #Estaba en 0.3
		set_collision_mask_value(2, true)
		await get_tree().create_timer(0.1).timeout
		#$DefenseZone.set_collision_mask_value(8, true) # TRIGGER
		current_player_state = PlayerState.GO_TO_POSITION
		can_move = true
		own_pass_receiver = null
		behavior_tree()
		move_animations()
			
	
func gk_saving(): # KICK
	var rival_gk
	match own_team:
		0:
			rival_gk = Match.gk_1
		_:
			rival_gk = Match.gk_0
	#rival_gk.current_player_state = rival_gk.PlayerState.SAVING
	rival_gk.shooter = self
	Match.saver_goalkeeper = rival_gk
	rival_gk.behavior_tree()
				

func shot(target_goal): # KICK REFACTORIZAR - 25 líneas 
	if ball.player_with_ball == self:
		can_move = false
		set_collision_mask_value(2, false)
		ball.player_with_ball = null
		var dir = ball.global_position.direction_to(target_goal)
		dir = dir.normalized()
		look_at(target_goal)
		var impulse = dir * (shot_power * 1.2)
		ball.linear_velocity = Vector2.ZERO
		set_shoot_animation(ball.current_ball_height_machine)
		if delay:
			await get_tree().create_timer(delay_shoot).timeout
		ball.apply_central_impulse(impulse)
		Match.audio_shot.play()
		Match.goal_scorer_position = global_position
		gk_saving() 
		#impact_x_gk_calculate(impulse)
		await get_tree().create_timer(0.3).timeout
		set_collision_mask_value(2, true)
		await get_tree().create_timer(0.7).timeout
		if Match.current_match_state != Match.MatchState.STOP_GAME:
			current_player_state = PlayerState.GO_TO_POSITION
		can_move = true
		move_animations()
		behavior_tree()

func set_shoot_animation(ball_height : int): #KICK
	if ball_height >= 2:
		$AnimatedSprite2D.play("heading")
		delay = false
		ball.current_ball_arc_machine = ball.BallArcMachine.DESCENDING
		ball.arc_machine()
	else:
		$AnimatedSprite2D.play("shot")
		delay = true


func shot_user_controlled(dir): # KICK REFACTORIZAR
	if ball.player_with_ball == self:
		impulse_type = ImpulseTypeMachine.SHOOT
		ball.set_collision_layer_value(2, false)
		can_move = false
		set_collision_mask_value(2, false)
		ball.player_with_ball = null
		var impulse = dir * shot_power
		ball.linear_velocity = Vector2.ZERO
		#$AnimatedSprite2D.play("shot") # Ya se puede borrar
		set_shoot_animation(ball.current_ball_height_machine)
		if delay:
			await get_tree().create_timer(delay_shoot).timeout 
		Match.audio_shot.play()
		ball.apply_central_impulse(impulse)
		Match.goal_scorer_position = global_position
		gk_saving()
				#impact_x_gk_calculate(impulse)
		#ball.get_node("AnimatedSprite2D").play("shot_free")
		#Match.shadow_ball.play("shot_free")
		#Match.shadow_ball.get_node("AnimShadow").play("shot_free")
		var distance = global_position.distance_to(get_parent().rival_goal.global_position) # No estaba activado
		ball.set_max_ball_height(distance, pass_power, impulse_type)
		#ball.set_ball_height(distance, shot_power) por ahora desactivado
		ball.set_collision_layer_value(2, true)
		await get_tree().create_timer(0.3).timeout
		set_collision_mask_value(2, true)
		await get_tree().create_timer(0.7).timeout
		behavior_tree()
		#current_player_state = PlayerState.GO_TO_POSITION
		can_move = true


func impact_x_gk_calculate(dir_ball): # KICK SUPPORT
	var rival_gk
	match own_team:
		0:
			rival_gk = Match.gk_1
		_:
			rival_gk = Match.gk_0
	
	var x0 = ball.global_position.x # posición x de la pelota
	var y0 = ball.global_position.y  # posición y de la pelota
	var Vx = dir_ball.x # dirección x de la pelota
	var Vy = dir_ball.y # dirección y de la pelota
	var y_gk = rival_gk.global_position.y # posición y del arquero
	#var impact_x = (x0 + Vx) * ((y0 - y_gk) / Vy)
	
	var t = (y_gk - y0) / Vy
	var impact_x = x0 + Vx * t
	
	var impact = Vector2(impact_x, y_gk)
	rival_gk.shooter = self
	Match.impact_x.global_position = impact
	Match.saver_goalkeeper.impact_point = impact
	if impact_x > -30 and impact_x < 30: 
		if Match.saver_goalkeeper.can_move:
			Match.saver_goalkeeper.current_player_state = Match.saver_goalkeeper.PlayerState.GO_TO_IMPACT_POINT
			Match.saver_goalkeeper.behavior_tree()
	else:
		if Match.saver_goalkeeper.can_move: 
			Match.saver_goalkeeper.current_player_state = Match.saver_goalkeeper.PlayerState.GO_TO_GK_POSITION
			Match.saver_goalkeeper.behavior_tree()
	

func choice_target_shot(goal): # KICK SUPPORT
	randomize()
	var rand_target = randi_range(1, 2) # VOLVER A 3
	if rand_target == 1:
		return goal.get_node("TargetShot/TargetShot1").global_position
	elif rand_target == 2:
		return goal.get_node("TargetShot/TargetShot2").global_position
	else:
		return goal.global_position

	
func set_set_pieces_receiver() -> Area2D:
	match Match.current_restarting_state:
		Match.RestartingState.KICK_OFF:
			return get_parent().restarter2
		Match.RestartingState.GOAL_KICK_0:
			var receivers = get_parent().field_player_list.duplicate(true)
			receivers.erase(self)
			return receivers.pick_random()
		Match.RestartingState.GOAL_KICK_1:
			var receivers = get_parent().field_player_list.duplicate(true)
			receivers.erase(self)
			return receivers.pick_random()
		Match.RestartingState.CORNER_KICK_L_0:
			return get_parent().corner_receivers.pick_random()
		Match.RestartingState.CORNER_KICK_L_1:
			return get_parent().corner_receivers.pick_random()
		Match.RestartingState.CORNER_KICK_R_0:
			return get_parent().corner_receivers.pick_random()
		Match.RestartingState.CORNER_KICK_R_1:
			return get_parent().corner_receivers.pick_random()
		_:
			return option_pass.pick_random()
	

func check_ftf() -> bool: # SUPPORT
	var check_l : bool = false
	var check_r : bool = false
	if in_ftfl and get_parent().rival_goal.ftf_l_active:
		check_l = true
	if in_ftfr and get_parent().rival_goal.ftf_r_active:
		check_r = true
	
	if in_ftfc or check_l or check_r:
		return true
	else:
		return false


func _on_match_state_changed():
	behavior_tree()


func _on_body_entered(body: Node2D) -> void:
	on_body_entered_script.on_body_entered(body)


func _on_timer_decision_timeout() -> void:
	var long_shot = get_parent().rival_goal.in_long_shot_area
	if long_shot:
		randomize()
		var rand_long_shot = randi_range(1, 2)
		if rand_long_shot > 1:
			current_player_with_ball = PlayerWithBall.PASS
			behavior_tree()
		else:
			current_player_with_ball = PlayerWithBall.SHOT
			behavior_tree()
	else:
		current_player_with_ball = PlayerWithBall.PASS
		behavior_tree()


func _on_defense_zone_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		triggers_script.current_defense_zone_state = triggers_script.DefenseZoneState.IN
		

func _on_defense_zone_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		triggers_script.current_defense_zone_state = triggers_script.DefenseZoneState.OUT


func _on_goal_scored(goal):
	if goal.rival_team == own_team:
		current_player_state = PlayerState.GO_TO_CELEBRATION
		behavior_tree()
	
	
func _on_shot_button_pressed():
	if ball.player_with_ball == self:
		if direction.length() > 0.01:
			shot_user_controlled(direction)
		else:
			var angle = rotation
			var direction2 = Vector2.RIGHT.rotated(angle)
			shot_user_controlled(direction2)


func _on_input_buffer_area_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if in_ftfc == true:
			Match.in_input_buffer_zone = true


func _on_input_buffer_area_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		if Match.in_input_buffer_zone:
			Match.in_input_buffer_zone = false
