extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const GRAPPLE_DISTANCE = 20.0
const LEFT_HOOK = Vector3(-0.55, 0, 0)
const RIGHT_HOOK = Vector3(0.55, 0, 0)

const SENSITIVITY = 0.01
const CAM_RADIUS = 0
const CAM_OFFSET = Vector3(0, 0.555, 0)

@onready var cam: Camera3D = $Camera3D
@onready var look_raycast: RayCast3D = $Camera3D/LookRaycast

var left_grappled := false
var left_wire = null
var left_hooked_to = Vector3(0, 0, 0)
var right_grappled := false
var right_wire = null
var right_hooked_to = Vector3(0, 0, 0)

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	look_raycast.add_exception(self)
	look_raycast.target_position = Vector3(0, 0, -1) * GRAPPLE_DISTANCE
	cam.position.z = CAM_RADIUS

func _input(event):
	if event is InputEventMouseMotion:
		var rot_x = event.relative.x * SENSITIVITY
		var rot_y = event.relative.y * SENSITIVITY
		rotate_object_local(Vector3(0, -1, 0), rot_x)
		cam.rotate_object_local(Vector3(-1, 0, 0), rot_y)
		cam.rotation.x = clamp(cam.rotation.x, -PI/2, PI/2)
		cam.position.y = CAM_RADIUS * sin(-cam.rotation.x) + CAM_OFFSET.y
		cam.position.z = CAM_RADIUS * cos(-cam.rotation.x) + CAM_OFFSET.z
	
func _process(delta):
	if not left_grappled and left_wire != null:
		get_tree().get_root().remove_child(left_wire)
		left_wire = null
	if not right_grappled and right_wire != null:
		get_tree().get_root().remove_child(right_wire)
		right_wire = null
	if left_wire != null:
		update_mesh(left_wire, to_global(LEFT_HOOK), left_hooked_to)
		if get_distance_between(to_global(LEFT_HOOK), left_hooked_to) > GRAPPLE_DISTANCE + 1.0:
			left_grappled = false
	if right_wire != null:
		update_mesh(right_wire, to_global(RIGHT_HOOK), right_hooked_to)
		if get_distance_between(to_global(RIGHT_HOOK), right_hooked_to) > GRAPPLE_DISTANCE + 1.0:
			right_grappled = false
	
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
	
	if look_raycast.is_colliding():
		if Input.is_action_just_pressed("left_mb"):
			left_grappled = true
			left_hooked_to = look_raycast.get_collision_point()
			left_wire = grapple(LEFT_HOOK, look_raycast.get_collision_point())
		if Input.is_action_just_pressed("right_mb"):
			right_grappled = true
			right_hooked_to = look_raycast.get_collision_point()
			right_wire = grapple(RIGHT_HOOK, look_raycast.get_collision_point())
	if Input.is_action_just_released("left_mb"):
		left_grappled = false
	if Input.is_action_just_released("right_mb"):
		right_grappled = false
	
	move_and_slide()

func grapple(from, to):
	return draw_line(to_global(from), to)

func update_mesh(mesh, from, to):
	mesh.rotation = get_rotation_between(from, to)
	mesh.mesh.height = get_distance_between(from, to)
	mesh.position = (from + to) * 0.5

func get_rotation_between(from, to):
	var dir = (from - to).normalized()
	const up = Vector3(0, 1, 0)
	if dir == up:
		return Vector3(0, 0, 0)
	elif dir == -up:
		return Vector3(PI, 0, 0)
	else:
		return Basis(Quaternion(up, dir)).get_euler()

func get_distance_between(from, to):
	var dx = from.x - to.x
	var dy = from.y - to.y
	var dz = from.z - to.z
	return sqrt(dx * dx + dy * dy + dz * dz)

func draw_line(from, to):
	var mesh_instance := MeshInstance3D.new()
	var cylinder_mesh := CylinderMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = cylinder_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = (from + to) * 0.5
	mesh_instance.rotation = get_rotation_between(from, to)
	
	cylinder_mesh.height = get_distance_between(from, to)
	cylinder_mesh.top_radius = 0.025
	cylinder_mesh.bottom_radius = 0.025

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	cylinder_mesh.material = material

	get_tree().get_root().add_child(mesh_instance)
	return mesh_instance
