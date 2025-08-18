extends TextureButton

@export var idle_texture: Texture2D
@export var active_texture: Texture2D  # Used for both hover/pressed
@export var settings_scene: PackedScene  # Assign settings_page.tscn

func _ready():
	texture_normal = idle_texture
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	texture_normal = active_texture

func _on_mouse_exited():
	texture_normal = idle_texture

func _pressed():
	texture_normal = active_texture  # Visual feedback
	get_tree().current_scene.add_child(settings_scene.instantiate())
