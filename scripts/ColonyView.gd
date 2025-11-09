extends Node
class_name ColonyView

#region Constants
const SAVE_PATH := "user://pending_camp.dat"
const LOAD_DELAY := 0.5
#endregion

var save_manager: SaveManager

func _ready():
	save_manager = _get_save_manager()
	
	print("🔍 ColonyView - Checking world state:")
	print("  SaveManager found: ", save_manager != null)
	if save_manager:
		print("  Current world ID: '", save_manager.current_world_id, "'")
		print("  Current world name: '", save_manager.current_world_name, "'")
	
	if save_manager and save_manager.current_world_id.is_empty():
		print("🌍 Creating new world...")
		var world_name = "New Clan " + Time.get_datetime_string_from_system().replace(":", ".")
		if save_manager.save_game(world_name):
			print("✅ New world created: ", world_name)
			print("🌍 World ID: ", save_manager.current_world_id)
		else:
			print("❌ Failed to create new world")
	
	await get_tree().create_timer(LOAD_DELAY).timeout
	_try_load_pending_camp()

func _get_save_manager() -> SaveManager:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager") as SaveManager
	return null

func _try_load_pending_camp():
	if not FileAccess.file_exists("user://pending_camp.dat"):
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
