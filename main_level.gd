extends Node2D

const EXERCISE_CONFIGS := {
	1: {"exercise_id": "scapular_retraction", "repetitions_per_phase": 10, "phase_count": 2, "hold_duration_ms": 0},
	2: {"exercise_id": "wall_abduction_external_rotation", "repetitions_per_phase": 5, "phase_count": 1, "hold_duration_ms": 5000},
	3: {"exercise_id": "horizontal_shoulder_adduction", "repetitions_per_phase": 5, "phase_count": 1, "hold_duration_ms": 5000},
	4: {"exercise_id": "hands_behind_head", "repetitions_per_phase": 5, "phase_count": 1, "hold_duration_ms": 5000},
	5: {"exercise_id": "cross_body_shoulder_stretch", "repetitions_per_phase": 2, "phase_count": 1, "hold_duration_ms": 30000},
}

var obstacle_scene = preload("res://obstacle.tscn")
var star_scene = preload("res://star.tscn") 

var score = 0.0 
var star_score = 0 

@onready var exercise_session: ExerciseSession = $ExerciseSession
@onready var state_label: Label = $UI/ScoreLabel
@onready var phase_label: Label = $UI/LivesLabel
@onready var rep_label: Label = $UI/StarScoreLabel
@onready var feedback_label: Label = $UI/FeedbackLabel
@onready var rest_label: Label = $UI/RestLabel
@onready var result_panel: PanelContainer = $UI/ResultPanel
@onready var result_label: Label = $UI/ResultPanel/MarginContainer/VBoxContainer/ResultLabel

func _ready() -> void:
	score = 0.0
	star_score = 0
	$Player.lives = 3
	# Sprint 2: runner spawners remain available but session progression must
	# come only from PoseProvider repetition events.
	$SpawnTimer.stop()
	$StarTimer.stop()
	result_panel.hide()
	rest_label.hide()

	exercise_session.state_changed.connect(_on_session_state_changed)
	exercise_session.progress_changed.connect(_on_session_progress_changed)
	exercise_session.feedback_changed.connect(_on_session_feedback_changed)
	exercise_session.repetition_accepted.connect(_on_repetition_accepted)
	exercise_session.repetition_rejected.connect(_on_repetition_rejected)
	exercise_session.rest_time_changed.connect(_on_rest_time_changed)
	exercise_session.session_completed.connect(_on_session_completed)

	var session_config: Dictionary = EXERCISE_CONFIGS.get(Global.selected_action, EXERCISE_CONFIGS[1]).duplicate(true)
	session_config["session_id"] = "game-session-%d" % Time.get_ticks_msec()
	session_config["difficulty"] = _difficulty_name()
	session_config["target_rom_ratio"] = _target_rom_ratio()
	session_config["minimum_movement_duration_ms"] = 2000
	session_config["maximum_movement_duration_ms"] = 5000
	session_config["rest_duration_seconds"] = 30.0
	exercise_session.start_session(session_config)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_N:
		exercise_session.debug_skip_rest()


func _on_session_state_changed(current: ExerciseSession.State, _previous: ExerciseSession.State) -> void:
	state_label.text = "TRẠNG THÁI: %s" % _state_text(current)
	rest_label.visible = current == ExerciseSession.State.RESTING


func _on_session_progress_changed(rep: int, reps_required: int, phase: int, phases: int) -> void:
	rep_label.text = "LẦN: %d/%d" % [rep, reps_required]
	phase_label.text = "PHASE: %d/%d" % [phase, phases]


func _on_session_feedback_changed(code: String) -> void:
	feedback_label.text = _feedback_text(code)


func _on_repetition_accepted(_data: Dictionary) -> void:
	feedback_label.modulate = Color(0.1, 0.75, 0.2)


func _on_repetition_rejected(_data: Dictionary) -> void:
	feedback_label.modulate = Color(0.9, 0.2, 0.1)


func _on_rest_time_changed(seconds_remaining: float) -> void:
	rest_label.text = "NGHỈ: %d GIÂY\nNhấn N để bỏ qua khi debug" % ceili(seconds_remaining)


func _on_session_completed(summary: Dictionary) -> void:
	result_label.text = "HOÀN THÀNH BUỔI TẬP\n\nLần hợp lệ: %d\nLần chưa hợp lệ: %d\nSố phase: %d" % [
		int(summary.get("valid_reps", 0)),
		int(summary.get("rejected_reps", 0)),
		int(summary.get("phase_count", 0)),
	]
	result_panel.show()
	_unlock_next_difficulty()


func _on_result_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _exit_tree() -> void:
	if is_instance_valid(exercise_session):
		exercise_session.stop_session("scene_changed")


func _difficulty_name() -> String:
	if Global.speed_multiplier >= 2.0:
		return "advanced"
	if Global.speed_multiplier >= 1.5:
		return "standard"
	return "gentle"


func _target_rom_ratio() -> float:
	if Global.speed_multiplier >= 2.0:
		return 0.90
	if Global.speed_multiplier >= 1.5:
		return 0.80
	return 0.70


func _unlock_next_difficulty() -> void:
	if Global.speed_multiplier == 1.0 and Global.highest_unlocked_level < 2:
		Global.highest_unlocked_level = 2
	elif Global.speed_multiplier == 1.5 and Global.highest_unlocked_level < 3:
		Global.highest_unlocked_level = 3


func _state_text(value: ExerciseSession.State) -> String:
	match value:
		ExerciseSession.State.READY: return "CHUẨN BỊ"
		ExerciseSession.State.ACTIVE: return "ĐANG TẬP"
		ExerciseSession.State.RESTING: return "ĐANG NGHỈ"
		ExerciseSession.State.PAUSED: return "TẠM DỪNG"
		ExerciseSession.State.TRACKING_LOST: return "MẤT NHẬN DIỆN"
		ExerciseSession.State.COMPLETED: return "HOÀN THÀNH"
		_: return "CHỜ"


func _feedback_text(code: String) -> String:
	const TEXTS := {
		"SESSION_READY": "Sẵn sàng. Hãy thực hiện động tác chậm rãi.",
		"MOVEMENT_STARTED": "Đã bắt đầu chuyển động...",
		"TARGET_REACHED": "Đã đạt ngưỡng mục tiêu.",
		"REP_VALID": "Tốt lắm! Một lần tập hợp lệ.",
		"MOVEMENT_TOO_FAST": "Cử động quá nhanh. Hãy thực hiện chậm hơn.",
		"REP_REJECTED": "Lần tập chưa hợp lệ.",
		"PHASE_REST": "Hoàn thành phase. Hãy nghỉ 30 giây.",
		"NEXT_PHASE": "Bắt đầu phase tiếp theo.",
		"TRACKING_LOST": "Không nhìn thấy người chơi. Buổi tập đã tạm dừng.",
		"TRACKING_RESTORED": "Đã nhận diện lại. Tiếp tục buổi tập.",
		"BACKEND_DISCONNECTED": "Mất kết nối với hệ thống nhận diện.",
		"SESSION_COMPLETED": "Hoàn thành buổi tập!",
	}
	return TEXTS.get(code, code)

func _on_spawn_timer_timeout():
	var new_obstacle = obstacle_scene.instantiate()
	new_obstacle.position = $SpawnPosition.position
	add_child(new_obstacle)
	$SpawnTimer.wait_time = randf_range(1.0, 2.5)
	
func _on_star_timer_timeout():
	var new_star = star_scene.instantiate()
	
	# Random một số nguyên từ 1 đến 3 (1: Dễ, 2: Vừa, 3: Khó)
	var random_type = randi_range(1, 3) 
	var y_offset = 0 # Biến để chỉnh độ cao (nhớ là trục Y hướng lên trên là số ÂM)
	
	if random_type == 1:
		# LOẠI 1 (DỄ): To, thấp, 10 điểm
		new_star.scale = Vector2(1.5, 1.5) # Phóng to gấp rưỡi
		y_offset = 0 # Thấp (ngang với điểm xuất phát gốc)
		new_star.point_value = 10
		
	elif random_type == 2:
		# LOẠI 2 (VỪA): Kích thước bình thường, cao vừa, 20 điểm
		new_star.scale = Vector2(1.0, 1.0) # Giữ nguyên
		y_offset = -60 # Dịch lên cao một chút (có thể tùy chỉnh số 60 này)
		new_star.point_value = 20
		
	else:
		# LOẠI 3 (KHÓ): Nhỏ, rất cao, 50 điểm
		new_star.scale = Vector2(0.6, 0.6) # Thu nhỏ lại
		y_offset = -130 # Dịch lên rất cao, đòi hỏi nhảy thật chuẩn
		new_star.point_value = 50

	# Thiết lập vị trí mới: X giữ nguyên, Y cộng thêm khoảng bù (y_offset)
	var spawn_x = $StarSpawnPosition.position.x
	var spawn_y = $StarSpawnPosition.position.y + y_offset
	new_star.position = Vector2(spawn_x, spawn_y)
	
	# Đưa ra màn hình
	add_child(new_star)
	
	# Random thời gian đẻ sao tiếp theo
	$StarTimer.wait_time = randf_range(3.0, 5.0)
