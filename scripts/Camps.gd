extends Control
class_name Camps

@onready var cat_manager = get_tree().get_first_node_in_group("cat_managers") as CatManager

func _ready():
	add_to_group("camps")
	
	print("Camp '", name, "' added to groups: ", get_groups())
	
	# Check if SpawnArea exists
	var spawn_area = get_node_or_null("SpawnArea") as Polygon2D
	if spawn_area:
		spawn_area.visible = false  # Ensure it's always hidden
		print("SpawnArea hidden in: ", name)

func spawn_cat_in_camp(camp_name: String, nick: String = "Unnamed", gender: String = "unknown"):
	if cat_manager:
		cat_manager.spawn_cat(camp_name, nick, gender)
	else:
		push_error("CatManager node not found in camp!")

func time_skip(months: int = 1):
	if cat_manager:
		cat_manager.age_all_cats(months)

func initialize_camp(camp_name: String):
	name = camp_name  # Set the actual node name
