extends Button

func _pressed():
	var template = "{{subj}} {{verb:go}} hunting and {{subj}} {{verb:find}} a rabbit. {{subj}} {{verb:eat}} it quickly."

	var dialogue_veil = Traits.fill_dialogue(template, "veil")
	print(dialogue_veil)
	
	var dialogue_bloom = Traits.fill_dialogue(template, "bloom")
	print(dialogue_bloom)
	
	var dialogue_stone = Traits.fill_dialogue(template, "stone")
	print(dialogue_stone)
	
	var dialogue_solstice = Traits.fill_dialogue(template, "solstice")
	print(dialogue_solstice)
	
	var dialogue_cinders = Traits.fill_dialogue(template, "cinders")
	print(dialogue_cinders)
	
	var dialogue_ashes = Traits.fill_dialogue(template, "ashes")
	print(dialogue_ashes)

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
