extends Control
class_name DebugButtons

#region Exports
@export var timeskip_button: Button
@export var spawncat_button: Button
@export var dialoguetester_button: Button
@export var savetest_button: Button
@export var open_save_dir_button: Button

@export var spawn_chance: float = 1.0
@export var timeskip_months: int = 1
@export var reposition_padding: float = 30.0
#endregion

#region Constants
const DIALOGUE_TEMPLATE := "{{subj}} {{verb:go}} hunting and {{subj}} {{verb:find}} a rabbit. {{subj}} {{verb:eat}} it quickly."
#endregion

#region Lifecycle
func _ready():
	_connect_buttons()

func _connect_buttons():
	if timeskip_button:
		timeskip_button.pressed.connect(_on_timeskip_pressed)
	if spawncat_button:
		spawncat_button.pressed.connect(_on_spawncat_pressed)
	if dialoguetester_button:
		dialoguetester_button.pressed.connect(_on_dialoguetester_pressed)
	if savetest_button:  # <- ADD THIS CONNECTION
		savetest_button.pressed.connect(_on_savetest_pressed)
	if open_save_dir_button:
		open_save_dir_button.pressed.connect(_on_open_save_dir_pressed)
#endregion

#region Button Handlers
func _on_timeskip_pressed():
	print("Timeskip pressed - skipping ", timeskip_months, " month(s)")
	_timeskip_all_cats()

func _on_spawncat_pressed():
	print("SpawnCat pressed - spawning cat in random camp")
	_spawn_random_cat()

func _on_dialoguetester_pressed():
	print("DialogueTester pressed - running dialogue tests")
	_test_all_genders_dialogue()

func _on_savetest_pressed():  # <- ADD THIS HANDLER
	print("SaveTest pressed - testing save system")
	_test_save_system()

func _on_open_save_dir_pressed():
	print("📂 Opening save directory...")
	
	var absolute_path = ProjectSettings.globalize_path("user://FelGen/saves/")
	print("📁 Path: ", absolute_path)
	
	OS.shell_open(absolute_path)
	print("✅ Attempted to open save directory")
#endregion

#region Debug Functions
func _timeskip_all_cats():
	var cat_manager := _get_cat_manager()
	if not cat_manager:
		return
	
	cat_manager.age_all_cats(timeskip_months)
	_reposition_all_cats(cat_manager)

func _reposition_all_cats(cat_manager: CatManager):
	for camp_name in cat_manager.camps:
		var cats_in_camp = cat_manager.get_cats_in_camp(camp_name)
		for cat in cats_in_camp:
			if cat and is_instance_valid(cat):
				cat.position = cat_manager.get_random_position(camp_name, 100, reposition_padding)
				print("Repositioned cat in camp: ", camp_name)

func _spawn_random_cat():
	var cat_manager := _get_cat_manager()
	if not cat_manager:
		return
	
	var spawned_camps := cat_manager.camp_holder.get_children()
	if spawned_camps.is_empty():
		push_warning("No camps spawned in camp_holder! Spawn a camp first.")
		return
	
	var random_camp := spawned_camps.pick_random() as Node
	print("Selected camp: '", random_camp.name, "'")
	cat_manager.spawn_cat(random_camp.name)

func _test_all_genders_dialogue():
	var genders := ["veil", "bloom", "stone", "solstice", "cinders", "ashes"]
	
	for gender in genders:
		var dialogue := Traits.fill_dialogue(DIALOGUE_TEMPLATE, gender)
		print(gender.capitalize(), ": ", dialogue)

func _test_save_system():
	print("=== SAVE SYSTEM TEST ===")
	
	# Try multiple ways to find SaveManager
	var save_manager = null
	
	# Method 1: Direct autoload access
	if has_node("/root/SaveManager"):
		save_manager = get_node("/root/SaveManager")
		print("✅ Found via /root/SaveManager")
	
	# Method 2: Search all root children
	if not save_manager:
		for child in get_tree().root.get_children():
			if child is SaveManager:
				save_manager = child
				print("✅ Found SaveManager as root child: ", child.name)
				break
	
	# Method 3: Search entire tree
	if not save_manager:
		var managers = get_tree().get_nodes_in_group("save_managers")
		if not managers.is_empty():
			save_manager = managers[0]
			print("✅ Found via save_managers group")
	
	if not save_manager:
		print("❌ SaveManager not found anywhere!")
		return
	
	print("✅ SaveManager found as autoload!")
	print("🔍 Current world ID: '", save_manager.current_world_id, "'")
	print("🔍 Current world name: '", save_manager.current_world_name, "'")
	
	if save_manager.current_world_id.is_empty():
		print("❌ No active world - create a world first via Start Menu")
		print("💡 Try: 1) Click 'New Game' in Start Menu, 2) Then click SaveTest")
		return
	
	print("Saving world ID: ", save_manager.current_world_id)
	print("World name: ", save_manager.current_world_name)
	
	if save_manager.save_game(save_manager.current_world_name):
		print("✅ World saved successfully!")
		
		var worlds = save_manager.get_saved_games()
		print("📁 Saved worlds: ", worlds.size())
		for world in worlds:
			print("  - ID: %s | Name: %s | %s" % [world.world_id, world.world_name, world.timestamp])
	else:
		print("❌ Save failed!")
	
	print("=== END SAVE TEST ===")

func _test_load_system():
	print("=== LOAD SYSTEM TEST ===")
	
	if not has_node("/root/SaveManager"):
		print("❌ SaveManager not found as autoload!")
		return
	
	var save_manager = get_node("/root/SaveManager") as SaveManager
	
	# List available worlds by ID
	var worlds = save_manager.get_saved_games()
	if worlds.is_empty():
		print("❌ No saved worlds found!")
		return
	
	print("📁 Available worlds (by ID):")
	for i in range(worlds.size()):
		var world = worlds[i]
		print("  [%d] ID: %s | Name: %s" % [i, world.world_id, world.world_name])
	
	# Load by world ID
	var most_recent = worlds[0]
	print("Loading world by ID: ", most_recent.world_id)
	
	if save_manager.load_game(most_recent.world_id):
		print("✅ World loaded successfully!")
		print("Current world ID: ", save_manager.current_world_id)
		print("Current world name: ", save_manager.current_world_name)
	else:
		print("❌ Load failed!")
	
	print("=== END LOAD TEST ===")
#endregion

#region Utilities
func _get_cat_manager() -> CatManager:
	var cat_managers := get_tree().get_nodes_in_group("cat_managers")
	if cat_managers.is_empty():
		push_warning("No CatManager found!")
		return null
	return cat_managers[0] as CatManager
#endregion


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
