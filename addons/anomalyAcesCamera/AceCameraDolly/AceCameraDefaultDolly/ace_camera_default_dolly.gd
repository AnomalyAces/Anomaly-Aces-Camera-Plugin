@tool
class_name AceCameraDefaultDolly extends AceCameraDolly



## Defaults for Camera
# Use local space - true
# Elevation rotation: -45, 0, 0
# Ace Camera position: 0, 0, 10

#Boolean to determine if the camera are actively moving, rotating, or zooming
var _is_active: bool = false
var _curr_active_status:bool = false
var _prev_active_status: bool = false

var _last_mouse_pos: Vector2 = Vector2.ZERO
var _is_rotating: bool = false

var _displacement: Vector2 = Vector2.ZERO

var _zoom_direction: float = 0.0
var _is_zooming_to_position: bool = false

var _is_panning: bool = false

const GROUND_PLANE: Plane = Plane(Vector3.UP, 0)
const RAY_LENGTH: float = 1000




func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = activePollingRate
	timer.connect("timeout", _check_active_state)
	timer.start()


func _physics_process(delta: float) -> void:
	if cameraEnabled:
		_move(delta)
		_rotate(delta)
		_zoom(delta)
		_pan(delta)


func _unhandled_input(event: InputEvent) -> void:

	
	if inputMap != null:
		#check if rotating
		if event.is_action_pressed(inputMap.camera_rotate_input):
			_is_rotating = true
			_last_mouse_pos = get_viewport().get_mouse_position()
		if event.is_action_released(inputMap.camera_rotate_input):
			_is_rotating = false
		
		#Check if zooming
		if event.is_action_pressed(inputMap.camera_zoom_in_input):
			_last_mouse_pos = get_viewport().get_mouse_position()
			_zoom_direction = -1

		if event.is_action_pressed(inputMap.camera_zoom_out_input):
			_last_mouse_pos = get_viewport().get_mouse_position()
			_zoom_direction = 1
		

		#Check if Panning
		if event.is_action_pressed(inputMap.camera_pan_input):
			_is_panning = true
			_last_mouse_pos = get_viewport().get_mouse_position()
		if event.is_action_released(inputMap.camera_pan_input):
			_is_panning = false
	

func _move(delta: float) -> void:
	# if not allow_wasd_movement:
	# 	return
	if inputMap != null && enableMovement:
		
		var input_dir : Vector2 = inputMap.get_input_vector()
		var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * movement_speed
			velocity.z = direction.z * movement_speed
		else:
			velocity.x = move_toward(velocity.x, 0, movement_speed)
			velocity.z = move_toward(velocity.z, 0, movement_speed)
		
		move_and_slide()

		_is_active = _check_if_active()


func _rotate(delta: float) -> void:
	if inputMap == null || !enableRotation || !_is_rotating:
		return 

	_displacement = _get_mouse_displacement()
	# Use horizontal displacement to rotate
	_rotate_horizontal(delta, _displacement.x)
	# Use the vertical displacement to elevate
	_elevate(delta, _displacement.y)

	_is_active = _check_if_active()
	

func _zoom(delta: float) -> void:
	# Calculat the new zoom and Clamp new zoom between min and max zoom
	var new_zoom: float = clamp(camera.position.z + (zoomSpeed * delta * _zoom_direction)
							, minZoom
							, maxZoom
						)

	if zoomToMouse && !_is_zooming_to_position && _zoom_direction != 0:

		_is_zooming_to_position = true
		var mouse_pos_3D: Vector3 = _get_mouse_3D_location(_last_mouse_pos)
		var target: Vector3 = Vector3(mouse_pos_3D.x, position.y, mouse_pos_3D.z)
		_jump(target)

	#zoom
	camera.position.z = new_zoom
	
	#Stop scrolling
	_zoom_direction *= zoomSpeedDamp
	if is_zero_approx(abs(_zoom_direction)):
		_zoom_direction = 0
	
	_is_active = _check_if_active()


func _pan(delta: float) -> void:
	if not enablePan or not _is_panning:
		return
	# get mouse speed
	_displacement = _get_mouse_displacement()
	# transform to velocity
	var velocity = (global_transform.basis.z * _displacement.y + global_transform.basis.x * _displacement.x) * delta * panSpeed
	# update position
	position += -velocity
	_is_active = _check_if_active()


func _jump(target: Vector3) -> void:
	## If there is a defined gridmap use that to "lock in" a location to avoid camera osciallations
	var tween: Tween = create_tween()
	var target_camera_dolly_position: Vector3 = target if gridMap == null else _get_grid_location(target)
	print("moving to camera to position during zoom: %s" % target_camera_dolly_position)
	tween.tween_property(self, "position", target_camera_dolly_position, .5)
	tween.tween_callback(_move_camera_complete.bind(target_camera_dolly_position))

func _get_mouse_displacement() -> Vector2:
	var curr_mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var displacement: Vector2 = curr_mouse_pos - _last_mouse_pos
	_last_mouse_pos = curr_mouse_pos
	return displacement

func _get_mouse_3D_location(curr_mouse_pos: Vector2) -> Vector3:
	#Get current mouse position in the viewport
	print("Current mouse screen position %s" % curr_mouse_pos)

	#Get position translated to world postion
	var curr_mouse_pos_intersection: ViewportWorldIntersection3D = _get_viewport_to_world_intersection(curr_mouse_pos)
	var curr_mouse_pos_3D: Vector3 = curr_mouse_pos_intersection.position
	print("Current mouse pos 3D %s" % curr_mouse_pos_3D)
	print("Current camera pos 3D %s" % position)

	return curr_mouse_pos_3D

func _rotate_horizontal(delta: float, val: float) -> void:
	rotation_degrees.y += val * delta * rotationSpeed

func _elevate(delta: float, val: float) -> void:
	#Calulate new elevation
	var new_elevation: float = elevation.rotation_degrees.x
	if invertedY:
		new_elevation += (val * delta * rotationSpeed)
	else:
		new_elevation -= (val * delta * rotationSpeed)
	#Clamp the new elevation
	new_elevation = clamp(new_elevation, -maxElevationAngle, -minElevationAngle)
	#Set new elevation based on the clapmed elevation 
	elevation.rotation_degrees.x = new_elevation


##########################
## Camera Helper Functions 
##########################
func _check_if_active() -> bool:
	return velocity != Vector3.ZERO || _displacement != Vector2.ZERO || _zoom_direction != 0


func _check_active_state() -> void:
	_curr_active_status = _is_active
	if _curr_active_status != _prev_active_status:
		print("Camera Active Status Changed: %s" % _curr_active_status)
		if !_curr_active_status:
			_get_world_posiitons_in_view()
		

	
	_prev_active_status = _curr_active_status


func _get_world_posiitons_in_view() -> void :

	var minCoordIntersection: ViewportWorldIntersection3D
	var maxCoordIntersection: ViewportWorldIntersection3D

	var viewport_size: Vector2 = camera.camera_host.get_viewport().get_visible_rect().size

	var max_grid_loc: Vector3i = gridMap.get_used_cells().max()

	#Get the 4 corners intersection
	var top_left_intersection: ViewportWorldIntersection3D = _get_viewport_to_world_intersection(Vector2.ZERO)
	var top_right_intersection: ViewportWorldIntersection3D = _get_viewport_to_world_intersection(Vector2(viewport_size.x, 0))
	var bottom_left_intersection: ViewportWorldIntersection3D = _get_viewport_to_world_intersection(Vector2(0, viewport_size.y))
	var bottom_right_intersection: ViewportWorldIntersection3D = _get_viewport_to_world_intersection(viewport_size)

	#Different Scenarios

	#Top Left and Bottom Left are empty
	if top_left_intersection.is_empty() && !top_right_intersection.is_empty() && bottom_left_intersection.is_empty() && !bottom_right_intersection.is_empty():
		minCoordIntersection = ViewportWorldIntersection3D.new({"collider": null, "position": Vector3(0,top_right_intersection.position.y, top_right_intersection.position.z)})
		maxCoordIntersection = bottom_right_intersection
	#Top Right and Bottom Right are empty
	elif !top_left_intersection.is_empty() && top_right_intersection.is_empty() && !bottom_left_intersection.is_empty() && bottom_right_intersection.is_empty():
		minCoordIntersection = top_left_intersection
		maxCoordIntersection = ViewportWorldIntersection3D.new({"collider": null, "position": Vector3(max_grid_loc.x,bottom_left_intersection.position.y, bottom_left_intersection.position.z)})
	#Bottom Right and Bottom Right are empty
	elif !top_left_intersection.is_empty() && top_right_intersection.is_empty() && !bottom_left_intersection.is_empty() && bottom_right_intersection.is_empty():
		minCoordIntersection = top_left_intersection
		maxCoordIntersection = ViewportWorldIntersection3D.new({"collider": null, "position": Vector3(top_right_intersection.position.x,bottom_left_intersection.position.y, max_grid_loc.z)})
	#Only Top Right present
	elif top_left_intersection.is_empty() && !top_right_intersection.is_empty() && bottom_left_intersection.is_empty() && bottom_right_intersection.is_empty():
		minCoordIntersection = ViewportWorldIntersection3D.new({"collider": null, "position": Vector3(0,top_right_intersection.position.y, top_right_intersection.position.z)})
		maxCoordIntersection = ViewportWorldIntersection3D.new({"collider": null, "position": Vector3(top_right_intersection.position.x,top_right_intersection.position.y, max_grid_loc.z)})
	#Only Bottom Left present
	elif top_left_intersection.is_empty() && top_right_intersection.is_empty() && !bottom_left_intersection.is_empty() && bottom_right_intersection.is_empty():
		minCoordIntersection = ViewportWorldIntersection3D.new({"collider": null, "position": Vector3(bottom_left_intersection.position.x,top_right_intersection.position.y, 0)})
		maxCoordIntersection = ViewportWorldIntersection3D.new({"collider": null, "position": Vector3(bottom_left_intersection.position.x,top_right_intersection.position.y, max_grid_loc.z)})
	else:
		minCoordIntersection = top_left_intersection
		maxCoordIntersection = bottom_right_intersection
	

	world_position_in_view.emit(minCoordIntersection, maxCoordIntersection)


func _get_viewport_to_world_intersection(target: Vector2) -> ViewportWorldIntersection3D:

	# Get center of viewport for position sampling

	# Convert the screen position to a ray's origin in world space
	# This is the starting point of our ray in 3D space, which is typically the camera's position
	# but adjusted for the perspective projection.
	var ray_origin: Vector3 = camera.camera_host.project_ray_origin(target)

	# Convert the screen position to a ray's normal (direction) in world space
	# This vector points from the camera through the mouse_screen_pos into the scene.
	var ray_direction: Vector3 = camera.camera_host.project_ray_normal(target)

	# Define the end point of the ray
	# We'll make the ray long enough to reach the camera's 'far' clipping plane.
	# This ensures we can detect hits on anything the camera can see.
	var ray_length: float = camera.camera_host.get_far() # Get the camera's far clipping distance
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	# 5. Perform the raycast
	# We need the 3D physics space state to perform raycasts.
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	# You can add exclude or collide_with_areas/bodies to the query if needed
	query.exclude = [self] # Exclude the camera itself from being hit
	query.collide_with_areas = true
	query.collide_with_bodies = true

	return ViewportWorldIntersection3D.new(space_state.intersect_ray(query))


func _get_grid_location(loc: Vector3) -> Vector3:
	return Vector3(gridMap.local_to_map(loc)) + gridMap.cell_size * .5


func _move_camera_complete(target_pos: Vector3):
	print("zoom repositioning complete")
	#Snap the values to avoid floating point errors 
	#camera dolly position
	position = target_pos
	
	_is_zooming_to_position = false
