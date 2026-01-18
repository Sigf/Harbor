class_name PlayerCameraController extends Node3D
# Controls the player camera. Allows or smooth rotation, zooming, and movement. Similar to the camera controls in Fantasy Life i in construction mode.

@export var camera: Camera3D
@export var spring_arm: SpringArm3D
@export var cursor_node: Node3D

@export var move_speed: float = 10.0
@export var rotation_speed: float = 2.0
@export var camera_min_distance: float = 5.0
@export var camera_max_distance: float = 15.0
@export var camera_min_angle: float = 30.0
@export var camera_max_angle: float = 60.0
@export var zoom_speed: float = 5.0
@export var smooth_movement: bool = true
@export var smooth_speed: float = 5.0

var target_position: Vector3 = Vector3.ZERO
var current_rotation: float = 0.0
var current_camera_angle: float = 0.0
var current_camera_distance: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(is_instance_valid(camera))
	assert(is_instance_valid(spring_arm))
	assert(is_instance_valid(cursor_node))

	spring_arm.spring_length = camera_max_distance
	current_camera_angle = camera_max_angle
	current_camera_distance = camera_max_distance

	update_camera_transform(1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update rotation
	var rotate_input := -Input.get_action_strength("rotate_right") + Input.get_action_strength("rotate_left")
	current_rotation += rotate_input * rotation_speed * delta * 100.0

	var tilt_input := -Input.get_action_strength("rotate_up") + Input.get_action_strength("rotate_down")
	current_camera_angle += tilt_input * rotation_speed * delta * 100.0
	current_camera_angle = clamp(current_camera_angle, camera_min_angle, camera_max_angle)
	
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

	# Update camera distance
	var zoom_input := -Input.get_action_strength("zoom_in") + Input.get_action_strength("zoom_out")
	current_camera_distance += zoom_input * zoom_speed * delta
	current_camera_distance = clamp(current_camera_distance, camera_min_distance, camera_max_distance)
	
	update_camera_transform(delta)


func update_camera_transform(delta: float) -> void:
	assert(is_instance_valid(camera))
	assert(is_instance_valid(spring_arm))

	spring_arm.rotation_degrees.y = lerp(spring_arm.rotation_degrees.y, current_rotation, clampf(smooth_speed * delta, 0.0, 1.0)) if smooth_movement else current_rotation
	spring_arm.rotation_degrees.x = lerp(spring_arm.rotation_degrees.x, -current_camera_angle, clampf(smooth_speed * delta, 0.0, 1.0)) if smooth_movement else -current_camera_angle
	spring_arm.position = lerp(spring_arm.position, target_position, clampf(smooth_speed * delta, 0.0, 1.0)) if smooth_movement else target_position
	spring_arm.spring_length = lerp(spring_arm.spring_length, current_camera_distance, clampf(smooth_speed * delta, 0.0, 1.0)) if smooth_movement else current_camera_distance
	cursor_node.position = target_position


func _on_start_pressed() -> void:
	pass
