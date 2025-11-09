extends Node

const SAVE_DIR = "user://FelGen/saves/"
var current_world_id: String = "" 
var current_world_name: String = ""

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	 
	print("🎯 SaveManager _ready() called!")
	print("🎯 SaveManager path: ", get_path())
	print("🎯 SaveManager owner: ", owner)
	
	var current_scene = get_tree().current_scene
	print("🎯 SaveManager scene: ", current_scene.name if current_scene else "No current scene")
	
	# Create saves directory if it doesn't exist
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		# Create both FelGen and saves directories
		var felgen_dir = "user://FelGen/"
		if not DirAccess.dir_exists_absolute(felgen_dir):
			DirAccess.make_dir_absolute(felgen_dir)
		DirAccess.make_dir_absolute(SAVE_DIR)
	
	print("✅ SaveManager initialized")
	print("📁 Save directory: ", SAVE_DIR)

func _exit_tree():
	print("💀 SaveManager is being destroyed! This shouldn't happen for autoloads!")

func save_game(world_name: String = "My Clan") -> bool:
	print("💾 SAVE GAME CALLED - World: ", world_name)
	print("💾 Current world ID before save: '", current_world_id, "'")
	
	var save_data = SaveData.new()
	save_data.world_name = world_name
	
	if current_world_id.is_empty():
		current_world_id = save_data.world_id
		print("🆕 Created new world ID: ", current_world_id)
	else:
		save_data.world_id = current_world_id
		print("✅ Using existing world ID: ", current_world_id)
	
	current_world_name = world_name
	
	# Collect basic camp data
	var cat_manager = _get_cat_manager()
	if cat_manager:
		print("📊 Collecting data from ", cat_manager.camps.size(), " camps")
		for camp_name in cat_manager.camps:
			print("  - Camp: ", camp_name)
			var camp_data = {
				"name": camp_name,
				"cats": []
			}
			# Add cats in this camp
			var cats_in_camp = cat_manager.get_cats_in_camp(camp_name)
			print("    Cats in camp: ", cats_in_camp.size())
			for cat in cats_in_camp:
				if cat and is_instance_valid(cat):
					camp_data.cats.append(_get_cat_save_data(cat))
			save_data.camps.append(camp_data)
	else:
		print("❌ No CatManager found!")
		return false
	
	# Save to JSON file instead of TRES
	var file_path = SAVE_DIR + save_data.world_id + ".json"
	print("💾 Writing JSON to: ", file_path)
	
	return _write_json_file(file_path, save_data)

# LOAD - Load a saved game from JSON
func load_game(world_id: String) -> bool:
	print("📂 Loading game from JSON...")
	
	var file_path = SAVE_DIR + world_id + ".json"
	var save_data = _read_json_file(file_path)
	if save_data == null:
		return false
	
	# Set current world info
	current_world_id = save_data.world_id
	current_world_name = save_data.world_name
	
	# Restore the game state
	return _restore_game(save_data)

# GET SAVES - List all saved games (now JSON files)
func get_saved_games() -> Array:
	var saves = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):  # Changed to .json
				var save_path = SAVE_DIR + file_name
				var save_data = _read_json_file(save_path)
				if save_data:
					saves.append({
						"world_id": save_data.world_id,
						"world_name": save_data.world_name,
						"timestamp": save_data.timestamp
					})
			file_name = dir.get_next()
	
	# Sort by timestamp (newest first)
	saves.sort_custom(func(a, b): return a.timestamp > b.timestamp)
	return saves

# PRIVATE METHODS
func _get_cat_manager() -> CatManager:
	var managers = get_tree().get_nodes_in_group("cat_managers")
	return managers[0] if not managers.is_empty() else null

func _get_cat_save_data(cat: Cat) -> Dictionary:
	return {
		"id": cat.id,
		"nick": cat.nick,
		"gender": cat.gender,
		"age_months": cat.age_months,
		"life_stage": cat.life_stage,
		"position": {"x": cat.position.x, "y": cat.position.y},
		"fur_length": cat.fur_length,
		"dilution": cat.dilution,
		"base_color": cat.base_color,
		"base_pattern": cat.base_pattern,
		"eye_color": cat.eye_color,
		"eye_pattern": cat.eye_pattern,
		"stats": cat.stats.duplicate(),
		"core_ability": cat.core_ability,
		"character_class": cat.character_class,
		"xp": cat.xp,
		"level": cat.level,
		"proficiencies": cat.proficiencies.duplicate()
	}

func _restore_game(save_data: SaveData) -> bool:
	# Clear current game
	var cat_manager = _get_cat_manager()
	if not cat_manager:
		return false
	
	# Remove all current cats
	for camp_name in cat_manager.camps.duplicate():
		var cats = cat_manager.get_cats_in_camp(camp_name).duplicate()
		for cat in cats:
			cat_manager.remove_cat(cat)
	
	# Restore camps and cats from save
	for camp_data in save_data.camps:
		# Ensure camp exists
		var camp_node = cat_manager.camp_holder.get_node_or_null(camp_data.name)
		if not camp_node:
			camp_node = cat_manager.spawn_camp(camp_data.name, Vector2.ZERO)
		
		# Restore cats
		for cat_data in camp_data.cats:
			var cat = cat_manager.spawn_cat(
				camp_data.name, 
				cat_data.nick, 
				cat_data.gender, 
				cat_data.age_months
			)
			if cat:
				# Restore all cat properties
				cat.id = cat_data.id
				cat.life_stage = cat_data.life_stage
				cat.fur_length = cat_data.fur_length
				cat.dilution = cat_data.dilution
				cat.base_color = cat_data.base_color
				cat.base_pattern = cat_data.base_pattern
				cat.eye_color = cat_data.eye_color
				cat.eye_pattern = cat_data.eye_pattern
				cat.position = Vector2(cat_data.position.x, cat_data.position.y)
				cat.stats = cat_data.stats.duplicate()
				cat.core_ability = cat_data.core_ability
				cat.character_class = cat_data.character_class
				cat.xp = cat_data.xp
				cat.level = cat_data.level
				cat.proficiencies = cat_data.proficiencies.duplicate()
				
				# Update visual appearance
				cat.update_pose_and_sprites()
	
	print("✅ Loaded: ", save_data.world_name)
	return true

# JSON FILE OPERATIONS
func _write_json_file(path: String, save_data: SaveData) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("Failed to create JSON file: ", path)
		return false
	
	var json_string = JSON.stringify(save_data.serialize(), "  ")
	file.store_string(json_string)
	file.close()
	print("✅ JSON saved: ", path)
	return true

func _read_json_file(path: String) -> SaveData:
	if not FileAccess.file_exists(path):
		push_error("JSON file doesn't exist: ", path)
		return null
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to read JSON file: ", path)
		return null
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Failed to parse JSON: ", json.get_error_message())
		return null
	
	var data = json.get_data()
	return SaveData.deserialize(data)
