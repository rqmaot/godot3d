extends Node3D

const pts := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func draw_line(from, to):
	var mesh_instance := MeshInstance3D.new()
	var cylinder_mesh := CylinderMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = cylinder_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = (from + to) * 0.5
	var dir = (from - to).normalized()
	const up = Vector3(0, 1, 0)
	if dir == -up:
		mesh_instance.rotation = Vector3(PI, 0, 0)
	else:
		mesh_instance.rotation = Basis(up, dir).get_euler()

	#immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	#immediate_mesh.surface_add_vertex(from)
	#immediate_mesh.surface_add_vertex(to)
	#immediate_mesh.surface_end()
	
	var dx = from.x - to.x
	var dy = from.y - to.y
	var dz = from.z - to.z
	var d = sqrt(dx * dx + dy * dy + dz * dz)
	cylinder_mesh.height = d

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK

	get_tree().get_root().add_child(mesh_instance)
	return mesh_instance

func draw():
	pass
