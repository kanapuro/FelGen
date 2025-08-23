extends Node

#region Signals
signal screen_changed(screen_name)
signal overlay_opened(overlay_name) 
signal overlay_closed(overlay_name)
#endregion

#region Constants
const SCREENS := {
	"start_menu": "res://scenes/Start.tscn",
	"colony_view": "res://scenes/ColonyView.tscn"
}

const OVERLAYS := {
	"settings": "res://scenes/SettingsScene.tscn",
	"cat_page": "res://scenes/CatPage.tscn"
}
#endregion

#region Variables
var current_screen: Node = null
var current_overlay: Node = null
var confirmation_dialog: ConfirmationDialog = null
#endregion

#region Lifecycle
func _ready():
	load_screen_deferred("start_menu")
#endregion

#region Screen Management
func load_screen_deferred(screen_key: String):
	call_deferred("_load_screen_actual", screen_key)

func _load_screen_actual(screen_key: String) -> bool:
	if not SCREENS.has(screen_key):
		push_error("Screen key not found: ", screen_key)
		return false
	
	_clear_existing_screens()
	return _load_new_screen(screen_key)

func _clear_existing_screens():
	for child in get_tree().root.get_children():
		if child != self:
			child.queue_free()

func _load_new_screen(screen_key: String) -> bool:
	var screen_scene := load(SCREENS[screen_key])
	if screen_scene == null:
		push_error("Failed to load scene: ", SCREENS[screen_key])
		return false
	
	current_screen = screen_scene.instantiate()
	get_tree().root.add_child(current_screen)
	
	emit_signal("screen_changed", screen_key)
	return true

func load_screen(screen_key: String) -> bool:
	load_screen_deferred(screen_key)
	return true
#endregion

#region Overlay Management
func open_overlay(overlay_key: String) -> bool:
	if not OVERLAYS.has(overlay_key):
		push_error("Overlay key not found: ", overlay_key)
		return false
	
	var overlay_scene := load(OVERLAYS[overlay_key])
	if overlay_scene == null:
		push_error("Failed to load overlay: ", OVERLAYS[overlay_key])
		return false
	
	current_overlay = overlay_scene.instantiate()
	current_screen.add_child(current_overlay)
	
	emit_signal("overlay_opened", overlay_key)
	return true

func close_current_overlay():
	if current_overlay:
		current_overlay.queue_free()
		current_overlay = null
		emit_signal("overlay_closed", "overlay")
#endregion

#region Specific Functions
func go_to_start_menu(confirm: bool = false):
	if confirm:
		load_screen_deferred("start_menu")
	else:
		_show_start_menu_confirmation()

func go_to_colony_view():
	load_screen_deferred("colony_view")

func open_settings():
	open_overlay("settings")

func open_cat_page(cat: Node, cat_scene: PackedScene):
	if not open_overlay("cat_page"):
		return
	
	if current_overlay.has_method("show_cat"):
		current_overlay.show_cat(cat, cat_scene)
	else:
		push_error("Current overlay has no show_cat method")

func _show_start_menu_confirmation():
	var dialog := ConfirmationDialog.new()
	dialog.title = "Return to Main Menu?"
	dialog.dialog_text = "Any unsaved progress will be lost!"
	
	dialog.confirmed.connect(_on_confirmation_confirmed)
	dialog.canceled.connect(_on_confirmation_canceled.bind(dialog))
	
	current_screen.add_child(dialog)
	dialog.popup_centered()

func _on_confirmation_confirmed():
	go_to_start_menu(true)

func _on_confirmation_canceled(dialog: ConfirmationDialog):
	dialog.queue_free()
#endregion
