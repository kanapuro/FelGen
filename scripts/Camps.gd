extends Control
class_name Camps

#region Constants
const CAMP_GROUP := "camps"
const CAT_MANAGER_GROUP := "cat_managers"
#endregion

#region Node References
@onready var camp_manager: CatManager = get_tree().get_first_node_in_group(CAT_MANAGER_GROUP)
@onready var spawn_area: Polygon2D = get_node_or_null("SpawnArea")
#endregion

#region Lifecycle
func _ready():
	_initialize_camp()
	_setup_spawn_area()

func _initialize_camp():
	add_to_group(CAMP_GROUP)
	print("Camp '", name, "' added to groups: ", get_groups())

func _setup_spawn_area():
	if spawn_area:
		spawn_area.visible = false
		print("SpawnArea hidden in: ", name)
#endregion

#region Public API
func spawn_cat_in_camp(camp_name: String, nick: String = "Unnamed", gender: String = "unknown") -> void:
	if not camp_manager:
		push_error("CatManager not found in camp '%s'!" % camp_name)
		return
	
	camp_manager.spawn_cat(camp_name, nick, gender)

func time_skip(months: int = 1) -> void:
	if not camp_manager:
		push_error("CatManager not found for time skip!")
		return
	
	camp_manager.age_all_cats(months)

func initialize_camp(camp_name: String) -> void:
	name = camp_name
#endregion
