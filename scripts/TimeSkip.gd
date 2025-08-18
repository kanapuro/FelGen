extends Button
@export var spawn_chance: float = 0.3

func _pressed():
	var all_camps = get_tree().get_nodes_in_group("camps")
	
	for camp in all_camps:
		# Age all cats in this camp
		if camp.has_method("time_skip"):
			camp.time_skip(1) # skip 1 month
			
			# Reposition all existing cats in this camp
			if camp.has_node("CatManager"):
				var cat_manager = camp.get_node("CatManager") as CatManager
				for cat in cat_manager.cats:
					if cat and is_instance_valid(cat):
						cat.position = cat_manager.get_random_position()
						print("Repositioned cat in camp: ", camp.name)

		# Random chance to spawn a new cat
		if randf() < spawn_chance:
			if camp.has_node("CatManager"):
				var cat_manager = camp.get_node("CatManager") as CatManager
				cat_manager.spawn_cat("", "", camp.name)
				print("Spawned a new cat in camp:", camp.name)
