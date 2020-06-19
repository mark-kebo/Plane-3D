class_name AxisMarker3D, "res://marker/AxisMarker3D.svg"
extends Spatial

func _process(_delta):
	translation = get_parent().get_node("Player").translation
	translation.y += 1
	DrawLine3D.DrawRay(translation, get_parent().get_node("Player").liftVector, Color.red, 0.0)
	DrawLine3D.DrawRay(translation, get_parent().get_node("Player").dragVector, Color.black, 0.0)
	DrawLine3D.DrawRay(translation, get_parent().get_node("Player").linear_velocity, Color.green, 0.0)
	DrawLine3D.DrawRay(translation, get_parent().get_node("Player").linear_velocity.project(get_parent().get_node("Player").getForwardVector()), Color.cyan, 0.0)
	$currentThrust.scale.z = -get_parent().get_node("Player").currentThrust
#	$drag.transform.basis = Basis(-get_parent().get_node("Player").dragVector.normalized())
#	$drag.scale.z = get_parent().get_node("Player").drag
#	$lift.transform.basis = Basis(-get_parent().get_node("Player").liftVector.normalized())
#	$lift.scale.y = get_parent().get_node("Player").lift
##	$forward.scale.x = get_parent().forward
#	$forward.transform.basis = Basis(-get_parent().get_node("Player").linear_velocity.normalized())
#	$forward.scale.z = get_parent().get_node("Player").linear_velocity.length()
