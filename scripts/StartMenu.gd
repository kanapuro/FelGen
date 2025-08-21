extends Control
class_name MenuManager

signal menu_item_selected(item_index: int)
static var pending_camp: String = ""
static var pending_position: Vector2 = Vector2.ZERO

# UI Elements - direct references to your scene nodes
@onready var button_backgrounds: Array[TextureRect] = [
	$ButtonContainer/ContinuePlayButton,
	$ButtonContainer/NewPlayButton,
	$ButtonContainer/SettingsButton,
	$ButtonContainer/CreditsButton
]

@onready var labels: Array[Label] = [
	$ButtonContainer/ContinuePlayLabel,
	$ButtonContainer/NewPlayLabel,
	$ButtonContainer/SettingsLabel,
	$ButtonContainer/CreditsLabel
]

@onready var version_label: Label = $VersionLabel

# Contributions window reference
@onready var contributions_window: TextureRect = $Contributions

# Single overlay texture for all buttons
var overlay_texture := load("res://resources/ui/LIGHT/LIGHTgeneralbuttonpressed.png")

# We'll store the created overlays here
var button_overlays: Array[TextureRect] = []

# Visual Settings
@export var overlay_alphas := {
	"normal": 0.0,
	"hover": 0.5, 
	"pressed": 1.0,
	"disabled": 0.8  # For unavailable buttons
}

@export var label_colors := {
	"normal": Color("#fef5ea"),
	"hover": Color("#cabdad"),
	"pressed": Color("#cabdad"),
	"disabled": Color("#7a7a7a")  # Grayed out for unavailable
}

# Which buttons should be permanently disabled (0-based index)
@export var disabled_buttons := [0, 3]

var current_hovered := -1

func _ready():
	# Hide contributions window initially
	if contributions_window:
		contributions_window.visible = false
	
	# Set version label
	version_label.text = "VERSION %s" % get_version()
	
	# Ensure labels are always on top by setting their z-index first
	for label in labels:
		label.z_index = 10  # High z-index to ensure labels are always visible
	
	# Create overlays for each button using the same texture
	for i in button_backgrounds.size():
		var bg = button_backgrounds[i]
		var label = labels[i]
		
		# Create overlay texture
		var overlay = TextureRect.new()
		overlay.texture = overlay_texture
		overlay.name = bg.name + "Overlay"
		
		# Position and size the overlay to match the button exactly
		overlay.position = bg.position
		overlay.size = bg.size
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Add overlay as a child of the same parent as the button
		bg.get_parent().add_child(overlay)
		overlay.z_index = bg.z_index + 1  # Overlay above button but below text
		
		button_overlays.append(overlay)
		
		# Button setup
		if i in disabled_buttons:
			# Disabled buttons - permanent pressed state
			bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
			overlay.modulate.a = overlay_alphas["disabled"]
			label.modulate = label_colors["disabled"]
		else:
			# Enabled buttons - normal interaction
			bg.mouse_filter = Control.MOUSE_FILTER_STOP
			bg.mouse_entered.connect(_on_element_hovered.bind(i, true))
			bg.mouse_exited.connect(_on_element_hovered.bind(i, false))
			bg.gui_input.connect(_on_button_pressed.bind(i))
			overlay.modulate.a = overlay_alphas["normal"]
			label.modulate = label_colors["normal"]
	
	# Connect exit button if it exists
	if contributions_window:
		var exit_button = contributions_window.get_node("ExitButton") as Button
		if exit_button:
			exit_button.pressed.connect(_on_contributions_exit_pressed)

func get_version() -> String:
	# Try to get version from project settings
	var config = ConfigFile.new()
	var err = config.load("res://application/config/version.cfg")
	if err == OK:
		return config.get_value("application", "config/version", "UNKNOWN")
	
	# Fallback to project settings
	return ProjectSettings.get_setting("application/config/version", "DEV")

func _on_element_hovered(index: int, is_hovered: bool):
	if index in disabled_buttons:
		return  # Ignore hover for disabled buttons
		
	current_hovered = index if is_hovered else -1
	
	# Update overlay transparency
	if index < button_overlays.size():
		button_overlays[index].modulate.a = overlay_alphas["hover"] if is_hovered else overlay_alphas["normal"]
	
	# Update label color
	if index < labels.size():
		labels[index].modulate = label_colors["hover"] if is_hovered else label_colors["normal"]

func _on_button_pressed(event: InputEvent, index: int):
	if index in disabled_buttons:
		return  # Ignore clicks for disabled buttons
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Visual feedback for press
		if index < button_overlays.size():
			button_overlays[index].modulate.a = overlay_alphas["pressed"]
		if index < labels.size():
			labels[index].modulate = label_colors["pressed"]
		
		# Handle different button actions
		match index:
			1:  # NewPlayButton (index 1)
				await get_tree().create_timer(0.3).timeout
				start_new_game()
			2:  # CreditsButton (index 2)
				await get_tree().create_timer(0.1).timeout
				show_contributions()
			_:
				await get_tree().create_timer(0.1).timeout
				menu_item_selected.emit(index)
		
		# Return to hover state if still hovering
		if current_hovered == index:
			if index < button_overlays.size():
				button_overlays[index].modulate.a = overlay_alphas["hover"]
			if index < labels.size():
				labels[index].modulate = label_colors["hover"]
		else:
			if index < button_overlays.size():
				button_overlays[index].modulate.a = overlay_alphas["normal"]
			if index < labels.size():
				labels[index].modulate = label_colors["normal"]

func start_new_game():
	print("Starting new game")
	
	# Store which camp to spawn
	var camp_names = ["MeadowCampBurrow"]
	var random_camp = camp_names[randi() % camp_names.size()]
	
	# Store this in a temporary file
	var file = FileAccess.open("user://pending_camp.dat", FileAccess.WRITE)
	if file:
		file.store_string(random_camp)
		file.store_string("")  # Add a second string to make reading easier
		file.close()
	
	# Change scene
	get_tree().change_scene_to_file("res://scenes/ColonyView.tscn")

func show_contributions():
	if contributions_window:
		contributions_window.visible = true
		# Bring to front
		contributions_window.z_index = 100

func _on_contributions_exit_pressed():
	if contributions_window:
		contributions_window.visible = false

# Make sure labels are always clickable by forwarding mouse events
func _gui_input(event: InputEvent):
	# Forward any mouse events to the appropriate button
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		for i in button_backgrounds.size():
			if i in disabled_buttons:
				continue  # Skip disabled buttons
				
			var bg = button_backgrounds[i]
			if bg and bg.get_global_rect().has_point(get_global_mouse_position()):
				if event is InputEventMouseButton:
					_on_button_pressed(event, i)
				break
