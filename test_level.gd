extends Node3D

func add_point(arr:PackedVector3Array):
	arr.append(Vector3(4, 5, 6))
	
func test_planes():
	var p0:Plane = Plane(1, 0, 0, 6)
	var p1:Plane = Plane(1, 0, 0, 6)

	var planes:Array[Plane] = []
	planes.append(p0)
	
	print("has %s" % [planes.has(p1)])
	
	print("has2 %s" % planes.any(func(p): return p.is_equal_approx(p1)))


# Called when the node enters the scene tree for the first time.
func _ready():
	
	await get_tree().process_frame

	test_planes()


	var points:PackedVector3Array
	points.append(Vector3(0, 0, 0))	
	points.append(Vector3(0, 0, 1))	
	points.append(Vector3(0, 1, 0))	
	points.append(Vector3(0, 1, 1))	
	points.append(Vector3(1, 0, 0))	
	points.append(Vector3(1, 0, 1))	
	points.append(Vector3(1, 1, 0))	
	points.append(Vector3(1, 1, 1))	
	points.append(Vector3(2, 1, 1))	
	points.append(Vector3(2, 2, 3))	

	var qh:QuickHull = QuickHull.new()
	var hull:QuickHull.Hull = qh.quickhull(points)
#	print(hull)
	print(hull.format_points())
	
	pass

	
	#var result:IntersectResults = $CyclopsBlocks.intersect_ray_closest($Marker3D.transform.origin, $Marker3D.transform.basis.z)
	#var result:IntersectResults = $CyclopsBlocks.intersect_ray_closest(Vector3(-2.827666, 11.78138, -14.39898), Vector3(0.703937, -0.382888, 0.598221))
	
	#print(result)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
