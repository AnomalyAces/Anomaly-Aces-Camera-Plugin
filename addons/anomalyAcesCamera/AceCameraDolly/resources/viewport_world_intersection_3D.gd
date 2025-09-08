class_name ViewportWorldIntersection3D extends Object

var collider: Node3D = null
var position: Vector3 = Vector3.INF


func _init(dict: Dictionary) -> void:
	if dict.is_empty():
		return
	else:
		collider = dict.collider
		position = dict.position

func is_empty() -> bool:
	return collider == null && position == Vector3.INF

func to_json() -> Dictionary:
	var dict: Dictionary

	dict['collider'] = var_to_str(collider)
	dict['position'] = var_to_str(position)
	
	return dict
