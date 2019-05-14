extends Camera2D

var world
export (int) var hard_load_radius_x = 3
export (int) var hard_load_radius_y = 3
export (int) var soft_load_radius_x = 2
export (int) var soft_load_radius_y = 2
export (int) var unload_radius_x = 5
export (int) var unload_radius_y = 5
export var camspeed = 10

var chunk_load_thread = Thread.new()

func _ready():
	world = get_parent()

func _process(delta):
	if Input.is_action_pressed("ui_up"):    translate(Vector2( 0, -camspeed)*delta)
	if Input.is_action_pressed("ui_down"):  translate(Vector2( 0,  camspeed)*delta)
	if Input.is_action_pressed("ui_left"):  translate(Vector2(-camspeed,  0)*delta)
	if Input.is_action_pressed("ui_right"): translate(Vector2( camspeed,  0)*delta)
	print(str(world.get_chunk_x(position.x), ", ", world.get_chunk_y(position.y)))
	#if(!chunk_load_thread.is_active()):
	#	chunk_load_thread.start(self, "update_chunks") #thread start here
	update_chunks(null)

func update_chunks(userdata):
	var chunk_x = world.get_chunk_x(position.x)
	var chunk_y = world.get_chunk_y(position.y)
	#var load_radius_x = max(hard_load_radius_x, soft_load_radius_x)+1
	#var load_radius_y = max(hard_load_radius_y, soft_load_radius_y)+1
	
	for i in range(-unload_radius_x-1, unload_radius_x+1):
		for j in range(-unload_radius_y-1, unload_radius_y+1):
			if(chunk_y+j < 0 || chunk_y+j >= world.chunks_depth): continue
			if(abs(i) < hard_load_radius_x && abs(j) < hard_load_radius_y): world.chunk_load_hard(chunk_x+i,chunk_y+j)
			elif(abs(i) < soft_load_radius_x && abs(j) < soft_load_radius_y): world.chunk_load_soft(chunk_x+i,chunk_y+j)
			elif(abs(i) >= unload_radius_x && abs(i) >= unload_radius_y): world.chunk_unload(chunk_x+i,chunk_y+j)
			yield(get_tree(), "idle_frame")
	#chunk_load_thread.wait_to_finish()
	return 0

func update_chunks_better():
	var chunk_x = world.get_chunk_x(position.x)
	var chunk_y = world.get_chunk_y(position.y)
	var chunk_list = []
	var position = self.position
	for i in range(-unload_radius_x-1, unload_radius_x+1):
		for j in range(-unload_radius_y-1, unload_radius_y+1):
			chunk_list.append(world.get_chunk(chunk_x+i, chunk_y+j))
	
	chunk_list = sort_by_distance(chunk_list, self.position)
	for c in chunk_list:
		if(c != null):
			var c_pos = c.get_chunk_coord()
			if(distance(c, position) < hard_load_radius_x): world.chunk_load_hard(c_pos.x,c_pos.y)
			elif(distance(c, position) < soft_load_radius_x): world.chunk_load_soft(c_pos.x,c_pos.y)
			elif(distance(c, position) >= unload_radius_x): world.chunk_unload(c_pos.x,c_pos.y)
			yield(get_tree(), "idle_frame")

func distance(chunk, pos):
	var res = (chunk.position - pos)
	res.x /= (world.tile_w*world.chunk_w)
	res.y /= (world.tile_h*world.chunk_h)
	return floor(res.length())

func sort_by_distance(chunks, pos):
	var res = []
	var distances = []
	for c in chunks:
		if(c != null):
			var distance = (c.position - pos).length()
			if(res.size() == 0):
				res.append(c)
				distances.append(distance)
			else:
				for i in range(distances.size()):
					if (distances[i] >= distance):
						res.insert(i, c)
						distances.insert(i, distance)
	return res