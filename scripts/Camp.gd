extends Node2D
class_name Camp

@onready var cat_manager = $CatManager  # no type hint

func _ready():
	add_to_group("camps") # dynamic camp management

func spawn_cat_in_camp(nick: String = "Unnamed", gender: String = "unknown", colony: String = "wild"):
	if cat_manager:
		cat_manager.spawn_cat(nick, gender, colony)
	else:
		push_error("CatManager node not found in camp!")

func time_skip(months: int = 1):
	if cat_manager:
		cat_manager.age_all_cats(months)
