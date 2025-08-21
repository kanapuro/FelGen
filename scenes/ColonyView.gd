extends Node

func _ready():
	# Wait a moment for everything to load
	await get_tree().create_timer(0.5).timeout
	
	# Check if we have a camp to spawn
	if FileAccess.file_exists("user://pending_camp.dat"):
		var file = FileAccess.open("user://pending_camp.dat", FileAccess.READ)
		if file:
			var camp_name = file.get_line()  # Use get_line() instead of get_string()
			file.close()
			
			# Delete the file
			DirAccess.remove_absolute("user://pending_camp.dat")
			
			print("Spawning camp from file: ", camp_name)
			
			# Find the CatManager and spawn the camp
			var cat_managers = get_tree().get_nodes_in_group("cat_managers")
			if not cat_managers.is_empty():
				var cat_manager = cat_managers[0] as CatManager
				cat_manager.spawn_camp(camp_name, Vector2.ZERO)
			else:
				push_error("No CatManager found in ColonyView!")
