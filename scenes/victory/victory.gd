extends Control

@onready var banner_row = $Banner

func _ready():
	get_tree().paused = false
	$AnimatedSprite2D.play("victory")
	call_deferred("set_shirt_palette")

func _process(delta):
	banner(delta)

func banner(delta):
	if banner_row.global_position.x < -180:
		banner_row.global_position.x = 180
	banner_row.global_position.x -= 40 * delta

	


func set_shirt_palette():
	var user_team_palette
	#Global.set_cpu_team()
	var user_id = Global.InfoUserGame.current_user_team
	user_team_palette = Global.get_data("Teams", user_id, "palette")
	$AnimatedSprite2D.material.set_shader_parameter("palette_to", user_team_palette)
	#$HomeTeam/ClubName.text = Global.get_data("Teams", user_id, "team_name")
