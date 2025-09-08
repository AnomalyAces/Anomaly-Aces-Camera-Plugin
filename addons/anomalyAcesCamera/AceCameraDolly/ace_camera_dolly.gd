@tool
@icon("res://addons/anomalyAcesCamera/AceCameraDolly/AceCameraDolly.svg")
class_name AceCameraDolly extends CharacterBody3D

## Controls input for the Camera Dolly
@export var inputMap: AceInputMap :
	set(p_map):
		inputMap = p_map
		update_configuration_warnings()

## Grid map used to detect spaces in view
@export var gridMap: GridMap :
	set(p_grid):
		gridMap = p_grid
		update_configuration_warnings()

## How often the camera looks for changes
@export var activePollingRate: float = 0.5


@onready var elevation: Node3D = $Elevation
@onready var camera: AceCamera3D = $Elevation/AceCamera3D

@export var cameraEnabled: bool = true
@export_category("Movement")
@export var enableMovement: bool = true
@export_range(0, 100, 0.2) var movement_speed: float = 10.0
@export_category("Rotation")
@export var enableRotation: bool = true
@export var invertedY: bool = false
@export var maxElevationAngle: int = 90
@export var minElevationAngle: int = 10
@export_range(0,100, 0.1) var rotationSpeed: float = 10
@export_category("Zoom")
@export var maxZoom: int = 90 
@export var minZoom: int = 10
@export var zoomToMouse: bool = false
@export_range(0,100, 0.1) var zoomSpeed: float = 10
@export_range(0,1, 0.1) var zoomSpeedDamp: float = 0.5
@export_category("Pan")
@export var enablePan: bool = true
@export_range(0, 10, 0.5) var panSpeed: float = 2

signal world_position_in_view(minCoordIntersection: ViewportWorldIntersection3D, maxCoordIntersection: ViewportWorldIntersection3D)

var timer: Timer


func get_world_posiitons_in_view() -> void :
	pass

## Default Movement Controls [br]
## [b]Foward[/b] - [AceInputMap.north_input] [br]
## [b]Backward[/b] - [AceInputMap.south_input] [br]
## [b]Left[/b] - [AceInputMap.west_input] [br]
## [b]Right[/b] - [AceInputMap.east_input] [br]
## 
func _move(delta: float) -> void:
	pass

## Default Rotation Controls [br]
## [b]Enable Rotation[/] - [AceInputMap.camera_rotate_input][br]
## [b]Rotate Left[/b] - [AceInputMap.north_input] [br]
## [b]Rotate Right[/b] - [AceInputMap.south_input] [br]
## 
func _rotate(delta: float) -> void:
	pass

## Default Zoom Controls [br]
## [b]Zoom In[/b] - [AceInputMap.camera_zoom_in_input] [br]
## [b]Zoom Out[/b] - [AceInputMap.camera_zoom_out_input] [br]
## 
func _zoom(delta: float) -> void:
	pass

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	#Check Input Map 
	if inputMap == null:
		warnings.append("A node of type AceInputMap is needed")
	
	#Check Grid Map
	if gridMap  == null:
		warnings.append("A node of type GridMap is needed")

	return warnings

 
