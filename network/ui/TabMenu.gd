extends PanelContainer


func _input(event):
	if event.is_action_pressed("tab"):
		visible = !visible
