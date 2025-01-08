extends Node3D

@onready var wire: MeshInstance3D = $"."

var player = null
func set_player(p):
	player = p
	
var drawn := false

var local_from := Vector3.ZERO
var global_to := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wire.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	wire.mesh.material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wire.mesh.material.albedo_color = Color.BLACK
	wire.mesh.top_radius = 0.025
	wire.mesh.bottom_radius = 0.025

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player != null:
		var from = player.to_global(local_from)
		update(from, global_to)

func draw_line(from, to):
	if player == null: return
	local_from = from
	global_to = to
	update(player.to_global(from), global_to)
	player.get_tree().get_root().add_child(wire)
	drawn = true

func remove_line():
	player.get_tree().get_root().remove_child(wire)
	drawn = false

func update(from, to):
	wire.rotation = get_rotation_between(from, to)
	wire.mesh.height = get_distance_between(from, to)
	wire.global_position = (from + to) * 0.5

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
