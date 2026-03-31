extends Control

signal button_clicked()

func _on_server_pressed() -> void:
	NetworkHandler.start_server()
	button_clicked.emit()
	get_parent().get_parent().queue_free()


func _on_client_pressed() -> void:
	NetworkHandler.start_client()
	button_clicked.emit()
	get_parent().get_parent().queue_free()

