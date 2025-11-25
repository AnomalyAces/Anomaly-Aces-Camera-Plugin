@tool
class_name AceCameraManager extends Node

## Controls whether a 2D or 3D Camera is used [br]
## [b]2D[/b] - 2D Camera [br]
## [b]3D[/b] - 3D Camera
enum CAMERA_TYPE {_2D, _3D}

## Controls Camera(s) that should be active [br]
## [b]PLAYER[/b] - Activates and cycles Player Cameras [br]
## [b]MAP[/b] - Activates Map camera [br]
## [b]SELECT[/b] - Activates Select Camera
enum CAMERA_MODE {PLAYER, MAP, SELECT}

#Controls priority for active and inactive
const CAMERA_ACTIVE: int = 10
const CAMERA_INACITVE: int = 0

signal camera_mode_changed(mode: CAMERA_MODE)


@export var cameraType: CAMERA_TYPE = CAMERA_TYPE._3D :
	set(p_mode):
		cameraType = p_mode
		notify_property_list_changed()
@export var inputMap: AceInputMap :
	set(p_input_map):
		inputMap = p_input_map
		update_configuration_warnings()
@export_category("3D")
@export var playerCameras3D: Array[AceCamera3D] = [] :
	set(p_playerCams):
		playerCameras3D = p_playerCams
		update_configuration_warnings()

@export var gridMapCamera: AceCamera3D : 
	set(p_gridCam):
		gridMapCamera = p_gridCam
		update_configuration_warnings()

@export var selectCamera3D: AceCamera3D:
	set(p_selectCam):
		selectCamera3D = p_selectCam
		update_configuration_warnings()

@export_category("2D")


var cameraMode: CAMERA_MODE = CAMERA_MODE.PLAYER

func set_camera_mode(mode: CAMERA_MODE) -> void:
	cameraMode = mode
	_toggle_camera_priority()
	camera_mode_changed.emit(cameraMode)


func _unhandled_input(event: InputEvent) -> void:
	# toggle_camera_mode is the input
	if inputMap != null:
		if event.is_action_pressed(inputMap.toggle_camera_mode_input):
			cameraMode = _get_next_camera_mode()
			_toggle_camera_priority()
			camera_mode_changed.emit(cameraMode)

func _toggle_camera_priority():
	if cameraType == CAMERA_TYPE._3D:
		if cameraMode == CAMERA_MODE.PLAYER:
			## Set first player camera as active
			for i in playerCameras3D.size():
				if i == 0:
					_set_3d_camera_priority(playerCameras3D[i], CAMERA_ACTIVE)
				else:
					_set_3d_camera_priority(playerCameras3D[i], CAMERA_INACITVE)
			
			## Set the other Cameras priority to 0
			_set_3d_camera_priority(gridMapCamera, CAMERA_INACITVE)
			_set_3d_camera_priority(selectCamera3D, CAMERA_INACITVE)
		elif cameraMode == CAMERA_MODE.MAP:
			## Set Map Camera to Active
			_set_3d_camera_priority(gridMapCamera, CAMERA_ACTIVE)
	
			## Set player camera as inactive
			for i in playerCameras3D.size():
				_set_3d_camera_priority(playerCameras3D[i], CAMERA_INACITVE)
	
			## Set the other Cameras priority to 0
			_set_3d_camera_priority(selectCamera3D, CAMERA_INACITVE)
		elif cameraMode == CAMERA_MODE.SELECT:
			## Set Select Camera to Active
			_set_3d_camera_priority(selectCamera3D, CAMERA_ACTIVE)
	
			## Set player camera as inactive
			for i in playerCameras3D.size():
				_set_3d_camera_priority(playerCameras3D[i], CAMERA_INACITVE)
	
			## Set the other Cameras priority to 0
			_set_3d_camera_priority(gridMapCamera, CAMERA_INACITVE)
	else: 
		AceLog.printLog(["2D Not implemented yet"])



func _validate_property(property: Dictionary) -> void:
	var _3D_props: Array[String]  = ["playerCameras3D", "gridMapCamera", "selectCamera3D"]
	var _2D_props: Array[String]  = []

	if property.name in _3D_props and cameraType != CAMERA_TYPE._3D:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in _3D_props and cameraType == CAMERA_TYPE._3D:
		property.usage = PROPERTY_USAGE_DEFAULT 
	
	if property.name in _2D_props and cameraType != CAMERA_TYPE._2D:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in _2D_props and cameraType == CAMERA_TYPE._2D:
		property.usage = PROPERTY_USAGE_DEFAULT 


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	#Check Input 
	if inputMap == null:
		warnings.append("A node of type AceInputMap is needed")

	#Check Player Cams
	if playerCameras3D.size() == 0:
		warnings.append("No Player Cameras defined")
	else:
		for i in playerCameras3D.size():
			if playerCameras3D[i] == null:
				warnings.append("Player Camera %d is null" % i)
	
	#Check Grid Map Cam
	if gridMapCamera  == null:
		warnings.append("gridMapCamera is not defined")
	
	#Check Select Cam
	if selectCamera3D  == null:
		warnings.append("selectCamera3D is not defined")

	return warnings

func _get_next_camera_mode() ->  CAMERA_MODE:
	var newCameraMode: CAMERA_MODE
	var keys = CAMERA_MODE.keys()
	var current_index = keys.find(keys[cameraMode])
	if current_index < keys.size() - 1:
		newCameraMode = CAMERA_MODE.get(keys[current_index + 1])
	else:
		# Wrap around to the first value if we're at the end
		newCameraMode = CAMERA_MODE.get(keys[0])
	return newCameraMode

func _set_3d_camera_priority(camera: AceCamera3D, priority: int) -> void:
	if camera != null:
		camera.set_camera_priority(priority)
