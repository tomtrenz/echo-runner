extends Label


func _on_player_update_score(new_score: Variant) -> void:
	text = String.num_int64(new_score)
