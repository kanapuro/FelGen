extends Control
class_name DebugButtons

# Button references - assign these in the inspector
@export var timeskip_button: Button
@export var spawncat_button: Button
@export var dialoguetester_button: Button

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

func _on_spawncat_pressed():
	print("SpawnCat pressed - spawning cat in random camp")
	var all_camps = get_tree().get_nodes_in_group("camps")
	
	if all_camps.is_empty():
		push_warning("No camps found!")
		return
	
	# Pick a random camp
	var random_camp = all_camps[randi() % all_camps.size()]
	
	if random_camp.has_node("CatManager"):
		var cat_manager = random_camp.get_node("CatManager") as CatManager
		cat_manager.spawn_cat("", "", random_camp.name)
		print("Spawned new cat in camp: ", random_camp.name)

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
