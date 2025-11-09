extends Control

signal menu_item_selected(item_index: int)

static var pending_camp: String = ""
static var pending_position: Vector2 = Vector2.ZERO

# UI References
@onready var contributions_window: TextureRect = $Contributions
@onready var contributions_exit_button: TextureButton = $Contributions/ExitButton
@onready var button_backgrounds: Array[TextureRect] = [
	$ButtonContainer/ContinuePlayButton,
	$ButtonContainer/NewPlayButton,
	$ButtonContainer/SettingsButton,
	$ButtonContainer/CreditsButton,
	$ButtonContainer/ExitButton
]
@onready var labels: Array[Label] = [
	$ButtonContainer/ContinuePlayLabel,
	$ButtonContainer/NewPlayLabel,
	$ButtonContainer/SettingsLabel,
	$ButtonContainer/CreditsLabel,
	$ButtonContainer/ExitLabel
]
@onready var version_label: Label = $VersionLabel

# Visual Settings
@export var overlay_alphas := {
	"normal": 0.0, "hover": 0.5, "pressed": 1.0, "disabled": 0.8
}
@export var label_colors := {
	"normal": Color("#fef5ea"), "hover": Color("#cabdad"),
	"pressed": Color("#cabdad"), "disabled": Color("#7a7a7a")
}
@export var disabled_buttons := [0, 3]

# Constants
const OVERLAY_TEXTURE := preload("res://resources/ui/LIGHT/LIGHTgeneralbuttonpressed.png")

# Variables
var button_overlays: Array[TextureRect] = []
var current_hovered := -1

#region Initialization
func _ready():
	print("🔍 StartMenu - Checking for SaveManager:")
	print("  Has /root/SaveManager: ", has_node("/root/SaveManager"))
	
	_initialize_ui()
	_setup_button_system()
	_setup_contributions_button()

func _initialize_ui():
	version_label.text = "VERSION %s" % get_version()
	for label in labels:
		label.z_index = 10

func _setup_button_system():
	for i in button_backgrounds.size():
		var bg = button_backgrounds[i]
		var label = labels[i]
		
		var overlay = _create_button_overlay(bg)
		button_overlays.append(overlay)
		
		if i in disabled_buttons:
			_setup_disabled_button(bg, overlay, label)
		else:
			_setup_interactive_button(bg, overlay, label, i)

func _setup_contributions_button():
	if contributions_exit_button:
		contributions_exit_button.mouse_entered.connect(_on_contributions_exit_button_mouse_entered)
		contributions_exit_button.mouse_exited.connect(_on_contributions_exit_button_mouse_exited)
		contributions_exit_button.pressed.connect(_on_contributions_exit_button_pressed)

func _create_button_overlay(bg: TextureRect) -> TextureRect:
	var overlay = TextureRect.new()
	overlay.texture = OVERLAY_TEXTURE
	overlay.name = bg.name + "Overlay"
	overlay.position = bg.position
	overlay.size = bg.size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = bg.z_index + 1
	bg.get_parent().add_child(overlay)
	return overlay

func _setup_disabled_button(bg: TextureRect, overlay: TextureRect, label: Label):
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.modulate.a = overlay_alphas["disabled"]
	label.modulate = label_colors["disabled"]

func _setup_interactive_button(bg: TextureRect, overlay: TextureRect, label: Label, index: int):
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	bg.mouse_entered.connect(_on_element_hovered.bind(index, true))
	bg.mouse_exited.connect(_on_element_hovered.bind(index, false))
	bg.gui_input.connect(_on_button_pressed.bind(index))
	overlay.modulate.a = overlay_alphas["normal"]
	label.modulate = label_colors["normal"]
#endregion

#region Utility Functions
func get_version() -> String:
	var config = ConfigFile.new()
	if config.load("res://application/config/version.cfg") == OK:
		return config.get_value("application", "config/version", "UNKNOWN")
	return ProjectSettings.get_setting("application/config/version", "DEV")
#endregion

#region Input Handling
func _on_element_hovered(index: int, is_hovered: bool):
	if index in disabled_buttons: return
	
	current_hovered = index if is_hovered else -1
	
	if index < button_overlays.size():
		button_overlays[index].modulate.a = overlay_alphas["hover" if is_hovered else "normal"]
	if index < labels.size():
		labels[index].modulate = label_colors["hover" if is_hovered else "normal"]

func _on_button_pressed(event: InputEvent, index: int):
	if index in disabled_buttons: return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT): return
	
	_handle_button_press_visuals(index)
	await _handle_button_action(index)
	_handle_button_hover_recovery(index)

func _handle_button_press_visuals(index: int):
	if index < button_overlays.size():
		button_overlays[index].modulate.a = overlay_alphas["pressed"]
	if index < labels.size():
		labels[index].modulate = label_colors["pressed"]

func _handle_button_hover_recovery(index: int):
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

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		for i in button_backgrounds.size():
			if i in disabled_buttons: continue
			var bg = button_backgrounds[i]
			if bg and bg.get_global_rect().has_point(get_global_mouse_position()):
				if event is InputEventMouseButton:
					_on_button_pressed(event, i)
				break
#endregion

#region Button Actions
func _handle_button_action(index: int):
	print("🔄 Button action triggered for index: ", index)  # ADD THIS
	
	match index:
		0: # ContinuePlayButton
			print("🎯 Continue game button pressed")
			await get_tree().create_timer(0.3).timeout
			continue_game()
		1: # NewPlayButton
			print("🎯 New game button pressed")  # ADD THIS
			await get_tree().create_timer(0.3).timeout
			start_new_game()
		3: # CreditsButton
			await get_tree().create_timer(0.1).timeout
			show_contributions()
		4: # ExitButton
			await get_tree().create_timer(0.1).timeout
			exit_game()
		_:
			await get_tree().create_timer(0.1).timeout
			menu_item_selected.emit(index)

func start_new_game():
	print("Starting new game")
	var camp_names = ["MeadowCampBurrow"]
	var random_camp = camp_names[randi() % camp_names.size()]
	
	# Continue with original flow FIRST
	var file = FileAccess.open("user://pending_camp.dat", FileAccess.WRITE)
	if file:
		file.store_string(random_camp)
		file.store_string("")
		file.close()
	
	SceneManager.go_to_colony_view()
	
	# Wait for colony to load, then create AND save the world
	await get_tree().create_timer(0.5).timeout
	
	print("🕒 World creation timer finished - attempting to create world...")  # ADD THIS
	
	# Create and save the world
	if has_node("/root/SaveManager"):
		print("✅ SaveManager found for world creation")  # ADD THIS
		var save_manager = get_node("/root/SaveManager") as SaveManager
		if save_manager and save_manager.has_method("save_game"):
			var world_name = "New Clan " + Time.get_datetime_string_from_system().replace(":", ".")
			print("🎯 Attempting to create world: ", world_name)  # ADD THIS
			if save_manager.save_game(world_name):
				print("✅ New world created and saved: ", world_name)
				print("🌍 World ID: ", save_manager.current_world_id)
			else:
				print("⚠️ Could not create new world")
		else:
			print("❌ SaveManager missing save_game method")
	else:
		print("❌ SaveManager not found for world creation")

func continue_game():
	print("Continuing game")
	
	if has_node("/root/SaveManager"):
		var save_manager = get_node("/root/SaveManager") as SaveManager
		if save_manager and save_manager.has_method("get_saved_games") and save_manager.has_method("load_game"):
			var saves = save_manager.get_saved_games()  # FIXED: Added this missing line!
			if not saves.is_empty():
				# Load by WORLD ID, not name
				var most_recent = saves[0]
				if save_manager.load_game(most_recent.world_id):  # ✅ Using world_id
					print("✅ Loaded saved game: ", most_recent.world_name)
					SceneManager.go_to_colony_view()
					return
				else:
					print("❌ Failed to load saved game")
			else:
				print("❌ No saved games found")
	
	# Fallback: start new game if no saves or load failed
	print("No saved games found, starting new game instead")
	start_new_game()

func exit_game():
	print("Exiting game...")
	if OS.has_feature("web"):
		print("Cannot exit on web version")
		return
	get_tree().quit()

func show_contributions():
	if contributions_window:
		contributions_window.visible = true
		contributions_window.z_index = 100
#endregion

#region Contributions Button
func _on_contributions_exit_button_mouse_entered():
	contributions_exit_button.texture_normal = preload("res://resources/ui/LIGHT/LIGHTx2.png")

func _on_contributions_exit_button_mouse_exited():
	contributions_exit_button.texture_normal = preload("res://resources/ui/LIGHT/LIGHTx1.png")

func _on_contributions_exit_button_pressed():
	contributions_exit_button.texture_normal = preload("res://resources/ui/LIGHT/LIGHTx2.png")
	_on_contributions_exit_pressed()

func _on_contributions_exit_pressed():
	if contributions_window:
		contributions_window.visible = false
#endregion
