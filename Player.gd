extends KinematicBody

onready var propeller = $Propeller

func _ready():
	pass

func _physics_process(delta):
	propeller.rotate_z(20 * delta)
