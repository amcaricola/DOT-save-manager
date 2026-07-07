@tool
extends EditorPlugin

const DOT_Save : String = "res://addons/dot_save_manager/tool/DOT_save.gd"
const _DOT_pannel : PackedScene = preload("res://addons/dot_save_manager/tool/_panel_dot.tscn")
var panel : Control 


func _enable_plugin() -> void:
	add_autoload_singleton("DOT_save", DOT_Save)
	pass


func _disable_plugin() -> void:
	remove_autoload_singleton("DOT_save")
	pass


func _enter_tree() -> void:
	panel = _DOT_pannel.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, panel)
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	remove_control_from_docks(panel)
	panel.queue_free()
	# Clean-up of the plugin goes here.
	pass
