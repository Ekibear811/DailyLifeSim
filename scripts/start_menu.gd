extends Control

# Hilfsfunktion – jetzt auf Klassenebene (außerhalb von _ready)
func create_button(text: String, callback: Callable):
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 48)
	btn.pressed.connect(callback)
	return btn

func _ready():
	# Vollbild dunkler Hintergrund
	var bg = ColorRect.new()
	bg.color = Color(0.12, 0.12, 0.15, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Mitte zentrieren
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
	# Buttons vertikal
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 40)
	center.add_child(vbox)
	
	# Buttons erstellen – jetzt mit return und add_child außerhalb
	vbox.add_child(create_button("New Game", func(): get_tree().change_scene_to_file("res://scenes/main.tscn")))
	vbox.add_child(create_button("Load Game", func(): print("Load Game – kommt später")))
	vbox.add_child(create_button("Options", func(): print("Options – kommt später")))
	vbox.add_child(create_button("Quit", func(): get_tree().quit()))