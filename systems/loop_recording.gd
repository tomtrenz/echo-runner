class_name LoopRecording
extends RefCounted

var input_frames: Array[RunnerInput] = []
var collected_items: Dictionary = {}


func collect_item(collectible_id: StringName, points: int) -> bool:
	if collectible_id == &"" or points <= 0 or collected_items.has(collectible_id):
		return false

	collected_items[collectible_id] = points
	return true
