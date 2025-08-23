extends Control
class_name CatPage

#region Node References
@onready var cat_container: Control = $Background/CatDisplay
@onready var name_label: Label = $Background/Name
@onready var id_label: Label = $Background/ID
@onready var age_label: Label = $Background/AppInfoContainer/AppearanceInfo/Age
@onready var coat_label: Label = $Background/AppInfoContainer/AppearanceInfo/Fur
@onready var eyes_label: Label = $Background/AppInfoContainer/AppearanceInfo/Eyes
@onready var gender_label: Label = $Background/PsychInfoContainer/PsychologyInfo/Gender
#endregion

#region Constants
const CAT_SCALE := Vector2(2, 2)
#endregion

#region Lifecycle
func _ready():
	hide()

func show_cat(cat: Cat, cat_scene: PackedScene):
	print_debug("Attempting to show cat: ", cat.nick)
	
	_clear_previous_cat()
	_create_cat_display(cat, cat_scene)
	_update_info_display(cat)
	show()
	
	print_debug("Cat page shown for: ", cat.nick)
#endregion

#region Cat Display
func _clear_previous_cat():
	for child in cat_container.get_children():
		child.queue_free()

func _create_cat_display(cat: Cat, cat_scene: PackedScene):
	var cat_copy := cat_scene.instantiate() as Cat
	cat_copy.set_data_from(cat)
	cat_container.add_child(cat_copy)
	
	# Position and scale the cat display
	cat_copy.position = cat_container.size / 2
	cat_copy.scale = CAT_SCALE
#endregion

#region Info Display
func _update_info_display(cat: Cat):
	_update_basic_info(cat)
	_update_appearance_info(cat)
	_update_eyes_info(cat)
	_update_gender_info(cat)

func _update_basic_info(cat: Cat):
	name_label.text = str(cat.nick)
	id_label.text = "ID:%s" % cat.id
	age_label.text = "%s semester old %s" % [cat.age_months, cat.life_stage]

func _update_appearance_info(cat: Cat):
	var coat_text: String
	if cat.dilution == "none":
		coat_text = "%s %s %s coat" % [cat.fur_length, cat.base_color, cat.base_pattern]
	else:
		coat_text = "%s %s %s coat with %s dilution" % [cat.fur_length, cat.base_color, cat.base_pattern, cat.dilution]
	coat_label.text = coat_text

func _update_eyes_info(cat: Cat):
	var eyes_text: String
	if cat.eye_pattern == "default":
		eyes_text = "%s eyes" % cat.eye_color
	else:
		eyes_text = "%s %s eyes" % [cat.eye_pattern, cat.eye_color]
	eyes_label.text = eyes_text

func _update_gender_info(cat: Cat):
	gender_label.text = "of the %s" % cat.gender
#endregion
