extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const GRAPPLE_DISTANCE = 20.0
const LEFT_HOOK = Vector3(-0.5, 0, 0)
const RIGHT_HOOK = Vector3(0.5, 0, 0)
const REEL_SPEED = 4.0

const SENSITIVITY = 0.01
const CAM_RADIUS = 0.0
const CAM_OFFSET = Vector3(0, CAM_RADIUS + 0.555, CAM_RADIUS)

@onready var cam: Camera3D = $Camera3D
@onready var look_raycast: RayCast3D = $Camera3D/LookRaycast
@onready var left_wire: MeshInstance3D = $LeftWire
@onready var right_wire: MeshInstance3D = $RightWire

var left_grappled := false
var right_grappled := false

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	look_raycast.add_exception(self)
	look_raycast.target_position = Vector3(0, 0, -1) * GRAPPLE_DISTANCE
	cam.position.x = CAM_OFFSET.x
	cam.position.y = CAM_RADIUS * sin(-cam.rotation.x) + CAM_OFFSET.y
	cam.position.z = CAM_RADIUS * cos(-cam.rotation.x) + CAM_OFFSET.z
	left_wire.set_player(self)
	right_wire.set_player(self)
	remove_child(left_wire)
	remove_child(right_wire)
	
func _process(delta):
	if left_wire.drawn:
		if left_wire.get_distance_between(to_global(LEFT_HOOK), 
			left_wire.global_to) > GRAPPLE_DISTANCE + 1.0:
			left_grappled = false
		if not left_grappled: left_wire.remove_line()
	if right_wire.drawn:
		if right_wire.get_distance_between(to_global(RIGHT_HOOK), 
			right_wire.global_to) > GRAPPLE_DISTANCE + 1.0:
			right_grappled = false
		if not right_grappled: right_wire.remove_line()
	
	
func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor() and not is_reeling():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
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
	
	if look_raycast.is_colliding():
		if Input.is_action_just_pressed("left_mb"):
			left_grappled = true
			left_wire.draw_line(LEFT_HOOK, look_raycast.get_collision_point())
		if Input.is_action_just_pressed("right_mb"):
			right_grappled = true
			right_wire.draw_line(RIGHT_HOOK, look_raycast.get_collision_point())
	if Input.is_action_just_released("left_mb"):
		left_grappled = false
	if Input.is_action_just_released("right_mb"):
		right_grappled = false
		
	if is_reeling(): velocity.y = 0
		
	if left_grappled and Input.is_action_pressed("reel"):
		var left_vec = (left_wire.global_to - to_global(position)).normalized()
		velocity.x += left_vec.x * REEL_SPEED
		velocity.y += left_vec.y * REEL_SPEED
		velocity.z += left_vec.z * REEL_SPEED
		
	if right_grappled and Input.is_action_pressed("reel"):
		var right_vec = (right_wire.global_to - to_global(position)).normalized()
		velocity.x += right_vec.x * REEL_SPEED
		velocity.y += right_vec.y * REEL_SPEED
		velocity.z += right_vec.z * REEL_SPEED
		
	
	move_and_slide()

func is_reeling():
	return Input.is_action_pressed("reel") and (left_grappled or right_grappled)

func _input(event):
	if event is InputEventMouseMotion:
		var rot_x = event.relative.x * SENSITIVITY
		var rot_y = event.relative.y * SENSITIVITY
		rotate_object_local(Vector3(0, -1, 0), rot_x)
		cam.rotate_object_local(Vector3(-1, 0, 0), rot_y)
		cam.rotation.x = clamp(cam.rotation.x, -PI/2, PI/2)
		cam.position.y = CAM_RADIUS * sin(-cam.rotation.x) + CAM_OFFSET.y
		cam.position.z = CAM_RADIUS * cos(-cam.rotation.x) + CAM_OFFSET.z
