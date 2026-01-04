extends RigidBody2D


var player_with_ball : Area2D
var ball_in_hand : bool = false
var can_scored : bool = true
@onready var kick_off_point : Vector2 = Vector2.ZERO
@export var friction_per_second : float = 0.3


var ball_height : Dictionary[int, String] = {
	0 : "h0",
	1 : "h1",
	2 : "h3",
	4 : "h4"
}
@onready var anim_shadow: AnimationPlayer = $"../ShadowBallNode/ShadowBall/AnimShadow"


func _physics_process(delta: float) -> void:
	if player_with_ball:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0 
		$AnimatedSprite2D.play("h0free")
		$"../ShadowBallNode/ShadowBall".play("h0")
		anim_shadow.play("RESET")
		if player_with_ball.field_player:
			global_position = player_with_ball.foot.global_position
			rotation = player_with_ball.rotation
			if player_with_ball.move == true and player_with_ball.can_move:
				$AnimationPlayer.play("at_foot")
			else:
				$AnimationPlayer.stop()
			if player_with_ball.user_controlled == false:
				if player_with_ball.current_player_state != player_with_ball.PlayerState.WITH_BALL:
					player_with_ball.current_player_state = player_with_ball.PlayerState.WITH_BALL
					player_with_ball.behavior_tree()
					print("correción de estado de jugador")
		else:
			set_collision_layer_value(2, false)
			match player_with_ball.current_save_side:
				0:
					global_position = player_with_ball.right_hand.global_position
				1:
					global_position = player_with_ball.center_hand.global_position
				_:
					global_position = player_with_ball.left_hand.global_position
			#global_position = player_with_ball.hand.global_position
			$AnimationPlayer.stop()
			$AnimatedSprite2D.play("h0")
			$"../ShadowBallNode/ShadowBall".play("h0")
			anim_shadow.play("RESET")
	else:
		$AnimationPlayer.stop()
		if $"..".current_match_state == $"..".MatchState.STOP_GAME:
			linear_velocity *= pow(friction_per_second, delta)
			angular_velocity *= pow(friction_per_second, delta)
			$AnimatedSprite2D.speed_scale = -1
			$"../ShadowBallNode/ShadowBall/AnimShadow".speed_scale = -1
			$"../ShadowBallNode/ShadowBall".speed_scale = -1
		elif $"..".current_match_state == $"..".MatchState.POSITIONING:
			$AnimatedSprite2D.play("h0")
			$AnimatedSprite2D.speed_scale = 1
			$"../ShadowBallNode/ShadowBall".speed_scale = 1
			$"../ShadowBallNode/ShadowBall/AnimShadow".speed_scale = 1
		

func set_ball_height(distance, power):
	var time = (distance / power) - 0.2
	if time < 0: time = 0
	if distance > 120:
		$AnimatedSprite2D.play("h4")
		$"../ShadowBallNode/ShadowBall".play("h4")
		anim_shadow.play("h4")
		set_collision_layer_value(2, false)
		await get_tree().create_timer(time).timeout
		set_collision_layer_value(2, true)
	elif distance > 100:
		$AnimatedSprite2D.play("h3")
		$"../ShadowBallNode/ShadowBall".play("h3")
		anim_shadow.play("h3")
		set_collision_layer_value(2, false)
		await get_tree().create_timer(time).timeout
		set_collision_layer_value(2, true)
	elif distance > 80:
		$AnimatedSprite2D.play("h2")
		$"../ShadowBallNode/ShadowBall".play("h2")
		anim_shadow.play("h2")
		set_collision_layer_value(2, false)
		await get_tree().create_timer(time).timeout
		set_collision_layer_value(2, true)
	elif distance > 60:
		$AnimatedSprite2D.play("h1")
		$"../ShadowBallNode/ShadowBall".play("h1")
		anim_shadow.play("h1")
		set_collision_layer_value(2, false)
		await get_tree().create_timer(time).timeout
		set_collision_layer_value(2, true)
	else:
		$AnimatedSprite2D.play("h0free")
		$"../ShadowBallNode/ShadowBall".play("h0")
		anim_shadow.play("RESET")
		set_collision_layer_value(2, true)


func _on_match_finished():
	pass
