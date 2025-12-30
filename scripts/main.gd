extends Node2D

var player: CharacterBody2D
var camera: Camera2D
var time_label: Label
var background: ColorRect   # <-- Wichtig für Tag/Nacht

# Tageszeit in Minuten (0 = 00:00, 1440 = 24:00)
var game_time: float = 480.0  # Start um 08:00 Uhr

const TIME_SCALE = 60.0  # 1 echte Sekunde = 1 Spielminute (schnell zum Testen)

func _ready():
	# Großer grauer Boden
	background = ColorRect.new()
	background.color = Color(0.3, 0.3, 0.3, 1)
	background.size = Vector2(10000, 10000)
	background.position = Vector2(-5000, -5000)
	add_child(background)
	
	# Spieler
	player = CharacterBody2D.new()
	player.position = Vector2(0, 0)
	add_child(player)
	
	var sprite = ColorRect.new()
	sprite.color = Color(1, 1, 1, 1)
	sprite.size = Vector2(64, 64)
	sprite.position = Vector2(-32, -32)
	player.add_child(sprite)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(64, 64)
	collision.shape = shape
	player.add_child(collision)
	
	# Kamera folgt Spieler
	camera = Camera2D.new()
	camera.enabled = true
	camera.zoom = Vector2(0.8, 0.8)
	player.add_child(camera)
	
	# HUD: Uhr oben links
	var hud = CanvasLayer.new()
	add_child(hud)
	
	time_label = Label.new()
	time_label.text = get_time_string()
	time_label.add_theme_font_size_override("font_size", 36)
	time_label.add_theme_color_override("font_color", Color(1, 1, 1))
	time_label.position = Vector2(20, 20)
	hud.add_child(time_label)

const SPEED = 400

func _physics_process(delta):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y += 1
	
	velocity = velocity.normalized() * SPEED
	player.velocity = velocity
	player.move_and_slide()

func _process(delta):
	# Zeit vorlaufen lassen
	game_time += delta * TIME_SCALE
	
	# Nach 24 Stunden zurücksetzen
	if game_time >= 1440:
		game_time -= 1440
	
	# Uhr aktualisieren
	time_label.text = get_time_string()
	
	# Tag/Nacht-Wechsel
	var hour = int(game_time / 60)
	if hour >= 6 and hour < 18:  # 6:00 – 17:59 = Tag
		background.color = Color(0.5, 0.5, 0.6, 1)  # Heller Tag
	else:
		background.color = Color(0.1, 0.1, 0.15, 1)  # Dunkle Nacht

func get_time_string() -> String:
	var hours = int(game_time / 60)
	var minutes = int(game_time) % 60
	return "%02d:%02d" % [hours, minutes]