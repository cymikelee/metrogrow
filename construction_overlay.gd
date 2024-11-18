extends ColorRect

const BUILD_COMPLETE = 3
var build_progress = 0

signal build_started()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func increment_build_progress() -> void:
	build_progress += 1
	$ConstructionProgressBar.set_size(
		Vector2((($ConstructionProgressOutline.get_size().x - 2) / BUILD_COMPLETE) * build_progress,
		$ConstructionProgressBar.get_size().y)
	)
	if(build_progress == 1):
		build_started.emit()
	elif(build_progress >= 3):
		queue_free()
