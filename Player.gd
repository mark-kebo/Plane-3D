extends RigidBody

const GRAVITY: float = 9.8
const PLANE_MASS: float = 300.0
const FLAT_PLANE = Plane.PLANE_XZ

const YAW_FORCE = 200.0
const ROLL_FORCE = 150.0
const PITCH_FORCE = 100.0

const THRUST_MAX = 500.0
var currentThrust = 100.0

const AIR_DENSITY = 1.2041
const WINGS_AREA = 2.0

const DRAG_COEF: float = 1.0
const SPEED_CAP = 4.0

var deltaPhysics: float
var statePhysics
#var inputThrust: float

onready var propeller = $Propeller

func _ready():
	set_use_custom_integrator(true)

func _physics_process(delta):
	deltaPhysics = delta
	propeller.rotate_z(20 * delta)

func _integrate_forces(state):
	statePhysics = state
	mass = PLANE_MASS
	addThrust()
	addLift()
	addDrag()
	statePhysics.add_central_force(Vector3.DOWN * mass * GRAVITY)
	
	roll()
	pitch()
	yaw()
	
func addThrust():
	var toAdd = 1
	if Input.is_action_pressed("ui_up"):
		currentThrust += toAdd
		currentThrust = clamp(currentThrust, 0, THRUST_MAX)
		var thrustVec = getForwardVector() * currentThrust
		statePhysics.apply_central_impulse(thrustVec)
	else:
		currentThrust -= toAdd
		currentThrust = clamp(currentThrust, 0, THRUST_MAX)
	
func addLift():
	var lift = getLiftCoeff() * 0.5 * AIR_DENSITY * WINGS_AREA * pow(getForwardSpeed(), 2) * deltaPhysics
	var liftVector = getUpVector() * lift
	statePhysics.apply_central_impulse(liftVector)
	
func addDrag():
	var drag = getDragCoeff() * 0.5 * AIR_DENSITY * WINGS_AREA * pow(getForwardSpeed(), 2) * deltaPhysics
	var dragVector = -linear_velocity.normalized() * drag
	statePhysics.apply_central_impulse(dragVector)
	
func roll():
	if Input.is_action_pressed("movement_left"):
		statePhysics.apply_torque_impulse(-getForwardVector() * ROLL_FORCE * deltaPhysics)
		print("movement_left")
	elif Input.is_action_pressed("movement_right"):
		statePhysics.apply_torque_impulse(getForwardVector() * ROLL_FORCE * deltaPhysics)
		print("movement_right")
		

func pitch():
	if Input.is_action_pressed("movement_down"):
		var test = -getLeftVector() * PITCH_FORCE * deltaPhysics
		statePhysics.apply_torque_impulse(test)
		print(test)
	elif Input.is_action_pressed("movement_up"):
		var test = getLeftVector() * PITCH_FORCE * deltaPhysics
		statePhysics.apply_torque_impulse(test)
		print(test)
		
func yaw():
	if Input.is_action_pressed("movement_left"):
		statePhysics.apply_torque_impulse(-getUpVector() * YAW_FORCE * deltaPhysics)
		print("movement_left")
	elif Input.is_action_pressed("movement_right"):
		statePhysics.apply_torque_impulse(getUpVector() * YAW_FORCE * deltaPhysics)
		print("movement_right")
		
func getLiftCoeff() -> float:
	return 2 * PI / getAngleOfAttack()

func getDragCoeff() -> float:
	return 2 * PI * getAngleOfAttack()
	
func getAngleOfAttack() -> float:
	var forwardVector = getForwardVector()
	var velocityNorm = linear_velocity.normalized()
	return velocityNorm.angle_to(forwardVector)
	
func getForwardVector() -> Vector3:
	return -global_transform.basis.z.normalized()
	
func getForwardSpeed() -> float:
	var forward = linear_velocity.project(getForwardVector()).length()
	return min(forward, SPEED_CAP)
	
func getUpVector() -> Vector3:
	return -global_transform.basis.y.normalized()
	
func getLeftVector() -> Vector3:
	return global_transform.basis.x.normalized()
