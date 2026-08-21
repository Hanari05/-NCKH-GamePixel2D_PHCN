extends Node

var speed_multiplier = 1.0
var highest_unlocked_level = 1 

var selected_action = 1

# --- MỚI: Biến lưu biên độ tối đa (Max Range of Motion) ---
# Ví dụ: 100 là giơ tay thẳng đứng. Khởi tạo bằng 0.
var max_rom_angle = 0.0
