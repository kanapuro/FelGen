extends Node2D
class_name Cat

# Core traits
var nick: String = ""
var gender: String = ""
var colony: String = ""
var age_months: int = 0
var life_stage: String = "bairn"
var fur_length: String = "short"

# Visual traits
var base_color: String = ""
var eye_color: String = ""

# Temporary data
var current_pose_set: Dictionary = {}

signal clicked(cat)

@onready var pose_sprite: Sprite2D = $Pose
@onready var base_sprite: Sprite2D = $Base
@onready var eyes_sprite: Sprite2D = $Eyes
@onready var click_area: Area2D = $ClickArea

func _ready():
	initialize_colors()
	update_sprites()
	if click_area:
		click_area.input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked", self)

func initialize_colors():
	if base_color.is_empty() or eye_color.is_empty():  # FIXED: Changed empty() to is_empty()
		randomize_colors()

func randomize_colors():
	var pose_data = get_random_pose()
	if pose_data.has("base") and pose_data.has("eyes"):
		base_color = pose_data["base"].keys()[0]
		eye_color = pose_data["eyes"].keys()[0]

func get_random_pose() -> Dictionary:
	var pose_key = "short" if life_stage == "bairn" else fur_length
	if Traits.POSES.has(life_stage) and Traits.POSES[life_stage].has(pose_key):
		var pose_list = Traits.POSES[life_stage][pose_key]
		if pose_list.size() > 0:
			return pose_list[randi() % pose_list.size()]
	return {}

func compute_life_stage():
	var previous_stage = life_stage
	if age_months < 6:
		life_stage = "bairn"
	elif age_months < 12:
		life_stage = "juvenile"
	elif age_months < 60:
		life_stage = "adult"
	else:
		life_stage = "senior"
	
	if previous_stage != life_stage:
		update_pose()

func update_pose():
	current_pose_set = get_random_pose()
	update_sprites()

func update_sprites():
	if current_pose_set.is_empty():
		return
	
	if pose_sprite and current_pose_set.has("pose"):
		pose_sprite.texture = load(current_pose_set["pose"])
	
	if base_sprite and current_pose_set.has("base"):
		base_sprite.texture = load(current_pose_set["base"][base_color])
	
	if eyes_sprite and current_pose_set.has("eyes"):
		eyes_sprite.texture = load(current_pose_set["eyes"][eye_color])

func age_up(months: int = 1):
	age_months += months
	compute_life_stage()

func set_data_from(other_cat):
	nick = other_cat.nick
	age_months = other_cat.age_months
	life_stage = other_cat.life_stage
	fur_length = other_cat.fur_length
	base_color = other_cat.base_color
	eye_color = other_cat.eye_color
	gender = other_cat.gender
