extends Area2D

# Variables Externas
@export var user_player_speed : float = 35.0
@export var cpu_player_speed : float = 30.0

@export var own_team : int = 0
@export var pass_power : float
var field_player : bool = false

var option_pass : Array[Area2D]
var move : bool = false
var direction : Vector2
var shooter : Area2D
var impact_point : Vector2

enum PlayerState {
	GO_TO_POSITION,
	GO_TO_IMPACT_POINT,
	GO_TO_BALL,
	WITH_BALL,
	PASSING,
	SAVING,
}



enum SaveSide {
	RIGHT,
	CENTER,
	LEFT,
}


enum Action {
	IDLE,
	SAVE,
	WAKE_UP,
	UP_KICK,
}

var current_save_side : SaveSide = SaveSide.CENTER
var current_player_state : PlayerState = PlayerState.GO_TO_POSITION
var user_controlled_player : bool = false
var target : Vector2
var pass_target : Vector2
@onready var ball = get_tree().get_first_node_in_group("ball")
@onready var Match = get_tree().get_first_node_in_group("match")
@onready var center_hand: Marker2D = $Hand
@onready var right_hand: Marker2D = $RightHand
@onready var left_hand: Marker2D = $LeftHand
@onready var own_goal : Node2D = get_parent().own_goal
@onready var hand : Marker2D = center_hand

func _ready() -> void:
	own_team = get_parent().team
	Match.match_state_changed.connect(_on_match_state_changed)
	await get_tree().create_timer(0.1).timeout
	call_deferred("set_player_level")


func _physics_process(delta):
	update_behavior_tree(delta)

func set_player_level():
	if own_team == 0:
		user_player_speed =	get_parent().gk_player_speed
	else:
		cpu_player_speed = get_parent().gk_player_speed

	
func _on_match_state_changed():
	behavior_tree()
	
func behavior_tree():
	if user_controlled_player == false:
		match Match.current_match_state:
			Match.MatchState.IN_GAME:
				match current_player_state:
					PlayerState.WITH_BALL:
						look_at(get_parent().rival_goal.global_position)
						await get_tree().create_timer(0.8).timeout
						current_save_side = SaveSide.CENTER
						$AnimatedSprite2D.play("center_save")
						target = global_position
						await get_tree().create_timer(0.5).timeout
						$AnimatedSprite2D.play("up_kick")
						await get_tree().create_timer(0.3).timeout
						current_player_state = PlayerState.PASSING
						behavior_tree()
					PlayerState.PASSING:
						Match.receiver = get_parent().field_player_list.pick_random()
						look_at(Match.receiver.global_position)
						pass_target = Match.receiver.global_position
						Match.receiver.current_player_state = Match.receiver.PlayerState.RECEIVER
						if ball.player_with_ball == self:
							#$AnimatedSprite2D.play("up_kick")
							#print($AnimatedSprite2D.animation)
							ball.ball_in_hand = false
							ball.player_with_ball = null
							set_collision_mask_value(2, false)
							var dir = ball.global_position.direction_to(pass_target)
							dir = dir.normalized()
							var impulse = dir * pass_power
							if Match.current_match_state != Match.MatchState.IN_GAME:
								Match.current_match_state = Match.MatchState.IN_GAME
							#await get_tree().create_timer(1.0).timeout
							ball.linear_velocity = Vector2.ZERO
							Match.audio_shot.play()
							ball.apply_central_impulse(impulse)
							var distance = global_position.distance_to(pass_target)
							ball.set_ball_height(distance, pass_power)
							await get_tree().create_timer(1.0).timeout
							current_player_state = PlayerState.GO_TO_POSITION
							Match.match_state_changed.emit()
							set_collision_mask_value(2, true)
							$RightSide.set_collision_mask_value(8, true)
							$LeftSide.set_collision_mask_value(8, true)
							$AnimatedSprite2D.play("idle")
							behavior_tree()
							#current_save_side = SaveSide.CENTER
					PlayerState.GO_TO_IMPACT_POINT:
						target = impact_point
						$AnimatedSprite2D.play("run")
						look_at(target)
						pass
			Match.MatchState.STOP_GAME:
				target = global_position
			Match.MatchState.RESTARTING:
				current_save_side = SaveSide.CENTER
				hand = center_hand
				current_player_state = PlayerState.GO_TO_POSITION
				$RightSide.set_collision_mask_value(8, true)
				$LeftSide.set_collision_mask_value(8, true)
		var distance_to_target : float = global_position.distance_to(target)
		if distance_to_target > 2: # Decía 2
			if current_player_state == PlayerState.SAVING:
				move = false
			else:			
				move = true
				if current_player_state == PlayerState.GO_TO_POSITION or \
					current_player_state == PlayerState.GO_TO_BALL:
						$AnimatedSprite2D.play("run")
		else:
			move = false
			if Match.current_match_state != Match.MatchState.STOP_GAME or \
			   current_player_state != PlayerState.GO_TO_IMPACT_POINT:
				$AnimatedSprite2D.play("idle")
			elif current_player_state == PlayerState.GO_TO_IMPACT_POINT and \
			$AnimatedSprite2D.animation == "save":
				$AnimatedSprite2D.animation = "save"
			
		if current_player_state == PlayerState.GO_TO_BALL:
			look_at(ball.global_position)
		elif current_player_state == PlayerState.GO_TO_POSITION:
			if move:
				look_at(target)
			else:
				look_at(ball.global_position)
		elif current_player_state == PlayerState.SAVING:
			look_at(shooter.global_position)
		
func search_nearest_position() -> Vector2:
	var min_distance : float = get_parent().own_goal.positions_gk[0].global_position.distance_squared_to(ball.global_position)
	var min_point : Vector2 = get_parent().own_goal.positions_gk[0].global_position
	for point in get_parent().own_goal.positions_gk:
		var distance = point.global_position.distance_squared_to(ball.global_position)
		if distance < min_distance:
			min_distance = distance
			min_point = point.global_position
	return Vector2(min_point.x, own_goal.positions_gk[0].global_position.y)
			

func update_behavior_tree(delta):
	if user_controlled_player == false:
		match Match.current_match_state:
			Match.MatchState.RESTARTING:
				match current_player_state:
					PlayerState.GO_TO_POSITION:
						if own_team == 0:
							target = Vector2( own_goal.gk_position.global_position.x, 165)
						else:
							target = Vector2( own_goal.gk_position.global_position.x, -165)

			Match.MatchState.IN_GAME:
				match current_player_state:
					PlayerState.GO_TO_POSITION:
						target = search_nearest_position()
						#if own_team == 0:
							#target = Vector2( own_goal.gk_position.global_position.x, 165)
						#else:
							#target = Vector2( own_goal.gk_position.global_position.x, -165)
						look_at(target)
						var distance_to_target : float = global_position.distance_to(target)
						if distance_to_target > 5: # decía 2
							move = true
							$AnimatedSprite2D.play("run")
							look_at(target)
						else:
							move = false
							$AnimatedSprite2D.play("idle")
							look_at(ball.global_position)
					PlayerState.GO_TO_IMPACT_POINT:
						if Match.current_match_state == Match.MatchState.IN_GAME:
							if own_team == 0:
								if ball.global_position.y > global_position.y -10:
									look_at(get_parent().rival_goal.global_position)
									if impact_point.x >global_position.x:
										$AnimatedSprite2D.flip_v = false
										$AnimatedSprite2D.play("save")
										hand = right_hand
										current_save_side = SaveSide.RIGHT
									else:
										$AnimatedSprite2D.flip_v = true
										$AnimatedSprite2D.play("save")
										hand = left_hand
										current_save_side = SaveSide.LEFT
							else:
								if ball.global_position.y < global_position.y +10:
									look_at(get_parent().rival_goal.global_position)
									if impact_point.x < global_position.x:
										$AnimatedSprite2D.flip_v = false
										$AnimatedSprite2D.play("save")
										hand = right_hand
										current_save_side = SaveSide.RIGHT
									else:
										$AnimatedSprite2D.flip_v = true
										$AnimatedSprite2D.play("save")
										hand = left_hand
										current_save_side = SaveSide.LEFT
					PlayerState.GO_TO_BALL:
						target = ball.global_position
						var distance_to_target : float = global_position.distance_to(target)
						if distance_to_target > 2: # decía 2
							move = true
							if $AnimatedSprite2D.animation != "run":
								$AnimatedSprite2D.play("run")
								look_at(target)
						else:
							move = false
							$AnimatedSprite2D.play("idle")
		
	if move:
		movement(delta)
					

func movement(delta):
	direction = global_position.direction_to(target)
	direction = direction.normalized()
	var speed : float
	var temp_speed : float
	if own_team == 0:
		temp_speed = user_player_speed
	else:
		temp_speed = cpu_player_speed
	
	if current_player_state == PlayerState.SAVING:
		speed = temp_speed * 1.0
	else:
		speed = temp_speed
	var velocity = direction * speed * delta
	global_position += velocity

func animations(_action : Action, _side : SaveSide):
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		Match.last_player_touch_ball = self
		Match.saver_goalkeeper = null
		body.ball_in_hand = true
		set_collision_mask_value(2, false)
		set_collision_mask_value(8, false)
		match Match.current_match_state:
			Match.MatchState.IN_GAME:
				if body.player_with_ball == null:
					body.player_with_ball = self
					#if current_save_side == SaveSide.CENTER:
						#$AnimatedSprite2D.play("center_save")
					if Match.receiver:
						Match.receiver.current_player_state = Match.receiver.PlayerState.GO_TO_POSITION
						Match.receiver = null
					current_player_state = PlayerState.WITH_BALL
					Match.current_team_posesion = own_team
					Match.match_state_changed.emit()
				else:
					if body.player_with_ball.field_player:
						body.player_with_ball.get_node("TimerDecision").stop()
					if own_team != body.player_with_ball.own_team:
						body.player_with_ball.current_player_state = body.player_with_ball.PlayerState.NOT_AVAILABLE
						body.player_with_ball.behavior_tree()
					else:
						body.player_with_ball.current_player_state = PlayerState.GO_TO_POSITION
						body.player_with_ball.behavior_tree()
					body.player_with_ball = self
					current_player_state = PlayerState.WITH_BALL
					Match.current_team_posesion = own_team
					Match.match_state_changed.emit()
			Match.MatchState.STOP_GAME:
				pass
			


func _on_right_side_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if current_player_state == PlayerState.GO_TO_IMPACT_POINT:
			$RightSide.set_collision_mask_value(8, false)
			$LeftSide.set_collision_mask_value(8, false)
			#behavior_tree()
			$AnimatedSprite2D.play("save")
			$AnimatedSprite2D.flip_v = false
			#var temp_target = $RightSide.global_position
			target = global_position
			hand = right_hand
			current_save_side = SaveSide.RIGHT





func _on_left_side_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if current_player_state == PlayerState.GO_TO_IMPACT_POINT:
			$RightSide.set_collision_mask_value(8, false)
			$LeftSide.set_collision_mask_value(8, false)
			#behavior_tree()
			$AnimatedSprite2D.play("save")
			$AnimatedSprite2D.flip_v = true
			#var temp_target = $LeftSide.global_position
			target = global_position
			hand = left_hand
			current_save_side = SaveSide.LEFT




func _on_center_side_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if current_player_state == PlayerState.GO_TO_IMPACT_POINT:
			$RightSide.set_collision_mask_value(8, false)
			$LeftSide.set_collision_mask_value(8, false)
			#behavior_tree()
			if own_team == 0:
				if target.x >= global_position.x:
					$AnimatedSprite2D.flip_v = false
					hand = right_hand
					current_save_side = SaveSide.RIGHT
				else:
					$AnimatedSprite2D.flip_v = true
					hand = left_hand
					current_save_side = SaveSide.LEFT
			else:
				if target.x <= global_position.x:
					$AnimatedSprite2D.flip_v = false
					hand = right_hand
					current_save_side = SaveSide.RIGHT
				else:
					$AnimatedSprite2D.flip_v = true
					hand = left_hand
					current_save_side = SaveSide.LEFT
			$AnimatedSprite2D.play("save")
			target = global_position
			#hand = center_hand
			#current_save_side = SaveSide.CENTER
