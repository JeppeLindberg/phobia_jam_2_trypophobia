extends CharacterBody3D

@export var movement_speed = 5

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3
var rotation_target: Vector3

var input_mouse: Vector2

var health:int = 100
var gravity := 0.0

var previously_floored := false

var container_offset = Vector3(1.2, -1.1, -2.75)

var tween:Tween

@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var hand_container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/hand_container
@onready var sound_footsteps = $SoundFootsteps
@onready var click_cooldown = $Cooldown
@onready var dialog = get_node('dialog')
@export var key_a: Node3D
@export var key_b: Node3D


func _ready():	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	key_a.visible = false
	key_b.visible = false

func enter_dialog(dialog_array):
	dialog.enter_dialog(dialog_array)

func add_key_a():
	key_a.visible = true
	
func add_key_b():
	key_b.visible = true

func _physics_process(delta):
	
	handle_controls(delta)
	handle_gravity(delta)
	

	var applied_velocity: Vector3
	
	movement_velocity = transform.basis * movement_velocity # Move forward
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
		
	camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
	
	camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	
	hand_container.position = lerp(hand_container.position, container_offset - (basis.inverse() * applied_velocity / 30), delta * 10)
		
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false
	
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored: # Landed
		Audio.play("sounds/land.ogg")
		camera.position.y = -0.1
	
	previously_floored = is_on_floor()
	
	if position.y < -10:
		get_tree().reload_current_scene()

func _input(event):
	if not dialog.is_in_dialog():
		if event is InputEventMouseMotion and mouse_captured:
			
			input_mouse = event.relative / mouse_sensitivity
			
			rotation_target.y -= event.relative.x / mouse_sensitivity
			rotation_target.x -= event.relative.y / mouse_sensitivity

func handle_controls(_delta):	
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		
		input_mouse = Vector2.ZERO
	
	var input = Vector2.ZERO
	if not dialog.is_in_dialog():
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed
	
	var rotation_input = Vector2.ZERO
	if not dialog.is_in_dialog():
		rotation_input = Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	
	rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	
	interact()

func handle_gravity(delta):
	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		gravity = 0

func interact():
	raycast.force_raycast_update()
	
	if not dialog.is_in_dialog() and Input.is_action_just_pressed("interact"):
	
		if !click_cooldown.is_stopped(): 
			return
		
		if !raycast.is_colliding(): 
			return
		
		var collider = raycast.get_collider()
		
		print(collider)

		if collider.is_in_group('interactable'):
			collider.interact()
		
		click_cooldown.start()
		
		
