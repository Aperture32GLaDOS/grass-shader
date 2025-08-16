extends Camera3D
var sensitivity = 0.009
var x_rot = 0.0;
var y_rot = 0.0;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		transform = transform.rotated_local(Vector3.RIGHT, -y_rot)
		transform = transform.rotated_local(Vector3.UP, -x_rot)
		
		x_rot += -sensitivity * event.relative.x
		y_rot += -sensitivity * event.relative.y
		
		transform = transform.rotated_local(Vector3.UP, x_rot)
		transform = transform.rotated_local(Vector3.RIGHT, y_rot)
	elif event is InputEventKey:
		if event.keycode == KEY_W:
			transform = transform.translated(-transform.basis.z)
		if event.keycode == KEY_S:
			transform = transform.translated(transform.basis.z)
		if event.keycode == KEY_A:
			transform = transform.translated(-transform.basis.x)
		if event.keycode == KEY_D:
			transform = transform.translated(transform.basis.x)
