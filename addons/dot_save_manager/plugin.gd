@tool
extends EditorPlugin


func _enable_plugin() -> void:
	add_autoload_singleton("DOT_save", "res://addons/dot_save_manager/tool/DOT_save.gd")
	pass


func _disable_plugin() -> void:
	remove_autoload_singleton("DOT_save")
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
