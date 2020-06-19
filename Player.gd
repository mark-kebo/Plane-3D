extends RigidBody

const GRAVITY: float = 9.8
const PLANE_MASS: float = 50.0

const YAW_FORCE = 50.0
const ROLL_FORCE = 50.0
const PITCH_FORCE = 50.0

const THRUST_MAX = 50.0
var currentThrust = 0.0

const AIR_DENSITY = 1.2041
const WINGS_AREA = 28.0

const DRAG_COEF: float = 1.0
#const SPEED_CAP = 4.0

var deltaPhysics: float
var statePhysics
#var inputThrust: float

var drag := 0.0
var lift := 0.0
var forward := 0.0
var dragVector := Vector3.ZERO
var liftVector := Vector3.ZERO

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
	var toAdd = 0.1
	if Input.is_action_pressed("ui_up"):
		currentThrust += toAdd
		currentThrust = clamp(currentThrust, 0, THRUST_MAX)
	if Input.is_action_pressed("ui_down"):
		currentThrust -= toAdd
		currentThrust = clamp(currentThrust, 0, THRUST_MAX)
	var thrustVec = getForwardVector() * currentThrust
	statePhysics.apply_central_impulse(thrustVec)
	
func addLift():
	lift = getLiftCoeff() * 0.5 * AIR_DENSITY * WINGS_AREA * pow(getForwardSpeed(), 2) * deltaPhysics
	liftVector = -getUpVector() * lift
	statePhysics.apply_central_impulse(liftVector)
#	print(liftVector)
	
func addDrag():
	drag = getDragCoeff() * 0.5 * AIR_DENSITY * WINGS_AREA * pow(getForwardSpeed(), 2) * deltaPhysics
	dragVector = -linear_velocity.normalized() * drag
	statePhysics.apply_central_impulse(dragVector)
	
func roll():
	if Input.is_action_pressed("roll_left"):
		statePhysics.apply_torque_impulse(-getForwardVector() * ROLL_FORCE * deltaPhysics)
	elif Input.is_action_pressed("roll_right"):
		statePhysics.apply_torque_impulse(getForwardVector() * ROLL_FORCE * deltaPhysics)
		

func pitch():
	if Input.is_action_pressed("pitch_down"):
		var test = -getLeftVector() * PITCH_FORCE * deltaPhysics
		statePhysics.apply_torque_impulse(test)
	elif Input.is_action_pressed("pitch_up"):
		var test = getLeftVector() * PITCH_FORCE * deltaPhysics
		statePhysics.apply_torque_impulse(test)
		
func yaw():
	if Input.is_action_pressed("yaw_left"):
		statePhysics.apply_torque_impulse(-getUpVector() * YAW_FORCE * deltaPhysics)
	elif Input.is_action_pressed("yaw_right"):
		statePhysics.apply_torque_impulse(getUpVector() * YAW_FORCE * deltaPhysics)

func getLiftCoeff() -> float:
	return getAngleOfAttack()

func getDragCoeff() -> float:
	return 0.4
	
func getAngleOfAttack() -> float:
	var forwardVector = getForwardVector()
	var velocityNorm = linear_velocity.normalized()
	return velocityNorm.angle_to(forwardVector)
	
func getForwardVector() -> Vector3:
	return -global_transform.basis.z.normalized()
	
func getForwardSpeed() -> float:
	forward = linear_velocity.project(getForwardVector()).length()
	return forward
#	return min(forward, SPEED_CAP)
	
func getUpVector() -> Vector3:
	return -global_transform.basis.y.normalized()
	
func getLeftVector() -> Vector3:
	return global_transform.basis.x.normalized()
