extends Node
class_name ColonyView

#region Constants
const SAVE_PATH := "user://pending_camp.dat"
const LOAD_DELAY := 0.5
#endregion

#region Lifecycle
func _ready():
	await get_tree().create_timer(LOAD_DELAY).timeout
	_try_load_pending_camp()

#endregion

#region Camp Loading
func _try_load_pending_camp():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var camp_name := _read_camp_name_from_file()
	if camp_name.is_empty():
		return
	
	_cleanup_save_file()
	_spawn_camp_from_name(camp_name)

func _read_camp_name_from_file() -> String:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return ""
	
	var camp_name := file.get_line()
	file.close()
	return camp_name

func _cleanup_save_file():
	DirAccess.remove_absolute(SAVE_PATH)

func _spawn_camp_from_name(camp_name: String):
	print("Spawning camp from file: ", camp_name)
	
	var cat_manager := _get_cat_manager()
	if not cat_manager:
		push_error("No CatManager found in ColonyView!")
		return
	
	cat_manager.spawn_camp(camp_name, Vector2.ZERO)

func _get_cat_manager() -> CatManager:
	var cat_managers := get_tree().get_nodes_in_group("cat_managers")
	if cat_managers.is_empty():
		return null
	return cat_managers[0] as CatManager
#endregion
