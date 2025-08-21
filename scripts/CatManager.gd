extends Node
class_name CatManager

@export var cat_scene: PackedScene
@export var camp_holder: Control
@export var camps_scene: PackedScene
@export var spawn_padding: float = 50.0
var CatPageScene = preload("res://scenes/CatPage.tscn")
var current_cat_page: Node = null

var camps: Dictionary = {}
var all_cats: Array = []
var next_cat_id: int = 1

func _ready() -> void:
	add_to_group("cat_managers")
	randomize()

func spawn_cat(camp_name: String, nick: String = "", gender: String = "", age_months: int = 0) -> Node:
	print("spawn_cat called with camp_name: '", camp_name, "'")
	
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
	
	# ====== ADD ID ASSIGNMENT HERE ======
	cat.id = next_cat_id
	next_cat_id += 1
	# ====================================
	
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
			# 25% chance: prefix/suffix name - with strong chance for single name
			var Nwordlist = Traits.WORDLIST
			var single_name_chance = 0.7  # 70% chance for single name, 30% for two names
			
			if randf() < single_name_chance:
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
	cat.colony = camp_name
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

	# ---------- base color ----------
	var color_keys = Traits.COLORS.keys()
	if color_keys.is_empty():
		cat.base_color = "white"
		push_warning("No colors defined in Traits.COLORS, defaulting to white")
	else:
		cat.base_color = get_random_color(Traits.COLORS, ["white"])
		
		# ---------- dilution (OPTIONAL) ----------
	var dilution_chance = 0.7  # 70%
	if randf() < dilution_chance:
		var dilution_keys = Traits.DILUTIONS.keys()
		if dilution_keys.is_empty():
			cat.dilution = "basic"
			push_warning("No dilutions defined, defaulting to basic")
		else:
			cat.dilution = dilution_keys[randi() % dilution_keys.size()]
	else:
		cat.dilution = "none"  

	# ---------- eye color ----------
	var eye_color_keys = Traits.EYE_COLORS.keys()
	if eye_color_keys.is_empty():
		cat.eye_color = "amber"  # fallback
	else:
		cat.eye_color = eye_color_keys[randi() % eye_color_keys.size()]

	# ---------- add to scene ----------
	# Find the camp this cat belongs to
	var target_camp = null
	for camp in camp_holder.get_children():
		if camp.name == camp_name:
			target_camp = camp
			break
	
	if target_camp:
		# Add cat as child of the camp
		target_camp.add_child(cat)
		print("✅ Cat added to camp: ", camp_name)
	else:
		# Fallback: add to cat manager
		add_child(cat)
		print("⚠️  Camp not found, cat added to manager")
	
	cat.add_to_group("cats")
	if cat.connect("clicked", _on_cat_clicked) != OK:
		push_error("Failed to connect clicked signal for cat ", cat.nick)
	
	# Position within the camp
	cat.position = get_random_position(camp_name)
	cat.call_deferred("update_sprites")

	# ====== ADD CAMP TRACKING ======
	if not camps.has(camp_name):
		camps[camp_name] = []
	camps[camp_name].append(cat)
	all_cats.append(cat)
	# ===============================
	print("Spawned cat ID ", cat.id, ": ", cat.nick, " in camp: ", camp_name)
	return cat

func get_random_position(camp_name: String = "", max_attempts: int = 100, min_distance: float = 50.0) -> Vector2:
	# If camp specified, try to use its SpawnArea
	if not camp_name.is_empty():
		print("Looking for camp in holder: ", camp_name)
		
		# Check if we have any camps in the holder
		if camp_holder.get_child_count() == 0:
			print("No camps in holder, using fallback")
		else:
			print("Camps in holder:")
			for camp in camp_holder.get_children():
				print("  - ", camp.name)
		
		# Find the active camp by colony name (not node name)
		var active_camp = null
		for cat in all_cats:
			if cat.colony == camp_name:
				# Find which camp this cat belongs to
				for camp in camp_holder.get_children():
					if camp.name == cat.colony:
						active_camp = camp
						break
				if active_camp:
					break
		
		if not active_camp:
			# Alternative: just use the first camp in holder
			if camp_holder.get_child_count() > 0:
				active_camp = camp_holder.get_child(0)
				print("Using first camp in holder: ", active_camp.name)
		
		if active_camp:
			var spawn_area = active_camp.get_node_or_null("SpawnArea") as Polygon2D
			if spawn_area and spawn_area.polygon.size() > 2:
				print("✅ Using SpawnArea for camp: ", active_camp.name)
				return get_random_position_in_polygon(spawn_area.polygon, spawn_area.global_position, max_attempts, min_distance, camp_name)
			else:
				print("❌ No valid SpawnArea found in camp: ", active_camp.name)
				if spawn_area:
					print("   SpawnArea points: ", spawn_area.polygon.size())
	
	# Fallback to screen positioning
	print("Using fallback positioning")
	var vp = get_viewport()
	if not vp:
		push_warning("Failed to get viewport in get_random_position()")
		return Vector2.ZERO

	var screen_rect := vp.get_visible_rect().size
	var padding := spawn_padding + min_distance
	
	# Define safe spawn area (accounting for padding)
	var spawn_rect := Rect2(
		Vector2(padding, padding + 80.0),
		Vector2(screen_rect.x - 2*padding, screen_rect.y - 2*padding - 80.0)
	)
	
	# If camp specified, only check cats in that camp
	var cats_to_check = all_cats
	if not camp_name.is_empty() and camps.has(camp_name):
		cats_to_check = camps[camp_name]
	
	# Filter valid cats first
	var valid_cats := []
	for cat in cats_to_check:
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
	
	return spawn_rect.get_center()

func get_random_position_in_polygon(polygon: PackedVector2Array, offset: Vector2 = Vector2.ZERO, 
								   max_attempts: int = 50, min_distance: float = 50.0, 
								   camp_name: String = "") -> Vector2:
	if polygon.size() < 3:
		push_warning("Polygon needs at least 3 points")
		return offset
	
	# Create a scaled-down polygon for padding (10% smaller)
	var padded_polygon = _create_padded_polygon(polygon, 0.1)
	
	# Find bounding box of PADDED polygon
	var min_point = padded_polygon[0]
	var max_point = padded_polygon[0]
	for point in padded_polygon:
		min_point = min_point.min(point)
		max_point = max_point.max(point)
	
	# Get cats in this specific camp
	var camp_cats = []
	if not camp_name.is_empty():
		for cat in all_cats:
			if cat and is_instance_valid(cat) and cat.colony == camp_name:
				camp_cats.append(cat)
	
	# Try random points until one is inside the PADDED polygon and not too close to other cats
	for _attempt in max_attempts:
		var test_point = Vector2(
			randf_range(min_point.x, max_point.x),
			randf_range(min_point.y, max_point.y)
		) + offset
		
		# Check if point is inside PADDED polygon and has enough distance from other cats
		if Geometry2D.is_point_in_polygon(test_point - offset, padded_polygon):
			var valid_position = true
			
			# Check distance from other cats in this camp
			for cat in camp_cats:
				if cat.position.distance_to(test_point) < min_distance:
					valid_position = false
					break
			
			if valid_position:
				return test_point
	
	# Fallback: try without padding if padded version fails
	for _attempt in max_attempts:
		var test_point = Vector2(
			randf_range(min_point.x, max_point.x),
			randf_range(min_point.y, max_point.y)
		) + offset
		
		if Geometry2D.is_point_in_polygon(test_point - offset, polygon):
			return test_point
	
	# Ultimate fallback: return center of polygon
	var center = Vector2.ZERO
	for point in polygon:
		center += point
	center /= polygon.size()
	return center + offset

# ADD THIS HELPER FUNCTION:
func _create_padded_polygon(polygon: PackedVector2Array, padding_factor: float = 0.1) -> PackedVector2Array:
	if polygon.size() < 3:
		return polygon
	
	# Find center of polygon
	var center = Vector2.ZERO
	for point in polygon:
		center += point
	center /= polygon.size()
	
	# Scale points toward center
	var padded_polygon = PackedVector2Array()
	for point in polygon:
		var direction = (point - center).normalized()
		var distance = point.distance_to(center)
		var padded_point = center + direction * distance * (1.0 - padding_factor)
		padded_polygon.append(padded_point)
	
	return padded_polygon

func get_camp_name_from_offset(offset: Vector2) -> String:
	# Try to find which camp this offset corresponds to
	var camp_nodes = get_tree().get_nodes_in_group("camps")
	for camp in camp_nodes:
		var spawn_area = camp.get_node_or_null("SpawnArea") as Polygon2D
		if spawn_area and spawn_area.global_position == offset:
			return camp.name
	return ""

func get_random_color(color_dict: Dictionary, exclude_colors: Array = []) -> String:
	if color_dict.is_empty():
		return "default"
	
	var available_colors = color_dict.keys()
	
	# Filter out excluded colors
	if not exclude_colors.is_empty():
		available_colors = available_colors.filter(
			func(color): return not exclude_colors.has(color)
		)
	
	# Fallback logic
	if available_colors.is_empty():
		push_warning("No valid colors after filtering, using first available")
		return color_dict.keys()[0]
	
	return available_colors[randi() % available_colors.size()]

func _on_cat_clicked(cat: Cat) -> void:
	#print("CatManager received click for: ", cat.nick)
	if is_instance_valid(current_cat_page):
		current_cat_page.queue_free()
	
	current_cat_page = CatPageScene.instantiate()
	get_viewport().add_child(current_cat_page)
	current_cat_page.position = get_viewport().size * 0.5 - current_cat_page.size * 0.5
	
	if current_cat_page.has_method("show_cat"):
		current_cat_page.show_cat(cat, cat_scene)  # PASS cat_scene here
	else:
		push_error("CatPage missing show_cat() method!")

func age_all_cats(months: int = 1) -> void:
	for c in all_cats:
		if c and is_instance_valid(c):
			print("Aging cat:", c.nick, "from", c.age_months, "months")
			c.age_up(months)

func remove_cat(c: Node) -> void:
	if c and c in all_cats:
		all_cats.erase(c)
		if is_instance_valid(c):
			c.queue_free()

# ====== ID SYSTEM UTILITIES ======
func get_cat_by_id(id: int) -> Cat:
	for cat in all_cats:
		if cat.id == id:
			return cat
	return null

func get_all_cat_ids() -> Array:
	return all_cats.map(func(cat): return cat.id)

func print_cat_ids() -> void:
	print("All cat IDs: ", get_all_cat_ids())

# ====== CAMP MANAGEMENT UTILITIES ======
func transfer_cat(cat_id: int, from_camp: String, to_camp: String):
	var cat = get_cat_by_id(cat_id)
	if cat and camps.has(from_camp) and camps.has(to_camp) and cat in camps[from_camp]:
		# Remove from old camp's array
		camps[from_camp].erase(cat)
		
		# Add to new camp's array  
		camps[to_camp].append(cat)
		cat.colony = to_camp
		
		# If you want to physically move the cat to a different camp node:
		var old_camp = camp_holder.get_node_or_null(from_camp)
		var new_camp = camp_holder.get_node_or_null(to_camp)
		
		if old_camp and new_camp and old_camp != new_camp:
			# Reparent the cat to the new camp
			old_camp.remove_child(cat)
			new_camp.add_child(cat)
			# Reposition within new camp
			cat.position = get_random_position(to_camp)
		
		print("Transferred cat ", cat_id, " from ", from_camp, " to ", to_camp)

func get_cats_in_camp(camp_name: String) -> Array:
	return camps.get(camp_name, [])

func create_camp(camp_name: String):
	if not camps.has(camp_name):
		camps[camp_name] = []
		print("Created new camp: ", camp_name)

func get_all_camps() -> Array:
	return camps.keys()

func get_camp_of_cat(cat_id: int) -> String:
	var cat = get_cat_by_id(cat_id)
	if cat:
		return cat.colony
	return ""

func spawn_camp(camp_name: String, position: Vector2 = Vector2.ZERO) -> Node:
	print("Spawning camp: ", camp_name)
	
	if not camp_holder:
		push_error("No camp holder assigned!")
		return null
	
	if not camps_scene:
		push_error("No camps scene assigned!")
		return null
	
	# Instantiate the camps scene to access its children
	var all_camps_instance = camps_scene.instantiate()
	var target_camp = all_camps_instance.get_node_or_null(camp_name)
	
	if not target_camp:
		push_error("Camp not found: ", camp_name)
		all_camps_instance.queue_free()
		return null
	
	# Duplicate the camp and add to holder
	var new_camp = target_camp.duplicate()
	camp_holder.add_child(new_camp)
	new_camp.position = position
	
	# HIDE THE SPAWNAREA - ADD THIS
	var spawn_area = new_camp.get_node_or_null("SpawnArea") as Polygon2D
	if spawn_area:
		spawn_area.visible = false
		print("✅ SpawnArea hidden")
	else:
		print("⚠️  No SpawnArea found in spawned camp")
	
	# Clean up
	all_camps_instance.queue_free()
	
	print("✅ Camp spawned: ", new_camp.name)
	return new_camp

func _debug_camp_situation(camp_name: String):
	print("=== CAMP DEBUG ===")
	print("Requested camp: ", camp_name)
	print("Camps in holder: ", camp_holder.get_child_count())
	
	for camp in camp_holder.get_children():
		print("  - Camp: ", camp.name)
		var spawn_area = camp.get_node_or_null("SpawnArea") as Polygon2D
		if spawn_area:
			print("    SpawnArea: ", spawn_area.polygon.size(), " points | Visible: ", spawn_area.visible)
		else:
			print("    No SpawnArea!")
	
	print("Cats and their colonies:")
	for cat in all_cats:
		print("  - ", cat.nick, " -> ", cat.colony)
	
	print("=== END DEBUG ===")

func switch_current_camp(camp_name: String):
	print("Switching to camp: ", camp_name)
	
	# Hide all camps first
	for camp in camp_holder.get_children():
		camp.visible = false
		# Also disable processing to save performance
		camp.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Show and enable the target camp
	var target_camp = camp_holder.get_node_or_null(camp_name)
	if target_camp:
		target_camp.visible = true
		target_camp.process_mode = Node.PROCESS_MODE_INHERIT
		print("✅ Switched to camp: ", camp_name)
		
		# Optional: Center view on camp if you have camera movement
		# emit_signal("camp_changed", target_camp.global_position)
	else:
		print("❌ Camp not found: ", camp_name)
