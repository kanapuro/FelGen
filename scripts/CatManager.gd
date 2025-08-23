extends Node
class_name CatManager

#region Constants
const CAT_GROUP := "cats"
const CAMP_GROUP := "camps"
const CAT_MANAGER_GROUP := "cat_managers"
#endregion

#region Exports
@export var cat_scene: PackedScene
@export var camp_holder: Control
@export var camps_scene: PackedScene
@export var spawn_padding: float = 50.0
#endregion

#region Preloads
var CatPageScene := preload("res://scenes/CatPage.tscn")
#endregion

#region Variables
var current_cat_page: Node = null
var camps: Dictionary = {}
var all_cats: Array = []
var next_cat_id: int = 1
#endregion

#region Lifecycle
func _ready() -> void:
	add_to_group(CAT_MANAGER_GROUP)
	randomize()
#endregion

#region Cat Spawning
func spawn_cat(camp_name: String, nick: String = "", gender: String = "", age_months: int = 0) -> Node:
	if not _validate_cat_scene():
		return null
	
	var cat := _create_cat_instance()
	if not cat:
		return null
	
	_setup_cat_attributes(cat, camp_name, nick, gender, age_months)
	_place_cat_in_scene(cat, camp_name)
	_connect_cat_signals(cat)
	_track_cat(cat, camp_name)
	
	print("Spawned cat ID ", cat.id, ": ", cat.nick, " in camp: ", camp_name)
	debug_all_cats_stats()
	return cat

func _validate_cat_scene() -> bool:
	if cat_scene == null:
		push_error("No Cat scene assigned to CatManager!")
		return false
	return true

func _create_cat_instance() -> Cat:
	var inst = cat_scene.instantiate()
	if inst == null:
		push_error("cat_scene.instantiate() returned null")
		return null
	if not (inst is Cat):
		push_error("Cat scene isn't using the Cat.gd script")
		return null
	return inst as Cat

func _setup_cat_attributes(cat: Cat, camp_name: String, nick: String, gender: String, age_months: int):
	cat.id = next_cat_id
	next_cat_id += 1
	
	cat.nick = _generate_nickname(nick)
	cat.gender = _generate_gender(gender)
	cat.colony = camp_name
	cat.age_months = age_months
	cat.compute_life_stage()
	
	_assign_visual_traits(cat)
	_assign_pose(cat)
	_generate_stats_and_abilities(cat)

func _assign_visual_traits(cat: Cat):
	cat.fur_length = _get_random_fur_length()
	cat.base_color = get_random_color(Traits.COLORS, ["white"])
	cat.base_pattern = _get_random_base_pattern()
	cat.dilution = _get_random_dilution()
	cat.eye_pattern = _get_random_eye_pattern()
	cat.eye_color = _get_random_eye_color()

func _assign_pose(cat: Cat):
	var stage_dict = Traits.POSES.get(cat.life_stage, {})
	if stage_dict.is_empty():
		push_error("No POSES for life_stage %s" % cat.life_stage)
		return
	
	var pose_list := _get_pose_list(cat.life_stage, cat.fur_length)
	if pose_list.is_empty():
		push_error("Empty pose list for %s/%s" % [cat.life_stage, cat.fur_length])
		return
	
	cat.current_pose_set = pose_list.pick_random()

func _get_pose_list(life_stage: String, fur_length: String) -> Array:
	if life_stage == "bairn":
		return Traits.POSES.get(life_stage, {}).get("short", [])
	return Traits.POSES.get(life_stage, {}).get(fur_length, [])

func _place_cat_in_scene(cat: Cat, camp_name: String):
	var target_camp := _find_target_camp(camp_name)
	if target_camp:
		target_camp.add_child(cat)
		print("✅ Cat added to camp: ", camp_name)
	else:
		add_child(cat)
		print("⚠️  Camp not found, cat added to manager")
	
	cat.position = get_random_position(camp_name)
	cat.call_deferred("update_sprites")

func _connect_cat_signals(cat: Cat):
	if cat.connect("clicked", _on_cat_clicked) != OK:
		push_error("Failed to connect clicked signal for cat ", cat.nick)

func _track_cat(cat: Cat, camp_name: String):
	if not camps.has(camp_name):
		camps[camp_name] = []
	camps[camp_name].append(cat)
	all_cats.append(cat)
	cat.add_to_group(CAT_GROUP)
#endregion

#region Name Generation
func _generate_nickname(default_nick: String) -> String:
	if not default_nick.is_empty():
		return default_nick
	
	var roll := randf()
	if roll < 0.25:
		return _generate_syllable_name()
	elif roll < 0.5:
		return _generate_prefix_suffix_name()
	else:
		return _generate_manual_name()

func _generate_syllable_name() -> String:
	var name_length := 2 + randi() % 2
	var raw_name := ""
	for i in range(name_length):
		raw_name += Traits.SYLLIST.pick_random().to_lower()
	return raw_name.substr(0, 1).to_upper() + raw_name.substr(1)

func _generate_prefix_suffix_name() -> String:
	if randf() < 0.7:
		return Traits.WORDLIST.pick_random() as String
	
	var prefix := Traits.WORDLIST.pick_random() as String
	var suffix := Traits.WORDLIST.pick_random() as String
	while suffix == prefix:
		suffix = Traits.WORDLIST.pick_random() as String 
	return "%s %s" % [prefix, suffix]

func _generate_manual_name() -> String:
	return Traits.NAMELIST.pick_random()

func _generate_gender(default_gender: String) -> String:
	if not default_gender.is_empty():
		return default_gender
	return Traits.GENDERS.keys().pick_random()
#endregion

#region Random Generators
func _get_random_fur_length() -> String:
	return ["short", "long"].pick_random()

func _get_random_base_pattern() -> String:
	return ["solid", "smokeback"].pick_random()

func _get_random_dilution() -> String:
	if randf() < 0.7:
		return Traits.DILUTIONS.keys().pick_random() if not Traits.DILUTIONS.is_empty() else "basic"
	return "none"

func _get_random_eye_pattern() -> String:
	return ["default"].pick_random()

func _get_random_eye_color() -> String:
	return Traits.EYE_COLORS.keys().pick_random() if not Traits.EYE_COLORS.is_empty() else "amber"

func get_random_color(color_dict: Dictionary, exclude_colors: Array = []) -> String:
	if color_dict.is_empty():
		return "default"
	
	var available_colors := color_dict.keys().filter(
		func(color): return not exclude_colors.has(color)
	)
	
	if available_colors.is_empty():
		push_warning("No valid colors after filtering, using first available")
		return color_dict.keys()[0]
	
	return available_colors.pick_random()
#endregion

#region Position Utilities
func get_random_position(camp_name: String = "", max_attempts: int = 100, min_distance: float = 50.0) -> Vector2:
	if not camp_name.is_empty():
		var position := _try_camp_position(camp_name, max_attempts, min_distance)
		if position != Vector2.ZERO:
			return position
	
	return _get_fallback_position(camp_name, max_attempts, min_distance)

func _try_camp_position(camp_name: String, max_attempts: int, min_distance: float) -> Vector2:
	var active_camp := _find_active_camp(camp_name)
	if not active_camp:
		return Vector2.ZERO
	
	var spawn_area := active_camp.get_node_or_null("SpawnArea") as Polygon2D
	if spawn_area and spawn_area.polygon.size() > 2:
		return get_random_position_in_polygon(spawn_area.polygon, spawn_area.global_position, max_attempts, min_distance, camp_name)
	return Vector2.ZERO

func _get_fallback_position(camp_name: String, max_attempts: int, min_distance: float) -> Vector2:
	var vp := get_viewport()
	if not vp:
		push_warning("Failed to get viewport")
		return Vector2.ZERO
	
	var screen_rect := vp.get_visible_rect().size
	var padding := spawn_padding + min_distance
	var spawn_rect := Rect2(
		Vector2(padding, padding + 80.0),
		Vector2(screen_rect.x - 2 * padding, screen_rect.y - 2 * padding - 80.0)
	)
	
	var valid_cats := _get_valid_cats_for_camp(camp_name)
	return _find_valid_position(spawn_rect, valid_cats, padding, max_attempts)

func _find_valid_position(spawn_rect: Rect2, valid_cats: Array, padding: float, max_attempts: int) -> Vector2:
	for _attempt in max_attempts:
		var test_pos := Vector2(
			randf_range(spawn_rect.position.x, spawn_rect.end.x),
			randf_range(spawn_rect.position.y, spawn_rect.end.y)
		)
		
		if _is_position_valid(test_pos, valid_cats, padding):
			return test_pos
	
	return _find_best_fallback_position(spawn_rect, valid_cats)

func _is_position_valid(position: Vector2, cats: Array, min_distance: float) -> bool:
	for cat in cats:
		if cat.position.distance_to(position) < min_distance:
			return false
	return true

func _find_best_fallback_position(spawn_rect: Rect2, valid_cats: Array) -> Vector2:
	if valid_cats.is_empty():
		return spawn_rect.get_center()
	
	var best_pos := Vector2.ZERO
	var best_distance := 0.0
	
	for _i in 10:
		var test_pos := Vector2(
			randf_range(spawn_rect.position.x, spawn_rect.end.x),
			randf_range(spawn_rect.position.y, spawn_rect.end.y)
		)
		
		var min_dist := _get_min_distance_to_cats(test_pos, valid_cats)
		if min_dist > best_distance:
			best_distance = min_dist
			best_pos = test_pos
	
	return best_pos

func _get_min_distance_to_cats(position: Vector2, cats: Array) -> float:
	var min_dist := INF
	for cat in cats:
		min_dist = min(min_dist, cat.position.distance_to(position))
	return min_dist

func get_random_position_in_polygon(polygon: PackedVector2Array, offset: Vector2 = Vector2.ZERO, 
								   max_attempts: int = 50, min_distance: float = 50.0, 
								   camp_name: String = "") -> Vector2:
	if polygon.size() < 3:
		push_warning("Polygon needs at least 3 points")
		return offset
	
	var padded_polygon := _create_padded_polygon(polygon, 0.1)
	var bounds := _get_polygon_bounds(padded_polygon)
	var camp_cats := _get_camp_cats(camp_name)
	
	for _attempt in max_attempts:
		var test_point := _get_random_point_in_bounds(bounds) + offset
		if _is_point_valid_in_polygon(test_point, offset, padded_polygon, camp_cats, min_distance):
			return test_point
	
	# Fallback to non-padded polygon
	for _attempt in max_attempts:
		var test_point := _get_random_point_in_bounds(_get_polygon_bounds(polygon)) + offset
		if Geometry2D.is_point_in_polygon(test_point - offset, polygon):
			return test_point
	
	return _get_polygon_center(polygon) + offset

func _create_padded_polygon(polygon: PackedVector2Array, padding_factor: float) -> PackedVector2Array:
	if polygon.size() < 3:
		return polygon
	
	var center := _get_polygon_center(polygon)
	var padded_polygon := PackedVector2Array()
	
	for point in polygon:
		var direction := (point - center).normalized()
		var distance := point.distance_to(center)
		padded_polygon.append(center + direction * distance * (1.0 - padding_factor))
	
	return padded_polygon

func _get_polygon_bounds(polygon: PackedVector2Array) -> Dictionary:
	var min_point := polygon[0]
	var max_point := polygon[0]
	
	for point in polygon:
		min_point = min_point.min(point)
		max_point = max_point.max(point)
	
	return {"min": min_point, "max": max_point}

func _get_random_point_in_bounds(bounds: Dictionary) -> Vector2:
	return Vector2(
		randf_range(bounds.min.x, bounds.max.x),
		randf_range(bounds.min.y, bounds.max.y)
	)

func _is_point_valid_in_polygon(point: Vector2, offset: Vector2, polygon: PackedVector2Array, 
							   cats: Array, min_distance: float) -> bool:
	if not Geometry2D.is_point_in_polygon(point - offset, polygon):
		return false
	
	for cat in cats:
		if cat.position.distance_to(point) < min_distance:
			return false
	
	return true

func _get_polygon_center(polygon: PackedVector2Array) -> Vector2:
	var center := Vector2.ZERO
	for point in polygon:
		center += point
	return center / polygon.size()

func _get_valid_cats_for_camp(camp_name: String) -> Array:
	var cats_to_check := all_cats
	if not camp_name.is_empty() and camps.has(camp_name):
		cats_to_check = camps[camp_name]
	
	return cats_to_check.filter(func(cat): return cat and is_instance_valid(cat))

func _get_camp_cats(camp_name: String) -> Array:
	if camp_name.is_empty():
		return []
	
	return all_cats.filter(
		func(cat): return cat and is_instance_valid(cat) and cat.colony == camp_name
	)
#endregion

#region Camp Utilities
func _find_target_camp(camp_name: String) -> Node:
	for camp in camp_holder.get_children():
		if camp.name == camp_name:
			return camp
	return null

func _find_active_camp(camp_name: String) -> Node:
	for cat in all_cats:
		if cat.colony == camp_name:
			for camp in camp_holder.get_children():
				if camp.name == cat.colony:
					return camp
			break
	
	if camp_holder.get_child_count() > 0:
		return camp_holder.get_child(0)
	
	return null

func get_cats_in_camp(camp_name: String) -> Array:
	return camps.get(camp_name, [])

func create_camp(camp_name: String):
	if not camps.has(camp_name):
		camps[camp_name] = []
		print("Created new camp: ", camp_name)

func get_all_camps() -> Array:
	return camps.keys()

func get_camp_of_cat(cat_id: int) -> String:
	var cat := get_cat_by_id(cat_id)
	return cat.colony if cat else ""

func spawn_camp(camp_name: String, position: Vector2 = Vector2.ZERO) -> Node:
	if not camp_holder:
		push_error("No camp holder assigned!")
		return null
	
	if not camps_scene:
		push_error("No camps scene assigned!")
		return null
	
	var all_camps_instance := camps_scene.instantiate()
	var target_camp := all_camps_instance.get_node_or_null(camp_name)
	
	if not target_camp:
		push_error("Camp not found: ", camp_name)
		all_camps_instance.queue_free()
		return null
	
	var new_camp := target_camp.duplicate()
	camp_holder.add_child(new_camp)
	new_camp.position = position
	
	_hide_spawn_area(new_camp)
	all_camps_instance.queue_free()
	
	print("✅ Camp spawned: ", new_camp.name)
	return new_camp

func _hide_spawn_area(camp: Node):
	var spawn_area := camp.get_node_or_null("SpawnArea") as Polygon2D
	if spawn_area:
		spawn_area.visible = false
		print("✅ SpawnArea hidden")
	else:
		print("⚠️  No SpawnArea found in spawned camp")

func transfer_cat(cat_id: int, from_camp: String, to_camp: String):
	var cat := get_cat_by_id(cat_id)
	if not cat or not camps.has(from_camp) or not camps.has(to_camp) or not cat in camps[from_camp]:
		return
	
	camps[from_camp].erase(cat)
	camps[to_camp].append(cat)
	cat.colony = to_camp
	
	var old_camp := camp_holder.get_node_or_null(from_camp)
	var new_camp := camp_holder.get_node_or_null(to_camp)
	
	if old_camp and new_camp and old_camp != new_camp:
		old_camp.remove_child(cat)
		new_camp.add_child(cat)
		cat.position = get_random_position(to_camp)
	
	print("Transferred cat ", cat_id, " from ", from_camp, " to ", to_camp)

func switch_current_camp(camp_name: String):
	for camp in camp_holder.get_children():
		camp.visible = false
		camp.process_mode = Node.PROCESS_MODE_DISABLED
	
	var target_camp := camp_holder.get_node_or_null(camp_name)
	if target_camp:
		target_camp.visible = true
		target_camp.process_mode = Node.PROCESS_MODE_INHERIT
		print("✅ Switched to camp: ", camp_name)
	else:
		print("❌ Camp not found: ", camp_name)
#endregion

#region Cat Management
func _on_cat_clicked(cat: Cat) -> void:
	print("CatManager received click for: ", cat.nick)
	SceneManager.open_cat_page(cat, cat_scene)

func age_all_cats(months: int = 1) -> void:
	for cat in all_cats:
		if cat and is_instance_valid(cat):
			print("Aging cat: ", cat.nick, " from ", cat.age_months, " months")
			cat.age_up(months)

func remove_cat(cat: Node) -> void:
	if cat and cat in all_cats:
		all_cats.erase(cat)
		if is_instance_valid(cat):
			cat.queue_free()

func get_cat_by_id(id: int) -> Cat:
	for cat in all_cats:
		if cat.id == id:
			return cat
	return null

func get_all_cat_ids() -> Array:
	return all_cats.map(func(cat): return cat.id)

func print_cat_ids() -> void:
	print("All cat IDs: ", get_all_cat_ids())
#endregion

#region Stat Generation
func _generate_stats_and_abilities(cat: Cat):
	_assign_base_stats(cat)
	_assign_core_ability(cat)
	_apply_core_bonuses(cat)
	_determine_class(cat)

func _assign_base_stats(cat: Cat):
	var stat_array = [15, 14, 13, 12, 10, 8]
	stat_array.shuffle()
	
	var stat_keys = Cat.StatType.values()
	for i in range(stat_keys.size()):
		cat.stats[stat_keys[i]] = stat_array[i]

func _assign_core_ability(cat: Cat):
	var cores = Cat.CoreAbility.values()
	cat.core_ability = cores[randi() % cores.size()]

func _apply_core_bonuses(cat: Cat):
	match cat.core_ability:
		Cat.CoreAbility.SOMATA:
			cat.stats[Cat.StatType.POWER] += 2
			cat.stats[Cat.StatType.ENDURANCE] += 2
		Cat.CoreAbility.ENERRA:
			cat.stats[Cat.StatType.POWER] += 2
			cat.stats[Cat.StatType.SPIRIT] += 2
		Cat.CoreAbility.CHIVARIA:
			cat.stats[Cat.StatType.AGILITY] += 2
			cat.stats[Cat.StatType.CHARM] += 2
		Cat.CoreAbility.PSYCONA:
			cat.stats[Cat.StatType.MIND] += 2
			cat.stats[Cat.StatType.SPIRIT] += 2
		Cat.CoreAbility.ARCANIA:
			# Random stat bonus for Arcania
			var random_stat = Cat.StatType.values()[randi() % Cat.StatType.size()]
			cat.stats[random_stat] += 2
	
	# Cap stats at 20
	for stat in cat.stats:
		cat.stats[stat] = min(cat.stats[stat], 20)

func _determine_class(cat: Cat):
	var highest_stat = cat.get_highest_stat()
	
	# Exact mapping from your specification
	match highest_stat:
		Cat.StatType.ENDURANCE:
			if cat.core_ability in [Cat.CoreAbility.SOMATA, Cat.CoreAbility.ENERRA]:
				cat.character_class = "Tank"
		
		Cat.StatType.POWER:
			if cat.core_ability in [Cat.CoreAbility.SOMATA, Cat.CoreAbility.ENERRA]:
				cat.character_class = "Bruiser"
		
		Cat.StatType.AGILITY:
			if cat.core_ability in [Cat.CoreAbility.SOMATA, Cat.CoreAbility.CHIVARIA]:
				cat.character_class = "Skirmisher"
			elif cat.core_ability in [Cat.CoreAbility.CHIVARIA, Cat.CoreAbility.PSYCONA]:
				cat.character_class = "Skulker"
			elif cat.core_ability == Cat.CoreAbility.ENERRA:
				cat.character_class = "Ranger"
		
		Cat.StatType.MIND:
			if cat.core_ability == Cat.CoreAbility.ENERRA:
				cat.character_class = "Ranger"
			elif cat.core_ability in [Cat.CoreAbility.PSYCONA, Cat.CoreAbility.ARCANIA]:
				cat.character_class = "Supporter"
		
		Cat.StatType.SPIRIT:
			if cat.core_ability in [Cat.CoreAbility.PSYCONA, Cat.CoreAbility.ARCANIA]:
				cat.character_class = "Supporter"
		
		Cat.StatType.CHARM:
			if cat.core_ability in [Cat.CoreAbility.CHIVARIA, Cat.CoreAbility.PSYCONA]:
				cat.character_class = "Skulker"
			elif cat.core_ability in [Cat.CoreAbility.PSYCONA, Cat.CoreAbility.ARCANIA]:
				cat.character_class = "Supporter" 
	
	if cat.character_class.is_empty():
		cat.character_class = "Allrounder"

	_add_core_proficiency(cat)

func _add_core_proficiency(cat: Cat):
	var core_skills = {
		Cat.CoreAbility.SOMATA: ["athletics", "intimidation", "survival"],
		Cat.CoreAbility.ENERRA: ["investigation", "nature", "medicine"],
		Cat.CoreAbility.CHIVARIA: ["acrobatics", "sleight_of_paw", "stealth"],
		Cat.CoreAbility.PSYCONA: ["insight", "persuasion", "medicine"],
		Cat.CoreAbility.ARCANIA: ["deception", "religion", "investigation"]
	}
	
	if core_skills.has(cat.core_ability) and randf() < 0.5:
		var available_skills = core_skills[cat.core_ability]
		cat.proficiencies.append(available_skills[randi() % available_skills.size()])
#endregion

#region Debug
func _debug_camp_situation(camp_name: String):
	print("=== CAMP DEBUG ===")
	print("Requested camp: ", camp_name)
	print("Camps in holder: ", camp_holder.get_child_count())
	
	for camp in camp_holder.get_children():
		print("  - Camp: ", camp.name)
		var spawn_area := camp.get_node_or_null("SpawnArea") as Polygon2D
		if spawn_area:
			print("    SpawnArea: ", spawn_area.polygon.size(), " points | Visible: ", spawn_area.visible)
		else:
			print("    No SpawnArea!")
	
	print("Cats and their colonies:")
	for cat in all_cats:
		print("  - ", cat.nick, " -> ", cat.colony)
	
	print("=== END DEBUG ===")

func debug_print_cat_stats(cat_id: int):
	var cat = get_cat_by_id(cat_id)
	if cat:
		cat.print_stats()
	else:
		print("Cat not found with ID: ", cat_id)

func debug_all_cats_stats():
	for cat in all_cats:
		if cat and is_instance_valid(cat):
			cat.print_stats()
#endregion
