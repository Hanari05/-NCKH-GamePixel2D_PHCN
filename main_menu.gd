extends Control

# Hàm chạy ngay khi mở Menu
func _ready():
	# Giả sử trong VBoxContainer, các nút của bạn tên là Button, Button2, Button3
	# Nếu cấp độ cao nhất < 2, khóa nút Mức 2 (1.5x)
	if Global.highest_unlocked_level < 2:
		$VBoxContainer/Button2.disabled = true
	else:
		$VBoxContainer/Button2.disabled = false
	# Nếu cấp độ cao nhất < 3, khóa nút Mức 3 (2.0x)
	if Global.highest_unlocked_level < 3:
		$VBoxContainer/Button3.disabled = true
	else:
		$VBoxContainer/Button3.disabled = false

func _on_button_pressed():
	Global.speed_multiplier = 1.0 
	# Phóng thẳng vào màn chơi chính
	get_tree().change_scene_to_file("res://main_level.tscn")

func _on_button_2_pressed():
	Global.speed_multiplier = 1.5
	get_tree().change_scene_to_file("res://main_level.tscn")
	
func _on_button_3_pressed():
	Global.speed_multiplier = 2.0
	get_tree().change_scene_to_file("res://main_level.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_selection.tscn")
