extends Control

# Node references - REMOVE @onready since we're not in a scene
var cat_container: Control
var name_label: Label
var age_label: Label
var coat_label: Label
var eyes_label: Label
var gender_label: Label
var back_button: Button
var id_label: Label

func _ready():
	# Get nodes manually since we can't use $ notation
	cat_container = get_node("Background/CatDisplay")
	name_label = get_node("Background/Name")
	id_label = get_node("Background/ID")
	age_label = get_node("Background/AppInfoContainer/AppearanceInfo/Age")
	coat_label = get_node("Background/AppInfoContainer/AppearanceInfo/Fur")
	eyes_label = get_node("Background/AppInfoContainer/AppearanceInfo/Eyes")
	gender_label = get_node("Background/PsychInfoContainer/PsychologyInfo/Gender")
	back_button = get_node("BackButton")
	
	# Debug node connections
	print("Back button connected: ", back_button.pressed.connect(_on_BackButton_pressed) == OK)
	
	hide()

func show_cat(cat, cat_scene: PackedScene):  # Add parameter here
	print_debug("Attempting to show cat: ", cat.nick)
	
	# Clear previous cat
	for child in cat_container.get_children():
		child.queue_free()
	
	# REMOVE the cat_manager line - use the passed cat_scene directly
	var cat_copy = cat_scene.instantiate() as Cat  # Use the parameter
	cat_copy.set_data_from(cat)
	cat_container.add_child(cat_copy)
	cat_copy.position = cat_container.size / 2
	cat_copy.scale = Vector2(2, 2)
	
	# Update info display
	_update_info(cat)
	show()
	print_debug("Cat page shown for: ", cat.nick)

func _update_info(cat):
	name_label.text = str(cat.nick)
	age_label.text = "%s semester old %s" % [cat.age_months, cat.life_stage]
	id_label.text = "ID:%s" % cat.id # format = ID:123
	
	# Updated coat description
	if cat.dilution == "none":
		coat_label.text = "%s %s coat" % [cat.fur_length, cat.base_color]
	else:
		coat_label.text = "%s %s coat with %s dilution" % [cat.fur_length, cat.base_color, cat.dilution]
	
	eyes_label.text = "%s eyes" % cat.eye_color
	gender_label.text = "of the %s" % cat.gender

func _on_BackButton_pressed():
	print_debug("Back button pressed")
	queue_free()
