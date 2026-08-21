extends Area2D

const SPEED = 250.0

func _process(delta):
	position.x -= (SPEED * Global.speed_multiplier) * delta
	if position.x < -100:
		queue_free()

# Đây là hàm Godot vừa tự tạo cho bạn
func _on_body_entered(body):
	# Kiểm tra xem vật vừa chạm vào có phải là Player không
	if body.name == "Player":
		# Gọi hàm trừ máu bên trong Player
		body.take_damage()
		# Tự xóa chướng ngại vật này đi
		queue_free()
