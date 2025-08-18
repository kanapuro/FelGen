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

func get_random_position() -> Vector2:
	var vp = get_viewport()
	if vp == null:
		return Vector2.ZERO

	var size = vp.get_visible_rect().size
	var extra_padding := 25.0
	var top_buffer := 80.0
	var tries := 0

	while tries < 64:
		var pos = Vector2(
			randf_range(spawn_padding + extra_padding, size.x - spawn_padding - extra_padding),
			randf_range(spawn_padding + extra_padding + top_buffer, size.y - spawn_padding - extra_padding)
		)
		var valid = true
		for c in cats:
			if c and is_instance_valid(c) and c.position.distance_to(pos) < spawn_padding + extra_padding:
				valid = false
				break
		if valid:
			return pos
		tries += 1
	return Vector2.ZERO

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
