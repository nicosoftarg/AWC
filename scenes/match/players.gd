extends Node2D

@onready var players_team_0 = get_tree().get_nodes_in_group("player_team_0")
@onready var players_team_1 = get_tree().get_nodes_in_group("player_team_1")


func _ready():
	for item in players_team_0.size():
		players_team_1[item].global_position = -players_team_0[item].global_position
		players_team_1[item].kick_off_position = players_team_1[item].global_position
		players_team_1[item].get_node("Positions/Position").global_position = -players_team_0[item].get_node("Positions/Position").global_position
		players_team_1[item].default_position = players_team_1[item].get_node("Positions/Position").global_position
