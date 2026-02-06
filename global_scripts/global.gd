extends Node

var PathFolders : Dictionary[String, String] = {
	#"saves" : "user://",
	"saves" : "user://saves/",
	"teams" : "res://data/db_res/teams/",
	"levels" : "res://data/db_res/levels/",
	"competitions" : "res://data/db_res/competitions/",
}

var InfoUserGame : Dictionary[String, int] = {
	"current_user_team" : 1,
	"current_rival_team" : 2,
	"current_week" : 1,
	"current_competition" : 1,
}

var teams_to_create : Dictionary
var competitions_to_create : Dictionary
var levels_to_create : Dictionary
var database

#Todo listo pàra salvar partida
var saves_path_array : Array[String]
var current_save_path : String
var current_save_game : SaveGameClass

# CREACIÓN DE BASE DE DATOS DINÁMICA
# ----------------------------------

func dbase_create() -> void:
	user_dir_create()
	current_save_path = get_save_game_path() 
	competitions_create()
	teams_create()
	levels_create()
	save_game_create()
	database = ResourceLoader.load(current_save_path)

func user_dir_create() -> void:
	if DirAccess.open("user://").dir_exists("saves"):
		print("Carpeta 'saves' ya creada")
		#return
	else:
		print("No existía la carpeta 'saves': creando carpeta")
		DirAccess.open("user://").make_dir("saves")
	
	#if DirAccess.open("user://").dir_exists("config"):
		#print("Carpeta 'config, ya creada")
		##return
	#else:
		#print("No existía la carpeta 'config': creando carpeta")
		#DirAccess.open("user://").make_dir("config")
	
func get_quantity_of_resources(path_folder)-> int:
	return DirAccess.open(path_folder).get_files().size()

func competitions_create():
	for item in get_quantity_of_resources(PathFolders.competitions):
		var path_recurso : String = PathFolders.competitions + str(item +1)+ ".tres"
		var current_competition_resource = load(path_recurso)
		var current_competition_dictionary : Dictionary = {
			"id" = current_competition_resource.id,
			"name" = current_competition_resource.name,
			"Fixture" = current_competition_resource.Fixture.duplicate(),
		}
		competitions_to_create[item + 1] = current_competition_dictionary.duplicate()

func teams_create():
	for item in get_quantity_of_resources(PathFolders.teams):
		var path_recurso : String = PathFolders.teams + str(item +1)+ ".tres"
		var current_club_resource = load(path_recurso)
		var current_club_dictionary : Dictionary = {
			"id_team" = current_club_resource.id_team,
			"palette" = current_club_resource.palette,
			"level" =  current_club_resource.level,
			"team_name" =  current_club_resource.team_name,
		}
		teams_to_create[item + 1] = current_club_dictionary.duplicate()

func levels_create():
	for item in get_quantity_of_resources(PathFolders.levels):
		var path_recurso : String = PathFolders.levels + str(item +1)+ ".tres"
		var current_level_resource = load(path_recurso)
		var current_level_dictionary : Dictionary = {
			"id_level" = current_level_resource.id_level,
			"field_player_speed" = current_level_resource.field_player_speed,
			"gk_player_speed" = current_level_resource.gk_player_speed,
			"decision_time" = current_level_resource.decision_time,
			"bounces_dict" = current_level_resource.bounces_dict.duplicate(true)
		}
		levels_to_create[item + 1] = current_level_dictionary.duplicate()
	


	
# CREACIÓN DEL SAVE GAME
# ----------------------

func get_save_game_path() -> String:
	# FUNCIÓN FINAL 
	#var saves_quant : int = get_quantity_of_resources(Path_Folders.saves)
	#return Path_Folders.saves + "savegame" + str(saves_quant + 1) + ".tres"
	
	#Esta es provisoria para grabar siempre en el mismo archivo
	return PathFolders.saves + "savegame1.tres" 
	

func save_game_create():
	var saved_game : SaveGameClass = SaveGameClass.new()
	saved_game.Teams = teams_to_create.duplicate()
	saved_game.Levels = levels_to_create.duplicate()
	saved_game.Competitions = competitions_to_create.duplicate()
	saved_game.InfoUserGame = InfoUserGame.duplicate()
	ResourceSaver.save(saved_game, current_save_path)

# SET Y GET DATA
# --------------

func get_table(access_table):
	match access_table:
		"Teams":
			return database.Teams
		"Competitions":
			return database.Competitions
		"InfoUserGame":
			return database.InfoUserGame
		"Levels":
			return database.Levels
		_:
			print ("No existe la tabla")



func get_data(access_table : String, id : int, field):
	var table = get_table(access_table)
	# Para acceder al dato:
	#print(table[id][field])
	return table[id][field]
	
	
func set_data(access_table : String, id : int, field, new_dato):
	var table = get_table(access_table)
	table[id][field] = new_dato
	ResourceSaver.save(database, current_save_path )


# MÉTODOS GLOBALES:

func set_text_week() -> String:
	match Global.InfoUserGame.current_week:
		1:
			return "1st Game"
		2:
			return "2nd Game"
		3:
			return "3rd Game"
		4:
			return "4th Game"
		5:
			return "5th Game"
		6:
			return "6th Game"
		_:
			return "Final Game"


func set_cpu_team():
	var fixture = get_data("Competitions", InfoUserGame.current_competition, "Fixture")
	InfoUserGame.current_rival_team = fixture[InfoUserGame.current_week]
