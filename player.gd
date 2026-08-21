extends CharacterBody2D

# Lực nhảy (Số âm vì trong game 2D, trục Y hướng lên trên là số âm)
const JUMP_VELOCITY = -400.0

# Lấy trọng lực mặc định của Godot
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# --- MỚI: Biến lưu số mạng của nhân vật ---
var lives = 3

func _physics_process(delta):
	# 1. TRỌNG LỰC: Nếu nhân vật không đứng trên sàn, nó sẽ bị rơi xuống
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. NHẢY: Nếu bấm phím Space (ui_accept) VÀ đang đứng trên sàn
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Lệnh bắt buộc để nhân vật di chuyển và tương tác vật lý
	move_and_slide()
	
	# --- MỚI: Hàm xử lý khi bị chướng ngại vật tông trúng ---
func take_damage():
	lives -= 1 
	
	if lives <= 0:
		print("Hết mạng! Game Over!")
		# Lệnh này sẽ đưa người chơi văng ra ngoài màn hình Menu
		get_tree().change_scene_to_file("res://main_menu.tscn")
	else:
		position.y = -200 
		velocity.y = 0
