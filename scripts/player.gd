extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01
const GRAPPLE_DISTANCE = 20.0

@onready var cam: Camera3D = $Camera3D
@onready var look_raycast: RayCast3D = $Camera3D/LookRaycast

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	look_raycast.add_exception(self)
	look_raycast.target_position = Vector3(0, 0, -1) * GRAPPLE_DISTANCE

func _input(event):
	if event is InputEventMouseMotion:
		var rot_x = event.relative.x * SENSITIVITY
		var rot_y = event.relative.y * SENSITIVITY
		rotate_object_local(Vector3(0, -1, 0), rot_x)
		cam.rotate_object_local(Vector3(-1, 0, 0), rot_y)
		cam.rotation.x = clamp(cam.rotation.x, -PI/2, PI/2)

func create_line(from, to, to_obj):
	line = 

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
