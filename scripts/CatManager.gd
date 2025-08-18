extends Node
class_name CatManager

@export var cat_scene: PackedScene
@export var spawn_padding: float = 50.0
var CatPageScene = preload("res://scenes/CatPage.tscn")
var current_cat_page: Node = null

var cats: Array = []

func _ready() -> void:
	randomize()

func spawn_cat(nick: String = "", gender: String = "", colony: String = "", age_months: int = 0) -> Node:
	if cat_scene == null:
		push_error("No Cat scene assigned to CatManager!")
		return null

	var inst = cat_scene.instantiate()
	if inst == null:
		push_error("cat_scene.instantiate() returned null")
		return null
	if !(inst is Cat):
		push_error("Cat scene isn't using the Cat.gd script (class_name Cat).")
		return null

	var cat: Cat = inst as Cat
	
	# ---------- RANDOMIZE gender if empty ----------
	if gender.is_empty():
		var gender_keys = Traits.GENDERS.keys()
		gender = gender_keys[randi() % gender_keys.size()]

	# ---------- RANDOMIZE nick if empty ----------
	if nick.is_empty():
		var roll = randf()  # 0-1
		if roll < 0.25:
			# 25% chance: syllable-based name
			var Nsyllablelist = Traits.SYLLIST
			var name_length = 2 + randi() % 2  # 2-3 syllables
			var raw_name = ""
			for i in range(name_length):
				raw_name += Nsyllablelist[randi() % Nsyllablelist.size()].to_lower()
			nick = raw_name.substr(0, 1).to_upper() + raw_name.substr(1)
		elif roll < 0.5:
			# 25% chance: prefix/suffix name
			var Nwordlist = Traits.WORDLIST
			if randf() < 0.5:
				nick = Nwordlist[randi() % Nwordlist.size()]
			else:
				var prefix = Nwordlist[randi() % Nwordlist.size()]
				var suffix = Nwordlist[randi() % Nwordlist.size()]
				while suffix == prefix:
					suffix = Nwordlist[randi() % Nwordlist.size()]
				nick = "%s %s" % [prefix, suffix]
		else:
			# 50% chance: manual list
			var Nnamelist = Traits.NAMELIST
			nick = Nnamelist[randi() % Nnamelist.size()]

	# ---------- basic data ----------
	cat.nick = nick
	cat.gender = gender
	cat.colony = colony
	cat.age_months = int(age_months)
	cat.compute_life_stage()

	# ---------- fur length ----------
	var stage_dict = Traits.POSES.get(cat.life_stage, {})
	if typeof(stage_dict) != TYPE_DICTIONARY or stage_dict.is_empty():
		push_error("No POSES for life_stage %s" % [cat.life_stage])
		return null

	var fur_keys: Array = ["short", "long"]
	cat.fur_length = fur_keys[randi() % fur_keys.size()]

	# ---------- pose pick ----------
	var pose_list: Array
	if cat.life_stage == "bairn":
		pose_list = stage_dict.get("short", [])
	else:
		pose_list = stage_dict.get(cat.fur_length, [])

	if pose_list.is_empty():
		push_error("Empty pose list for %s/%s" % [cat.life_stage, cat.fur_length])
		return null

	cat.current_pose_set = pose_list[randi() % pose_list.size()]

	# Set colors from pose data
	var base_dict = cat.current_pose_set.get("base", {})
	cat.base_color = base_dict.keys()[0] if base_dict.size() > 0 else "white"
	
	var eyes_dict = cat.current_pose_set.get("eyes", {})
	cat.eye_color = eyes_dict.keys()[0] if eyes_dict.size() > 0 else "error"

	# ---------- add to scene ----------
	add_child(cat)
	cat.add_to_group("cats")
	if cat.connect("clicked", _on_cat_clicked) != OK:
		push_error("Failed to connect clicked signal for cat ", cat.nick)
	cat.position = get_random_position()
	cat.call_deferred("update_sprites")

	cats.append(cat)
	return cat

func get_random_position(max_attempts: int = 100, min_distance: float = 50.0) -> Vector2:
	var vp = get_viewport()
	if not vp:
		push_warning("Failed to get viewport in get_random_position()")
		return Vector2.ZERO

	var screen_rect := vp.get_visible_rect().size
	var padding := spawn_padding + min_distance
	
	# Define safe spawn area (accounting for padding)
	var spawn_rect := Rect2(
		Vector2(padding, padding + 80.0),  # Top-left (with top buffer)
		Vector2(screen_rect.x - 2*padding, screen_rect.y - 2*padding - 80.0)  # Size
	)
	
	# Filter valid cats first
	var valid_cats := []
	for cat in cats:
		if cat and is_instance_valid(cat):
			valid_cats.append(cat)
	
	# Try to find valid position
	for _attempt in max_attempts:
		var test_pos := Vector2(
			randf_range(spawn_rect.position.x, spawn_rect.end.x),
			randf_range(spawn_rect.position.y, spawn_rect.end.y)
		)
		
		var position_valid := true
		for cat in valid_cats:
			if cat.position.distance_to(test_pos) < padding:
				position_valid = false
				break
				
		if position_valid:
			return test_pos
	
	# Fallback - find least bad position if all attempts fail
	if valid_cats.size() > 0:
		var best_pos := Vector2.ZERO
		var best_distance := 0.0
		
		# Do 10 quick checks to find least crowded spot
		for _i in 10:
			var test_pos := Vector2(
				randf_range(spawn_rect.position.x, spawn_rect.end.x),
				randf_range(spawn_rect.position.y, spawn_rect.end.y)
			)
			
			var min_dist := INF
			for cat in valid_cats:
				min_dist = min(min_dist, cat.position.distance_to(test_pos))
			
			if min_dist > best_distance:
				best_distance = min_dist
				best_pos = test_pos
				
		return best_pos
	
	# If no cats exist, return center of safe area
	return spawn_rect.get_center()

func _on_cat_clicked(cat: Cat) -> void:
	print("CatManager received click for: ", cat.nick)
	if is_instance_valid(current_cat_page):
		current_cat_page.queue_free()
	
	current_cat_page = CatPageScene.instantiate()
	get_viewport().add_child(current_cat_page)
	current_cat_page.position = get_viewport().size * 0.5 - current_cat_page.size * 0.5
	
	if current_cat_page.has_method("show_cat"):
		current_cat_page.show_cat(cat)
	else:
		push_error("CatPage missing show_cat() method!")

func age_all_cats(months: int = 1) -> void:
	for c in cats:
		if c and is_instance_valid(c):
			print("Aging cat:", c.nick, "from", c.age_months, "months")
			c.age_up(months)

func remove_cat(c: Node) -> void:
	if c and c in cats:
		cats.erase(c)
		if is_instance_valid(c):
			c.queue_free()
