extends TextureButton
class_name OpenUI

#region Exports
@export var idle_texture: Texture2D
@export var active_texture: Texture2D
@export var action_type: String = ""  # "screen_change" or "overlay"
@export var target: String = ""       # "start_menu", "colony_view", "settings", etc.
#endregion

#region Lifecycle
func _ready():
	_initialize_button()
	_connect_signals()

func _initialize_button():
	texture_normal = idle_texture

func _connect_signals():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
#endregion

#region Input Handling
func _on_mouse_entered():
	texture_normal = active_texture

func _on_mouse_exited():
	texture_normal = idle_texture

func _pressed():
	texture_normal = active_texture
	_handle_button_action()

func _handle_button_action():
	match action_type:
		"screen_change":
			SceneManager.load_screen(target)
		"overlay":
			SceneManager.open_overlay(target)
		_:
			push_warning("Unknown action type: ", action_type)
#endregion
