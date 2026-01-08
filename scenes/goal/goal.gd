extends Node2D

signal Goal(goal)

# Los targets shot están en 18 y - 18

@export var rival_team : int
@onready var ball = get_tree().get_first_node_in_group("ball")
@onready var gk_position: Marker2D = $PivotGK/GkPosition
@onready var sweeper_position: Marker2D = $PivotSweeper/SweeperPosition
@onready var Match = get_tree().get_first_node_in_group("match")
var positions_gk : Array[Marker2D]
var in_long_shot_area : bool = false
var in_aerial_pass_zone : bool = false
var ftf_l_active : bool = false
var ftf_r_active : bool = false

func _ready() -> void:
	positions_gk.append($"PositionsGK/1")
	positions_gk.append($"PositionsGK/2")
	positions_gk.append($"PositionsGK/3")
	positions_gk.append($"PositionsGK/4")
	positions_gk.append($"PositionsGK/5")
	positions_gk.append($"PositionsGK/6")
	positions_gk.append($"PositionsGK/7")


func _physics_process(_delta: float) -> void:
	$PivotGK.look_at(ball.global_position)
	$PivotSweeper.look_at(ball.global_position)

func _on_shot_area_area_entered(area: Area2D) -> void:
	if area.own_team == rival_team:
		area.in_shot_area = true
		if area == ball.player_with_ball:
			area.get_node("TimerDecision").stop()
			area.current_player_with_ball = area.PlayerWithBall.SHOT
			area.behavior_tree()


func _on_shot_area_area_exited(area: Area2D) -> void:
	if area.own_team == rival_team:
		area.in_shot_area = false


func _on_goal_line_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if body.can_scored:
			body.can_scored = false
			Goal.emit(self)


func _on_gk_for_ball_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if ball.player_with_ball:
			if ball.player_with_ball.own_team == rival_team:
				if rival_team == 0:
					print("Tiene que salir el arquero del equipo 1")
					Match.gk_1.current_player_state = Match.gk_1.PlayerState.GO_TO_BALL
				else:
					print("Tiene que salir el arquero del equipo 0")
					Match.gk_0.current_player_state = Match.gk_0.PlayerState.GO_TO_BALL
	


func _on_gk_for_ball_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		if ball.player_with_ball:
			if ball.player_with_ball.own_team == rival_team:
				if rival_team == 0:
					print("Tiene que volver el arquero del equipo 1")
					Match.gk_1.current_player_state = Match.gk_1.PlayerState.GO_TO_POSITION
					Match.gk_1.behavior_tree()
				else:
					print("Tiene que volver el arquero del equipo 0")
					Match.gk_0.current_player_state = Match.gk_0.PlayerState.GO_TO_POSITION
					Match.gk_0.behavior_tree()


func _on_long_shot_area_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		in_long_shot_area = true
		


func _on_long_shot_area_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		in_long_shot_area = false


func _on_areal_pass_l_body_entered(body):
	if body is RigidBody2D:
		print("Pelota en zona de centro L")
		in_aerial_pass_zone = true
		ftf_r_active = true


func _on_areal_pass_l_body_exited(body):
	if body is RigidBody2D:
		in_aerial_pass_zone = false
		ftf_r_active = false


func _on_areal_pass_r_body_entered(body):
	if body is RigidBody2D:
		print("Pelota en zona de centro R")
		in_aerial_pass_zone = true
		ftf_l_active = true


func _on_areal_pass_r_body_exited(body):
	if body is RigidBody2D:
		in_aerial_pass_zone = false
		ftf_l_active = false


func _on_ftfc_area_entered(area):
	if area.own_team == rival_team:
		area.in_ftfc = true



func _on_ftfc_area_exited(area):
	if area.own_team == rival_team:
		area.in_ftfc = false


func _on_ftfl_area_entered(area):
	if area.own_team == rival_team:
		area.in_ftfl = true



func _on_ftfl_area_exited(area):
	if area.own_team == rival_team:
		area.in_ftfl = false


func _on_ftflr_area_entered(area):
	if area.own_team == rival_team:
		area.in_ftfr = true



func _on_ftflr_area_exited(area):
	if area.own_team == rival_team:
		area.in_ftfr = false
