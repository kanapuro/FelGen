extends Node2D
class_name Cat

# Core traits
var id: int = -1 # unassigned id
var nick: String = ""
var gender: String = ""
var colony: String = ""
var age_months: int = 0
var life_stage: String = ""
var fur_length: String = ""
var dilution: String = ""

# Visual traits
var base_color: String = ""
var base_pattern: String = ""
var eye_color: String = ""

# Temporary data
var current_pose_set: Dictionary = {}

signal clicked(cat)

var pose_sprite: Sprite2D
var base_sprite: Sprite2D
var eyes_sprite: Sprite2D
var click_area: Area2D

func _ready():
	pose_sprite = get_node_or_null("Pose")
	base_sprite = get_node_or_null("Base")
	eyes_sprite = get_node_or_null("Eyes")
	click_area = get_node_or_null("ClickArea")
	
	if not pose_sprite or not base_sprite or not eyes_sprite:
		push_error("Missing required sprite nodes in Cat scene!")
		return
	
	initialize_colors()
	update_sprites()
	
	if click_area:
		# Make sure it's not disabled
		click_area.input_event.connect(_on_input_event)
		click_area.input_pickable = true  # Ensure it can receive input
		#print("ClickArea setup complete for cat: ", nick)
	else:
		push_error("No ClickArea found for cat: ", nick)
	
	initialize_colors()
	update_sprites()
func _on_input_event(_viewport, event, _shape_idx):
	#print("Input event received: ", event)
	if event is InputEventMouseButton:
		#print("Mouse button: ", event.pressed, " button: ", event.button_index)
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			#print("Emitting clicked signal")
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
	#print("Looking for pose: ", life_stage, "/", pose_key)
	
	if Traits.POSES.has(life_stage) and Traits.POSES[life_stage].has(pose_key):
		var pose_list = Traits.POSES[life_stage][pose_key]
		#print("Found ", pose_list.size(), " poses")
		if pose_list.size() > 0:
			return pose_list[randi() % pose_list.size()]
	
	print("ERROR: No poses found for ", life_stage, "/", pose_key)
	return {}

func update_sprites():
	if current_pose_set.is_empty():
		current_pose_set = get_random_pose()
		if current_pose_set.is_empty():
			push_warning("No pose set for cat %s (Stage: %s, Fur: %s)" % [nick, life_stage, fur_length])
			return
	
	# Load pose sprite
	if pose_sprite and current_pose_set.has("pose"):
		pose_sprite.texture = ResourceLoader.load(current_pose_set["pose"])
	
	# Load base texture and apply color modulation (unchanged)
	if base_sprite and current_pose_set.has("base"):
		var base_texture_path = current_pose_set["base"].get("solid", "")
		if base_texture_path:
			base_sprite.texture = ResourceLoader.load(base_texture_path)
			
			var color_data = Traits.COLORS.get(base_color, {"modulate": "#ffffff"})
			base_sprite.modulate = Color(color_data.modulate)
			
			if dilution != "none" and dilution != "":
				var dilution_data = Traits.DILUTIONS.get(dilution, {})
				if dilution_data.has(base_color):
					base_sprite.modulate = Color(dilution_data[base_color].modulate)
	
	# Load eye texture and apply color modulation (NEW SYSTEM)
	if eyes_sprite and current_pose_set.has("eyes"):
		var eye_texture_path = current_pose_set["eyes"].get("default", "")
		if eye_texture_path:
			eyes_sprite.texture = ResourceLoader.load(eye_texture_path)
			
			# Apply eye color modulation (like base colors)
			var eye_color_data = Traits.EYE_COLORS.get(eye_color, {"modulate": "#ffffff"})
			eyes_sprite.modulate = Color(eye_color_data.modulate)
			
		else:
			push_warning("No default eye texture found in pose data")

func age_up(months: int = 1):
	age_months += months
	compute_life_stage()

func set_data_from(other_cat):
	id = other_cat.id
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
