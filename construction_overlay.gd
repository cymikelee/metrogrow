extends ColorRect

var build_time = 3;
var build_progress = 0

signal build_started()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_build_time(time: int) -> void:
	build_time = time

func increment_build_progress() -> void:
	build_progress += 1
	$ConstructionProgressBar.set_size(
		Vector2((($ConstructionProgressOutline.get_size().x - 2) / build_time) * build_progress,
		$ConstructionProgressBar.get_size().y)
	)
	if(build_progress == 1):
		build_started.emit()
	elif(build_progress >= build_time):
		queue_free()
