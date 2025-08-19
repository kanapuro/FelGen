extends Node2D
class_name Cat

# Core traits
var nick: String = ""
var gender: String = ""
var colony: String = ""
var age_months: int = 0
var life_stage: String = ""
var fur_length: String = ""
var dilution: String = ""

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
		print("ClickArea found: ", click_area.name)
		var connect_result = click_area.input_event.connect(_on_input_event)
		print("Signal connection result: ", connect_result)
	else:
		print("ClickArea is null!")

func _on_input_event(_viewport, event, _shape_idx):
	print("Input event received: ", event)
	if event is InputEventMouseButton:
		print("Mouse button: ", event.pressed, " button: ", event.button_index)
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Emitting clicked signal")
			emit_signal("clicked", self)

func initialize_colors():
	# Set default colors if empty
	if base_color.is_empty():
		base_color = "white"
	if eye_color.is_empty():
		eye_color = "error"
	if dilution.is_empty(): 
		dilution = "none"

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
	print("Selected pose set: ", current_pose_set)
	update_sprites()

func get_random_pose() -> Dictionary:
	var pose_key = "short" if life_stage == "bairn" else fur_length
	print("Looking for pose: ", life_stage, "/", pose_key)
	
	if Traits.POSES.has(life_stage) and Traits.POSES[life_stage].has(pose_key):
		var pose_list = Traits.POSES[life_stage][pose_key]
		print("Found ", pose_list.size(), " poses")
		if pose_list.size() > 0:
			return pose_list[randi() % pose_list.size()]
	
	print("ERROR: No poses found for ", life_stage, "/", pose_key)
	return {}

func update_sprites():
	if current_pose_set.is_empty():
		# Try one more time before warning
		current_pose_set = get_random_pose()
		if current_pose_set.is_empty():
			# Add helpful debug info
			push_warning("No pose set for cat %s (Stage: %s, Fur: %s)" % [nick, life_stage, fur_length])
			return
		else:
			# Optional: log successful recovery
			print("Pose recovered for: ", nick)
	
	# Load pose sprite
	if pose_sprite and current_pose_set.has("pose"):
		pose_sprite.texture = load(current_pose_set["pose"])
	
		# Load base texture and apply color modulation
	if base_sprite and current_pose_set.has("base"):
		var base_texture_path = current_pose_set["base"].get("solid", "")
		if base_texture_path:
			base_sprite.texture = load(base_texture_path)
			
			# FIX: REPLACE instead of multiply colors
			if dilution != "none" and dilution != "":
				var dilution_data = Traits.DILUTIONS.get(dilution, {})
				if dilution_data.has(base_color):
					# REPLACE with dilution color (don't multiply)
					base_sprite.modulate = Color(dilution_data[base_color].modulate)
				else:
					# Fallback to base color if no dilution found
					var color_data = Traits.COLORS.get(base_color, {"modulate": "#ffffff"})
					base_sprite.modulate = Color(color_data.modulate)
			else:
				# No dilution - use base color
				var color_data = Traits.COLORS.get(base_color, {"modulate": "#ffffff"})
				base_sprite.modulate = Color(color_data.modulate)
			
		else:
			push_warning("No solid base texture found in pose data")
	
	# Load eye texture
	if eyes_sprite and current_pose_set.has("eyes"):
		var eye_texture_path = current_pose_set["eyes"].get(eye_color, "")
		if eye_texture_path:
			eyes_sprite.texture = load(eye_texture_path)
		else:
			push_warning("No eye texture found for: ", eye_color)

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
	dilution = other_cat.dilution
	gender = other_cat.gender
	current_pose_set = other_cat.current_pose_set.duplicate(true)  # deep copy
	
	update_sprites() 
