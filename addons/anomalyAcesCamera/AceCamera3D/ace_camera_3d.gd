@tool
@icon("res://addons/anomalyAcesCamera/AceCamera.svg")
class_name AceCamera3D extends Node3D

## Controls the movement mode of the character [br]
## [b]FREE[/b] - Free form movement [br]
## [b]FIXED[/b] - Movement restricted to a Follow Mode from [PhantomCamera3D]
enum MOVEMENT_MODE {FIXED, FREE}

@export var movement_mode: MOVEMENT_MODE = MOVEMENT_MODE.FIXED :
	set(p_move_mode):
		movement_mode = p_move_mode

@export_group("Fixed Movement")
@export var follow_mode: PhantomCamera3D.FollowMode = PhantomCamera3D.FollowMode.SIMPLE:
	set(p_follow_mode):
		follow_mode = p_follow_mode
		_update_fixed_camera_settings()
		update_configuration_warnings()

@export var follow_target: Node3D :
	set(p_follow_target):
		follow_target = p_follow_target
		_update_fixed_camera_settings()
		update_configuration_warnings()

@export var follow_offset: Vector3 = Vector3.ZERO :
	set(p_follow_offset):
		follow_offset = p_follow_offset
		_update_fixed_camera_settings()
		update_configuration_warnings()

@export var rotation_in_degrees: Vector3 = Vector3.ZERO :
	set(p_rotation):
		rotation_in_degrees = p_rotation
		_update_fixed_camera_settings()
		update_configuration_warnings()



@onready var camera_host: Camera3D = $CameraHost
@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D


func set_camera_priority(priority: int) -> void:
	if phantom_camera_3d != null: 
		phantom_camera_3d.priority = priority

func _process(delta: float) -> void:
	if phantom_camera_3d == null and ($PhantomCamera3D).is_node_ready():
		phantom_camera_3d = $PhantomCamera3D


func _update_fixed_camera_settings() -> void:
	if phantom_camera_3d != null:
		phantom_camera_3d.follow_mode = follow_mode
		phantom_camera_3d.follow_target = follow_target
		phantom_camera_3d.set_follow_offset(follow_offset) #Vector3(0, 1.0, 1.25)
		phantom_camera_3d.rotation_degrees = rotation_in_degrees #Vector3(-24, 0, 0)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	#Check camera_host
	if camera_host == null:
		warnings.append("A child node of type Camera3D is needed")
	
	#Check player_camera
	if phantom_camera_3d == null:
		warnings.append("A child node of type PhantomCamera3D is needed")
	
	#Check follow_target
	if movement_mode == MOVEMENT_MODE.FIXED:
		if follow_target == null:
			warnings.append("No follow target has be assigned")
	

	return warnings
