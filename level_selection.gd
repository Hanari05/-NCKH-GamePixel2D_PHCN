extends Control

func _on_back_button_pressed():
	# Nút Quay lại đưa về Start Screen
	get_tree().change_scene_to_file("res://calibration_screen.tscn")

func _on_button_pressed():
	Global.selected_action = 1
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_button_2_pressed():
	Global.selected_action = 2
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
func _on_button_3_pressed():
	Global.selected_action = 3
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_button_4_pressed():
	Global.selected_action = 4
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_button_5_pressed():
	Global.selected_action = 5
	get_tree().change_scene_to_file("res://main_menu.tscn")
