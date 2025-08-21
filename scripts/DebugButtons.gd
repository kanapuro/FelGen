extends Control
class_name DebugButtons

# Button references - assign these in the inspector
@export var timeskip_button: Button
@export var spawncat_button: Button
@export var dialoguetester_button: Button
@export var spawncamp_button: Button

# Timeskip settings
@export var spawn_chance: float = 1.0

func _ready():
	# Connect buttons if they exist
	if timeskip_button:
		timeskip_button.pressed.connect(_on_timeskip_pressed)
	if spawncat_button:
		spawncat_button.pressed.connect(_on_spawncat_pressed)
	if dialoguetester_button:
		dialoguetester_button.pressed.connect(_on_dialoguetester_pressed)

func _on_timeskip_pressed():
	print("Timeskip pressed - skipping 1 month")
	
	var cat_managers = get_tree().get_nodes_in_group("cat_managers")
	if cat_managers.is_empty():
		push_warning("No CatManager found!")
		return
	
	var cat_manager = cat_managers[0] as CatManager
	cat_manager.age_all_cats(1)  # Skip 1 month
	
	# Reposition all cats in their respective camps WITH PADDING
	for camp_name in cat_manager.camps:
		var cats_in_camp = cat_manager.get_cats_in_camp(camp_name)
		for cat in cats_in_camp:
			if cat and is_instance_valid(cat):
				# Use the camp-aware positioning WITH padding
				cat.position = cat_manager.get_random_position(camp_name, 100, 30.0)  # ← Ensure padding is used
				print("Repositioned cat in camp: ", camp_name)

func _on_spawncat_pressed():
	print("SpawnCat pressed - spawning cat in random camp")
	
	var cat_managers = get_tree().get_nodes_in_group("cat_managers")
	if cat_managers.is_empty():
		push_warning("No CatManager found!")
		return
	
	var cat_manager = cat_managers[0] as CatManager
	
	# FIX: Get camps from camp_holder, not from the "camps" group!
	var spawned_camps = cat_manager.camp_holder.get_children()
	if spawned_camps.is_empty():
		push_warning("No camps spawned in camp_holder! Spawn a camp first.")
		return
	
	# Pick a random camp from the ACTUAL spawned camps
	var random_camp = spawned_camps[randi() % spawned_camps.size()]
	print("Selected camp: '", random_camp.name, "'")
	
	# Spawn cat in the selected camp
	cat_manager.spawn_cat(random_camp.name)

func _on_test_spawnareas_pressed():
	print("=== TESTING SPAWNAREAS ===")
	
	var cat_managers = get_tree().get_nodes_in_group("cat_managers")
	if cat_managers.is_empty():
		return
	
	var cat_manager = cat_managers[0] as CatManager
	
	# Check all spawned camps
	for camp in cat_manager.camp_holder.get_children():
		print("Camp: ", camp.name)
		var spawn_area = camp.get_node_or_null("SpawnArea") as Polygon2D
		if spawn_area:
			print("  - SpawnArea: ", spawn_area.polygon.size(), " points | Visible: ", spawn_area.visible)
			# Test if a position can be generated
			var test_pos = cat_manager.get_random_position_in_polygon(spawn_area.polygon, spawn_area.global_position)
			print("  - Test position: ", test_pos)
		else:
			print("  - No SpawnArea found!")
	
	print("=== END TEST ===")

# script for camp switching mechanic
func _on_switchcamp_pressed():
	print("Switch Camp pressed")
	
	var cat_managers = get_tree().get_nodes_in_group("cat_managers")
	if cat_managers.is_empty():
		return
	
	var cat_manager = cat_managers[0] as CatManager
	
	# Get available camps
	var available_camps = []
	for camp in cat_manager.camp_holder.get_children():
		available_camps.append(camp.name)
	
	if available_camps.is_empty():
		print("No camps available to switch to")
		return
	
	# Switch to a random camp
	var random_camp = available_camps[randi() % available_camps.size()]
	cat_manager.switch_current_camp(random_camp)

func _on_dialoguetester_pressed():
	print("DialogueTester pressed - running dialogue tests")
	var template = "{{subj}} {{verb:go}} hunting and {{subj}} {{verb:find}} a rabbit. {{subj}} {{verb:eat}} it quickly."

	var dialogue_veil = Traits.fill_dialogue(template, "veil")
	print("Veil: ", dialogue_veil)
	
	var dialogue_bloom = Traits.fill_dialogue(template, "bloom")
	print("Bloom: ", dialogue_bloom)
	
	var dialogue_stone = Traits.fill_dialogue(template, "stone")
	print("Stone: ", dialogue_stone)
	
	var dialogue_solstice = Traits.fill_dialogue(template, "solstice")
	print("Solstice: ", dialogue_solstice)
	
	var dialogue_cinders = Traits.fill_dialogue(template, "cinders")
	print("Cinders: ", dialogue_cinders)
	
	var dialogue_ashes = Traits.fill_dialogue(template, "ashes")
	print("Ashes: ", dialogue_ashes)


# extra code concepts

# Example Cat class (or whatever your character object is)
#class_name Cat
#var nick: String = "Fenn"
#var gender: String = "stone" # could be "veil", "stone", "flame"
#
#func _pressed():
	#var template = "{{subj}} {{verb:go}} hunting and {{subj}} {{verb:find}} a rabbit. {{subj}} {{verb:eat}} it quickly."
#
	## Pick a character (replace this with your actual character reference)
	#var referred_cat = Cat.new()
	#referred_cat.gender = "stone" # dynamically set based on the cat involved
#
	## Use the cat's gender
	#var dialogue = Traits.fill_dialogue(template, referred_cat.gender)
	#print(dialogue)
	## Output: "He goes hunting and he finds a rabbit. He eats it quickly."

# or pick random

#var cats = [cat1, cat2, cat3]
#var referred_cat = cats[randi() % cats.size()]
#var dialogue = Traits.fill_dialogue(template, referred_cat.gender)
#print(dialogue)


#KITTEN MAKER
#func create_kitten(parent: Cat) -> Cat:
	#var kitten = duplicate()
	#kitten.base_color = pick_genetic_color(base_color, parent.base_color)
	#kitten.eye_color = pick_genetic_color(eye_color, parent.eye_color)
	#return kitten
