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
class_name ActionConvertToMesh
extends CyclopsAction

const ACTION_ID:String = "convert_to_mesh"

func _get_action_id():
	return ACTION_ID


#func _init(plugin:CyclopsLevelBuilder, name:String = "", accellerator:Key = KEY_NONE):
	#super._init(plugin, "Convert To Godot Mesh")

func _init():
	name = "Convert To Godot Mesh"

func _execute(event:CyclopsActionEvent):
	var plugin:CyclopsLevelBuilder = event.plugin
	var root:Node = plugin.get_editor_interface().get_edited_scene_root()
	
	var ed_sel:EditorSelection = EditorInterface.get_selection()
	var sel_nodes:Array[Node] = ed_sel.get_selected_nodes()
	
	if sel_nodes.is_empty():
		#error_string("No nodes selected")
		return

	#var branch_to_clone:Node = sel_nodes[0]
	#var root = branch_to_clone.get_parent()
	
	var converted_branch:Node3D = clone_branch(root)
	if converted_branch:
		converted_branch.name = GeneralUtil.find_unique_name(root, "converted_blocks")
		root.add_child(converted_branch)
		
		set_owner_recursive(converted_branch, plugin.get_editor_interface().get_edited_scene_root())
	
	pass

func set_owner_recursive(node:Node3D, new_owner):
	node.owner = new_owner
	for child in node.get_children():
		if child is Node3D:
			set_owner_recursive(child, new_owner)

func clone_branch(node:Node3D)->Node3D:
	if node is CyclopsBlock:
		if !EditorInterface.get_selection().get_selected_nodes().has(node):
			return null
		
		var block:CyclopsBlock = node
		var name_root:String = block.name
		
		var new_node:Node3D = Node3D.new()
		new_node.name = name_root
		new_node.transform = node.transform
		new_node.set_meta("_edit_group_", true)
#		new_node.owner = plugin.get_editor_interface().get_edited_scene_root()

		var new_mesh_node:MeshInstance3D = block.mesh_instance.duplicate()
		new_mesh_node.name = name_root + "_mesh"
#		new_mesh_node.owner = plugin.get_editor_interface().get_edited_scene_root()
		new_node.add_child(new_mesh_node)
		

		var vol:ConvexVolume = ConvexVolume.new()
		vol.init_from_convex_block_data(block.block_data)
		

		var collision_body:PhysicsBody3D
		
		match block.collision_type:
			Collision.Type.STATIC:
				collision_body = StaticBody3D.new()
			Collision.Type.KINEMATIC:
				collision_body = CharacterBody3D.new()
			Collision.Type.RIGID:
				collision_body = RigidBody3D.new()

		if collision_body:
		
#			collision_body.owner = plugin.get_editor_interface().get_edited_scene_root()
			collision_body.name = name_root + "_col"
			collision_body.collision_layer = block.collision_layer
			collision_body.collision_mask = block.collision_mask
			new_node.add_child(collision_body)
			
			var collision_shape:CollisionShape3D = CollisionShape3D.new()
#			collision_shape.owner = plugin.get_editor_interface().get_edited_scene_root()
			collision_body.add_child(collision_shape)
			collision_shape.name = name_root + "_col_shp"
				
			var shape:ConvexPolygonShape3D = ConvexPolygonShape3D.new()
			shape.points = vol.get_points()
			collision_shape.shape = shape

		return new_node
		
	else:
		var new_node:Node3D = Node3D.new()

		new_node.transform = node.transform
		new_node.name = node.name
		for child in node.get_children():
			if branch_is_valid(child):
				var child_branch:Node3D = clone_branch(child)
				if child_branch:
					new_node.add_child(child_branch)
		if new_node.get_child_count() == 0:
			return null
		return new_node

func branch_is_valid(node:Node)->bool:
	if node is CyclopsBlock:
		return true
	
	for child in node.get_children():
		if child is Node3D and branch_is_valid(child):
			return true
	
	return false
