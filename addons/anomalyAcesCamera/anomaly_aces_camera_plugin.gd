@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	#Add Custom Types

	add_custom_type(
		"AceCameraManager",
		"Node",
		preload("res://addons/anomalyAcesCamera/AceCameraManager/ace_camera_manager.gd"),
		preload("res://addons/anomalyAcesCamera/AceCameraManager/AceCameraManager.svg")
	)
	AceLog.printLog(["AceCameraManager Entering Tree"])

	add_custom_type(
		"AceCamera3D",
		"Node3D",
		preload("res://addons/anomalyAcesCamera/AceCamera3D/ace_camera_3d.gd"),
		preload("res://addons/anomalyAcesCamera/AceCamera.svg")
	)
	AceLog.printLog(["AceCamera3D Entering Tree"])


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("AceCameraManager")
	remove_custom_type("AceCamera3D")
