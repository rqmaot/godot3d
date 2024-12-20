extends Node3D

@onready var player: CharacterBody3D = $Player

var paused := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = Node.PROCESS_MODE_ALWAYS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"): 
		if paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			paused = false
			get_tree().paused = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			paused = true
			get_tree().paused = true
