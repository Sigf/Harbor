class_name PlayerCameraController extends Node3D

@export var camera: Camera3D
@export var move_speed: float = 10.0
@export var rotation_speed: float = 2.0
@export var camera_distance: float = 15.0
@export var camera_height: float = 30.0

var target_position: Vector3 = Vector3.ZERO
var current_rotation: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not camera:
		camera = $Camera3D
		
	update_camera_transform()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update rotation
	var rotate_input := -Input.get_action_strength("rotate_right") + Input.get_action_strength("rotate_left")
	current_rotation += rotate_input * rotation_speed * delta * 100.0
	
	# Update target location
	var move_input := Vector2(Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"), Input.get_action_raw_strength("move_right") - Input.get_action_strength("move_left"))
	var camera_forward := -camera.global_transform.basis.z
	camera_forward.y = 0.0
	camera_forward = camera_forward.normalized()
	var camera_side := camera.global_transform.basis.x
	camera_side.y = 0.0
	camera_side = camera_side.normalized()
	target_position += camera_forward * move_input.x * move_speed * delta
	target_position += camera_side * move_input.y * move_speed * delta
	
	update_camera_transform()


func update_camera_transform() -> void:
	assert(is_instance_valid(camera))
	
	var offset = Vector3(0.0, camera_height, camera_distance)
	offset = offset.rotated(Vector3.UP, deg_to_rad(current_rotation))
	
	camera.position = target_position + offset
	camera.look_at(target_position, Vector3.UP)


func _on_start_pressed() -> void:
	pass
