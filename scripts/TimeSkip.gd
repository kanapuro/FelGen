extends Button
@export var spawn_chance: float = 0.3

func _pressed():
	var all_camps = get_tree().get_nodes_in_group("camps")
	
	for camp in all_camps:
		# Age all cats in this camp
		if camp.has_method("time_skip"):
			camp.time_skip(1) # skip 1 month

		# Random chance to spawn a new cat
		if randf() < spawn_chance:
			if camp.has_node("CatManager"):
				var cat_manager = camp.get_node("CatManager") as CatManager
				cat_manager.spawn_cat("", "", camp.name)
				print("Spawned a new cat in camp:", camp.name)
