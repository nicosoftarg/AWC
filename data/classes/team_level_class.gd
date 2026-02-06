class_name TeamLevelClass
extends Resource

@export var id_level : int
@export var field_player_speed : float
@export var decision_time : float
@export var gk_player_speed : float
@export var bounces_dict : Dictionary[String, int] = {
	"no_bounce" : 50,
	"good_bounce" : 20,
	"corner_bounce" : 15,
	"bad_bounce" : 10,
	"goal_bounce" : 5,
	}
