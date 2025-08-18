extends Control
class_name TabManager

signal tab_opened(tab_index: int)

# UI Elements
@export var buttons: Array[TextureRect] = []  # Clickable button backgrounds
@export var labels: Array[Label] = []        # Always-visible labels (positioned separately)
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

var current_active := -1

func _ready():
	assert(buttons.size() == labels.size(), "Element count mismatch")
	
	for i in buttons.size():
		var btn = buttons[i]
		var lbl = labels[i]
		
		# Button setup
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.mouse_entered.connect(_on_element_hovered.bind(i, true))
		btn.mouse_exited.connect(_on_element_hovered.bind(i, false))
		btn.gui_input.connect(_on_button_pressed.bind(i))
		
		# Initial state
		btn.modulate.a = button_alphas["normal"]
		lbl.modulate = label_colors["normal"]
	
	set_active_tab(default_open)

func _on_element_hovered(index: int, is_hovered: bool):
	# Update button transparency
	if index != current_active:
		buttons[index].modulate.a = button_alphas["hover"] if is_hovered else button_alphas["normal"]
	
	# Always update label color
	labels[index].modulate = label_colors["hover"] if is_hovered else (
		label_colors["active"] if index == current_active else label_colors["normal"]
	)

func _on_button_pressed(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		set_active_tab(index)

func set_active_tab(new_active: int):
	if new_active == current_active: return
	
	# Reset previous tab
	if current_active != -1:
		buttons[current_active].modulate.a = button_alphas["normal"]
		labels[current_active].modulate = label_colors["normal"]
	
	# Set new active tab
	current_active = new_active
	buttons[new_active].modulate.a = button_alphas["active"]
	labels[new_active].modulate = label_colors["active"]
	
	tab_opened.emit(new_active)
