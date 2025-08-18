extends Control

# Node references
@onready var cat_container = $Background/CatDisplay
@onready var name_label = $Background/Name
@onready var age_label = $Background/AppInfoContainer/AppearanceInfo/Age
@onready var coat_label = $Background/AppInfoContainer/AppearanceInfo/Fur
@onready var eyes_label = $Background/AppInfoContainer/AppearanceInfo/Eyes
@onready var gender_label = $Background/PsychInfoContainer/PsychologyInfo/Gender
@onready var back_button = $BackButton

func _ready():
		# Debug node connections
	print("Back button connected: ", back_button.pressed.connect(_on_BackButton_pressed) == OK)
	
	hide()

func show_cat(cat):
	print_debug("Attempting to show cat: ", cat.name if "name" in cat else "unnamed")
	
	# Clear previous cat
	for child in cat_container.get_children():
		child.queue_free()
	
	# Add new cat instance
	var cat_copy = cat.duplicate()
	cat_container.add_child(cat_copy)
	cat_copy.position = cat_container.size / 2
	cat_copy.scale = Vector2(2, 2)
	
	# Update info display
	_update_info(cat)
	show()
	print_debug("Cat page shown for: ", cat.nick)

func _update_info(cat):
	name_label.text = str(cat.nick)
	age_label.text = "%s month old %s" % [cat.age_months, cat.life_stage]
	coat_label.text = "%s %s coat" % [cat.fur_length, cat.base_color]
	eyes_label.text = "%s eyes" % cat.eye_color
	gender_label.text = "of the %s" % cat.gender

func _on_BackButton_pressed():
	print_debug("Back button pressed")
	queue_free()
