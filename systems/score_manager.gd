class_name ScoreManager
extends Node

signal score_changed(banked_score: int, active_score: int, total_score: int)

var banked_score: int = 0
var active_score: int = 0
var _active_collectibles: Dictionary = {}


func reset_campaign() -> void:
	banked_score = 0
	active_score = 0
	_active_collectibles.clear()
	_emit_score_changed()


func sync_active_collectibles(active_collectibles: Dictionary) -> void:
	_active_collectibles = active_collectibles.duplicate()
	active_score = 0
	for points: Variant in _active_collectibles.values():
		active_score += int(points)
	_emit_score_changed()


func commit_level_score() -> void:
	banked_score += active_score
	active_score = 0
	_active_collectibles.clear()
	_emit_score_changed()


func get_total_score() -> int:
	return banked_score + active_score


func _emit_score_changed() -> void:
	score_changed.emit(banked_score, active_score, get_total_score())
