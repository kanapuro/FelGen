extends Control

func _ready():
	# Ensure the close button exists and is connected
	var close_button = $Background/BackButton as Button
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	else:
		push_error("CloseButton node not found!")

func _on_close_pressed():
	print("Close button pressed!")  # Debug output
	queue_free()
	
	# Optional: Play a sound effect
	# $AudioStreamPlayer.play()
