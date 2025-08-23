extends TextureButton
class_name CloseUI

#region Exports
@export var idle_texture: Texture2D
@export var active_texture: Texture2D
@export var is_exit_button: bool = false
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
	if is_exit_button:
		SceneManager.go_to_start_menu()
	else:
		SceneManager.close_current_overlay()
#endregion
