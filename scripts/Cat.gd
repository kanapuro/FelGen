extends Node2D
class_name Cat

#region Signals
signal clicked(cat)
#endregion

#region Enums
enum LifeStage { BAIRN, JUVENILE, ADULT, SENIOR }
enum CoreAbility { SOMATA, ENERRA, CHIVARIA, PSYCONA, ARCANIA }
enum StatType { POWER, AGILITY, ENDURANCE, MIND, SPIRIT, CHARM }
#endregion

#region Node References
@onready var pose_sprite: Sprite2D = $Pose
@onready var base_sprite: Sprite2D = $Base
@onready var eyes_sprite: Sprite2D = $Eyes
@onready var click_area: Area2D = $ClickArea
#endregion

#region Core Traits
var id: int = -1
var nick: String = ""
var gender: String = ""
var colony: String = ""
var age_months: int = 0
var life_stage: String = ""
var fur_length: String = ""
var dilution: String = ""

var stats: Dictionary = {
	StatType.POWER: 0,
	StatType.AGILITY: 0,
	StatType.ENDURANCE: 0,
	StatType.MIND: 0,
	StatType.SPIRIT: 0,
	StatType.CHARM: 0
}
var core_ability: CoreAbility = CoreAbility.SOMATA
var character_class: String = ""
var xp: int = 0
var level: int = 1
var proficiencies: Array = []
#endregion

#region Visual Traits
var base_color: String = ""
var base_pattern: String = ""
var eye_color: String = ""
var eye_pattern: String = ""
#endregion

#region Pose System
var pose_storage: Dictionary = {
	"bairn": {}, "juvenile": {}, "adult": {}, "senior": {}
}
var current_pose_id: String = ""
var current_pose_set: Dictionary = {}
#endregion

#region Drag System
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_z_index: int = 0
static var current_drag_z_index: int = 100
#endregion

#region Lifecycle
func _ready():
	_validate_required_nodes()
	_initialize_cat()
	_setup_input_handling()

func _process(_delta):
	_handle_dragging()

func _validate_required_nodes():
	if not pose_sprite or not base_sprite or not eyes_sprite:
		push_error("Missing required sprite nodes in Cat scene!")
		set_process(false)

func _initialize_cat():
	set_process(true)
	initialize_colors()
	update_sprites()

func _setup_input_handling():
	if click_area:
		click_area.input_event.connect(_on_input_event)
		click_area.input_pickable = true
	else:
		push_error("No ClickArea found for cat: ", nick)
#endregion

#region Input Handling
func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if not event is InputEventMouseButton:
		return
	
	if event.button_index == MOUSE_BUTTON_RIGHT:
		_handle_right_click(event)
	elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_left_click()

func _handle_right_click(event: InputEventMouseButton):
	if event.pressed:
		_start_dragging()
	else:
		_stop_dragging()
	get_viewport().set_input_as_handled()

func _handle_left_click():
	emit_signal("clicked", self)
	get_viewport().set_input_as_handled()

func _start_dragging():
	is_dragging = true
	drag_offset = position - get_global_mouse_position()
	
	original_z_index = z_index
	current_drag_z_index += 1
	z_index = current_drag_z_index
	
	modulate.a = 0.8

func _stop_dragging():
	is_dragging = false
	
	z_index = original_z_index
	modulate.a = 1.0

func _handle_dragging():
	if is_dragging:
		position = get_global_mouse_position() + drag_offset - get_parent().global_position
#endregion

#region Color Management
func initialize_colors():
	if base_color.is_empty(): base_color = "white"
	if eye_color.is_empty(): eye_color = "error"
	if dilution.is_empty(): dilution = "none"
#endregion

#region Life Stage Management
func compute_life_stage():
	var previous_stage = life_stage
	
	if age_months < 6: life_stage = "bairn"
	elif age_months < 12: life_stage = "juvenile"
	elif age_months < 60: life_stage = "adult"
	else: life_stage = "senior"
	
	if previous_stage != life_stage:
		update_pose()

func age_up(months: int = 1):
	age_months += months
	compute_life_stage()
#endregion

#region Pose System
func store_pose_for_stage(stage: String, pose_data: Dictionary):
	pose_storage[stage] = pose_data.duplicate(true)
	print("Stored pose for ", stage, ": ", pose_data.get("id", "unknown"))

func get_stored_pose(stage: String) -> Dictionary:
	return pose_storage.get(stage, {}).duplicate(true)

func has_pose_for_stage(stage: String) -> bool:
	return pose_storage.has(stage) and not pose_storage[stage].is_empty()

func update_pose():
	if has_pose_for_stage(life_stage):
		current_pose_set = get_stored_pose(life_stage)
		current_pose_id = current_pose_set.get("id", "")
		print("Using stored pose for ", life_stage, ": ", current_pose_id)
	else:
		current_pose_set = get_random_pose()
		current_pose_id = current_pose_set.get("id", "")
		print("Selected random pose: ", current_pose_id)
	
	update_sprites()

func get_random_pose(pose_id: String = "") -> Dictionary:
	var pose_key = "short" if life_stage == "bairn" else fur_length
	
	if not Traits.POSES.has(life_stage) or not Traits.POSES[life_stage].has(pose_key):
		push_error("No poses found for %s/%s" % [life_stage, pose_key])
		return {}
	
	var pose_list = Traits.POSES[life_stage][pose_key]
	if pose_list.is_empty():
		return {}
	
	# Find specific pose if requested
	if not pose_id.is_empty():
		for pose in pose_list:
			if pose.get("id", "") == pose_id:
				return pose.duplicate(true)
		return {}
	
	# Return random pose
	return pose_list[randi() % pose_list.size()].duplicate(true)
#endregion

#region Sprite Management
func update_sprites():
	if current_pose_set.is_empty():
		current_pose_set = get_random_pose()
		if current_pose_set.is_empty():
			push_warning("No pose set for cat %s (Stage: %s, Fur: %s)" % [nick, life_stage, fur_length])
			return
	
	_update_pose_sprite()
	_update_base_sprite()
	_update_eyes_sprite()

func _update_pose_sprite():
	if pose_sprite and current_pose_set.has("pose"):
		pose_sprite.texture = ResourceLoader.load(current_pose_set["pose"])

func _update_base_sprite():
	if not base_sprite or not current_pose_set.has("base"):
		return
	
	var base_texture_path = current_pose_set["base"].get(base_pattern, "")
	if not base_texture_path:
		return
	
	base_sprite.texture = ResourceLoader.load(base_texture_path)
	
	# Apply base color and dilution
	var color_data = Traits.COLORS.get(base_color, {"modulate": "#ffffff"})
	base_sprite.modulate = Color(color_data.modulate)
	
	if dilution != "none" and Traits.DILUTIONS.has(dilution):
		var dilution_data = Traits.DILUTIONS[dilution]
		if dilution_data.has(base_color):
			base_sprite.modulate = Color(dilution_data[base_color].modulate)

func _update_eyes_sprite():
	if not eyes_sprite or not current_pose_set.has("eyes"):
		return
	
	var eye_texture_path = current_pose_set["eyes"].get(eye_pattern, "")
	if not eye_texture_path:
		push_warning("No %s eye texture found in pose data" % eye_pattern)
		return
	
	eyes_sprite.texture = ResourceLoader.load(eye_texture_path)
	
	# Apply eye color
	var eye_color_data = Traits.EYE_COLORS.get(eye_color, {"modulate": "#ffffff"})
	eyes_sprite.modulate = Color(eye_color_data.modulate)
#endregion

#region Stat Utilities
func get_stat_modifier(stat: StatType) -> int:
	return floor((stats[stat] - 10) / 2)

func get_highest_stat() -> StatType:
	var highest_value = -1
	var highest_stat = StatType.POWER
	
	for stat in stats:
		if stats[stat] > highest_value:
			highest_value = stats[stat]
			highest_stat = stat
	
	return highest_stat

func get_core_ability_name() -> String:
	return CoreAbility.keys()[core_ability].capitalize()

func print_stats():
	print("=== %s's Stats ===" % nick)
	print("Class: %s" % character_class)
	print("Core: %s" % get_core_ability_name())
	print("Level: %d | XP: %d" % [level, xp])
	for stat in stats:
		print("%s: %d (+%d)" % [StatType.keys()[stat], stats[stat], get_stat_modifier(stat)])
	print("Proficiencies: ", proficiencies)
	
	print("Skill Modifiers:")
	var all_skills = [
		"acrobatics", "athletics", "deception", "insight",
		"intimidation", "investigation", "medicine", "nature",
		"persuasion", "religion", "sleight_of_paw", "stealth", "survival"
	]
	
	for skill in all_skills:
		var modifier = get_skill_modifier(skill)
		var proficiency_indicator = " (P)" if proficiencies.has(skill) else ""
		print("  %s: %+d%s" % [skill, modifier, proficiency_indicator])
#endregion

#region Skill System
func get_skill_modifier(skill: String) -> int:
	var stat_bonus = 0
	
	match skill:
		"acrobatics", "sleight_of_paw", "stealth":
			stat_bonus = get_stat_modifier(StatType.AGILITY)
		"athletics":
			stat_bonus = get_stat_modifier(StatType.POWER)
		"deception", "intimidation", "persuasion":
			stat_bonus = get_stat_modifier(StatType.CHARM)
		"insight":
			stat_bonus = get_stat_modifier(StatType.SPIRIT)
		"investigation", "nature", "religion":
			stat_bonus = get_stat_modifier(StatType.MIND)
		"medicine", "survival":
			stat_bonus = get_stat_modifier(StatType.ENDURANCE)
		_:
			stat_bonus = 0
	
	# Add proficiency bonus if proficient
	var proficiency_bonus = 2 if proficiencies.has(skill) else 0
	
	return stat_bonus + proficiency_bonus

func make_skill_check(skill: String, dc: int = 12) -> Dictionary:
	var valid_skills = [
		"acrobatics", "athletics", "deception", "insight",
		"intimidation", "investigation", "medicine", "nature",
		"persuasion", "religion", "sleight_of_paw", "stealth", "survival"
	]
	
	if not valid_skills.has(skill):
		push_warning("Unknown skill: ", skill)
		return {}
	
	var roll = randi() % 20 + 1
	var total = roll + get_skill_modifier(skill)
	
	return {
		"success": total >= dc or roll == 20,
		"critical_success": roll == 20,
		"critical_failure": roll == 1,
		"roll": roll,
		"modifier": get_skill_modifier(skill) - (2 if proficiencies.has(skill) else 0),
		"proficiency_bonus": 2 if proficiencies.has(skill) else 0,
		"total": total,
		"dc": dc
	}
#endregion

#region Data Management
func set_data_from(other_cat: Cat):
	id = other_cat.id
	nick = other_cat.nick
	age_months = other_cat.age_months
	life_stage = other_cat.life_stage
	fur_length = other_cat.fur_length
	base_color = other_cat.base_color
	base_pattern = other_cat.base_pattern
	eye_color = other_cat.eye_color
	eye_pattern = other_cat.eye_pattern
	dilution = other_cat.dilution
	gender = other_cat.gender
	current_pose_set = other_cat.current_pose_set.duplicate(true)
	current_pose_id = other_cat.current_pose_id
	pose_storage = other_cat.pose_storage.duplicate(true)
	
	update_sprites()
#endregion
