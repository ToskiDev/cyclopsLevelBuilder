# MIT License
#
# Copyright (c) 2023 Mark McKay
# https://github.com/blackears/cyclopsLevelBuilder
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@tool
extends Tree
class_name MaterialGroupsTree


enum ButtonType { VISIBLE }

const bn_vis_off = preload("res://addons/cyclops_level_builder/art/icons/eye_closed.svg")
const bn_vis_on = preload("res://addons/cyclops_level_builder/art/icons/eye_open.svg")

var plugin:CyclopsLevelBuilder:
	get:
		return plugin
	set(value):
		if value == plugin:
			return
			
		if plugin:
			var ed_iface:EditorInterface = plugin.get_editor_interface()
			var efs:EditorFileSystem = ed_iface.get_resource_filesystem()
			efs.filesystem_changed.disconnect(on_filesystem_changed)
			efs.resources_reimported.disconnect(on_resources_reimported)
			efs.resources_reload.disconnect(on_resources_reload)
			
		plugin = value
		
		if plugin:
			var ed_iface:EditorInterface = plugin.get_editor_interface()
			var efs:EditorFileSystem = ed_iface.get_resource_filesystem()
			efs.filesystem_changed.connect(on_filesystem_changed)
			efs.resources_reimported.connect(on_resources_reimported)
			efs.resources_reload.connect(on_resources_reload)
		
		reload_materials()

#var root_group:MaterialGroup = MaterialGroup.new()

var tree_item_to_path_map:Dictionary
var path_to_tree_item_map:Dictionary

#func _input(event):
	#if event is InputEventMouseButton:
		#var e:InputEventMouseButton = event
		#
		#if e.button_index == MOUSE_BUTTON_RIGHT:
			#if !e.is_pressed():
				#
				#%PopupMenu.popup_on_parent(Rect2i(e.position.x, e.position.y, 0, 0))
#
			#get_viewport().set_input_as_handled()
		

func reload_materials():
	print("reload_materials")
	clear()
	tree_item_to_path_map.clear()
	path_to_tree_item_map.clear()

	if !plugin:
		return

	var ed_iface:EditorInterface = plugin.get_editor_interface()
	var efs:EditorFileSystem = ed_iface.get_resource_filesystem()

	var root_dir:EditorFileSystemDirectory = efs.get_filesystem()
	
	var root_tree_item:TreeItem = create_item()
	root_tree_item.set_text(0, root_dir.get_name())
	root_tree_item.set_checked(1, true)
	root_tree_item.set_editable(1, true)
	
	tree_item_to_path_map[root_tree_item] = root_dir.get_path()
	path_to_tree_item_map[root_dir.get_path()] = root_tree_item
	
	build_tree_recursive(root_dir, root_tree_item)
	
	collapse_unused_dirs()	
	
	##################
	#root_item.set_text(0, root_group.name)
#
	#
	#if !root_group:
		#return
	#
	#print("Set item ", root_group.name)
	#var root_item:TreeItem = create_item()
	#root_item.set_text(0, root_group.name)
	#root_item.set_editable(0, true)
	#
	#build_tree_recursive(root_group, root_item)
	
	pass

func build_tree_recursive(parent_dir:EditorFileSystemDirectory, tree_item_parent:TreeItem):
	#print("par_dir count ", parent_dir.get_path(), parent_dir.get_subdir_count())

	for i in parent_dir.get_subdir_count():
		var child_dir:EditorFileSystemDirectory = parent_dir.get_subdir(i)
		#print("add child ", child_dir.get_path())

		var item:TreeItem = create_item(tree_item_parent)
		item.set_text(0, child_dir.get_name())
		item.set_checked(1, true)
		#item.set_editable(1, true)
		item.add_button(1, bn_vis_on, ButtonType.VISIBLE, false, "Visible")

		tree_item_to_path_map[item] = child_dir.get_path()
		path_to_tree_item_map[child_dir.get_path()] = item
		#print("path ", child_dir.get_path())
		
		build_tree_recursive(child_dir, item)
		

#
#func build_tree_recursive(mat_group:MaterialGroup, tree_group_parent:TreeItem):
	#var item:TreeItem = create_item(tree_group_parent)
	#item.set_text(0, mat_group.name)
	#item.set_editable(0, true)
	#
	#for child in mat_group.children:
		#build_tree_recursive(child, item)
	
	
func on_filesystem_changed():
	reload_materials()
	pass

func on_resources_reimported(resources: PackedStringArray):
	pass

func on_resources_reload(resources: PackedStringArray):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_new_group():
	pass

func delete_selected_group():
	pass

func rename_selected_group():
	pass

func _on_item_selected():
	var item:TreeItem = get_selected()
	item.get_index()
	pass # Replace with function body.


func _on_item_edited():
	var item:TreeItem = get_edited()
	pass # Replace with function body.


func _on_popup_menu_id_pressed(id:int):
	match id:
		0:
			create_new_group()
		1:
			delete_selected_group()
		2:
			rename_selected_group()
			


func _on_button_clicked(item:TreeItem, column:int, id:int, mouse_button_index:int):
	var checked:bool = !item.is_checked(1)
	item.set_checked(1, checked)
	item.set_button(1, ButtonType.VISIBLE, bn_vis_on if checked else bn_vis_off)

func dir_has_materials(dir:EditorFileSystemDirectory)->bool:
	for i in dir.get_file_count():
		var file_type:StringName = dir.get_file_type(i)
		
		if file_type == "StandardMaterial3D" || file_type == "ORMMaterial3D" || file_type == "ShaderMaterial":
			return true
		
		#var path:String = dir.get_file_path(i)
		#print("check ", path)
		#if !ResourceLoader.exists(path):
			#continue
		#var res:Resource = load(path)
		#print("is Res ")
		#if res is Material:
			#print("is Material! ")
			#return true
	
	return false
	
func dir_has_materials_recursive(dir:EditorFileSystemDirectory)->bool:
	if dir_has_materials(dir):
		return true
	
	for i in dir.get_subdir_count():
		var child_dir:EditorFileSystemDirectory = dir.get_subdir(i)
		if dir_has_materials_recursive(child_dir):
			return true
	
	return false

func collapse_unused_dirs():
	if !plugin:
		return

	var ed_iface:EditorInterface = plugin.get_editor_interface()
	var efs:EditorFileSystem = ed_iface.get_resource_filesystem()

	var root_dir:EditorFileSystemDirectory = efs.get_filesystem()
	collapse_unused_dirs_recursive(root_dir)


func collapse_unused_dirs_recursive(dir:EditorFileSystemDirectory)->bool:
	#print("path ", dir.get_path())
	var item:TreeItem = path_to_tree_item_map[dir.get_path()]
	#print("item ", item.get_text(0))
	var expanded:bool = dir_has_materials(dir)
#	item.collapsed = !dir_has_materials(dir)
	#
	for i in dir.get_subdir_count():
		var child_dir:EditorFileSystemDirectory = dir.get_subdir(i)
		var result:bool = collapse_unused_dirs_recursive(child_dir)
		if result:
			expanded = true
			
	item.collapsed = !expanded
	
	return expanded