extends ParallaxBackground

# Tốc độ trôi của nền (có thể chỉnh chậm hơn chướng ngại vật để tạo độ sâu 3D)
var scroll_speed = 100.0

func _process(delta):
	# Hàm này sẽ liên tục đẩy tọa độ của toàn bộ hình nền sang trái
	scroll_offset.x -= (scroll_speed * Global.speed_multiplier) * delta
