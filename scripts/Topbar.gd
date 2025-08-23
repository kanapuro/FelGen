extends Control
class_name TabManager

signal tab_opened(tab_index: int)

# UI Elements
@export var buttons: Array[TextureRect] = []  # Clickable button backgrounds
@export var labels: Array[Label] = []        # Always-visible labels
@export var default_open := 1

# Visual Settings
@export var button_alphas := {
	"normal": 0.0,
	"hover": 0.5, 
	"active": 1.0
}

@export var label_colors := {
	"normal": Color("#fef5ea"),
	"hover": Color("#cabdad"),
	"active": Color("#cabdad")
}

# Private variables
var _current_active := -1

#region Initialization
func _ready():
	_validate_ui_elements()
	_initialize_tabs()
	set_active_tab(default_open)

func _validate_ui_elements():
	assert(buttons.size() == labels.size(), "Mismatch between buttons (%d) and labels (%d)" % [buttons.size(), labels.size()])
	assert(default_open >= 0 and default_open < buttons.size(), "Default tab index %d is out of bounds" % default_open)

func _initialize_tabs():
	for i in buttons.size():
		_setup_tab(i)

func _setup_tab(index: int):
	var btn = buttons[index]
	
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.mouse_entered.connect(_on_tab_hovered.bind(index, true))
	btn.mouse_exited.connect(_on_tab_hovered.bind(index, false))
	btn.gui_input.connect(_on_tab_pressed.bind(index))
	
	_reset_tab_visuals(index)
#endregion

#region Input Handling
func _on_tab_hovered(index: int, is_hovered: bool):
	if index == _current_active:
		return
	
	_update_button_alpha(index, is_hovered)
	_update_label_color(index, is_hovered)

func _on_tab_pressed(event: InputEvent, index: int):
	if _is_valid_left_click(event):
		set_active_tab(index)

func _is_valid_left_click(event: InputEvent) -> bool:
	return (event is InputEventMouseButton and 
			event.pressed and 
			event.button_index == MOUSE_BUTTON_LEFT)
#endregion

#region Tab Management
func set_active_tab(new_active: int):
	if new_active == _current_active or new_active < 0 or new_active >= buttons.size():
		return
	
	_deactivate_current_tab()
	_activate_tab(new_active)
	tab_opened.emit(new_active)

func _deactivate_current_tab():
	if _current_active != -1:
		_reset_tab_visuals(_current_active)

func _activate_tab(index: int):
	_current_active = index
	buttons[index].modulate.a = button_alphas["active"]
	labels[index].modulate = label_colors["active"]
#endregion

#region Visual Updates
func _update_button_alpha(index: int, is_hovered: bool):
	buttons[index].modulate.a = button_alphas["hover"] if is_hovered else button_alphas["normal"]

func _update_label_color(index: int, is_hovered: bool):
	var color_key = "hover" if is_hovered else "normal"
	labels[index].modulate = label_colors[color_key]

func _reset_tab_visuals(index: int):
	buttons[index].modulate.a = button_alphas["normal"]
	labels[index].modulate = label_colors["normal"]
#endregion

#region Public API
func get_active_tab() -> int:
	return _current_active

func is_tab_active(index: int) -> bool:
	return _current_active == index

func enable_tab(index: int, enabled: bool):
	if index >= 0 and index < buttons.size():
		buttons[index].mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
		labels[index].modulate = label_colors["normal"] if enabled else label_colors["normal"].duplicate().with_alpha(0.5)
#endregion
