extends Control

@export var match1 : Texture2D
@export var match2 : Texture2D
@export var match3 : Texture2D
@export var match4 : Texture2D
@export var match5 : Texture2D
@export var match6 : Texture2D
@export var match7 : Texture2D

@export_file('*.tscn') var new_game

@onready var shirt_com = $VBoxContainer/PanelContainer/Row2/ShirtCom
@onready var shirt_user = $VBoxContainer/PanelContainer2/Row3/ShirtUser
var com_team_palette : Texture2D
var user_team_palette : Texture2D

@onready var row_1 = $Row1




func _ready():
	get_tree().paused = false
	#set_match_preview_texture()
	$MatchPreviewMusic.play()
	$Row1/MatchNumber.text = Global.set_text_week()
	call_deferred("set_shirt_palette")
	await get_tree().create_timer(4.3).timeout
	get_tree().change_scene_to_file.call_deferred(new_game)
	
func _process(delta):
	banner(delta)

func banner(delta):
	if row_1.global_position.x < -220:
		row_1.global_position.x = 220
	row_1.global_position.x -= 40 * delta


func set_match_preview_texture():
	var texture_preview
	match Global.InfoUserGame.current_week:
		1:
			texture_preview = match1
		2:
			texture_preview = match2
		3:
			texture_preview = match3
		4:
			texture_preview = match4
		5:
			texture_preview = match5
		6:
			texture_preview = match6
		7:
			texture_preview = match7
	$TextureRect.texture = texture_preview




func set_shirt_palette():
	#var competition = Global.InfoUserGame.current_competition
	Global.set_cpu_team()
	var rival_id = Global.InfoUserGame.current_rival_team
	var user_id = Global.InfoUserGame.current_user_team
	#var week = Global.InfoUserGame.current_week
	com_team_palette = Global.get_data("Teams", rival_id, "palette")
	user_team_palette = Global.get_data("Teams", user_id, "palette")
	#$VBoxContainer/PanelContainer/Row2/ShirtCom.material.set_shader_parameter("palette_to", com_team_palette)
	#$VBoxContainer/PanelContainer2/Row3/ShirtUser.material.set_shader_parameter("palette_to", user_team_palette)
	$AwayTeam.material.set_shader_parameter("palette_to", com_team_palette)
	$HomeTeam.material.set_shader_parameter("palette_to", user_team_palette)	
	$AwayTeam/ClubName.text = Global.get_data("Teams", rival_id, "team_name")
	$HomeTeam/ClubName.text = Global.get_data("Teams", user_id, "team_name")
func _on_match_preview_finished():
	get_tree().change_scene_to_file.call_deferred(new_game)
