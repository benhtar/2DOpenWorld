extends WorldEnvironment

var world_seed = 123
var chunk = preload("res://Instances/Chunk.tscn")
var chunks = [[]]
var chunks_length = Globals.world_length
var chunks_depth = Globals.world_depth

var tile_w = Globals.tile_width
var tile_h = Globals.tile_height
var chunk_w = Globals.chunk_width
var chunk_h = Globals.chunk_height

var chunk_load_thread = Thread.new()

func _ready():
	#randomize()
	for i in range(0, chunks_length):
		chunks.append([])
		#chunks[i] = []
		for j in range(0, chunks_depth):
			chunks[i].append([])
			chunks[i][j] = chunk_new(i, j)

func chunk_new(chunk_x, chunk_y):
	var new_chunk = chunk.instance()
	new_chunk.position = Vector2(chunk_x*chunk_w*tile_w, chunk_y*chunk_h*tile_h)
	new_chunk.set_name("Chunk_"+str(chunk_x)+"_"+str(chunk_y))
	add_child(new_chunk)
	print("added :" + new_chunk.get_name())
	return new_chunk

func chunk_load_soft(chunk_x, chunk_y):
	var c = get_chunk(chunk_x, chunk_y)
	if(c == null):
		print("try loading chunk at y ="+str(chunk_y))
		return
	if (!c.active):
		c.position = Vector2(chunk_x*chunk_w*tile_w, chunk_y*chunk_h*tile_h)
		if(c.generated): 
			c.active = true
			add_child(c)
		else:
			c.generate(get_chunk_x(c.position.x), get_chunk_y(c.position.y), world_seed, true)

func chunk_load_hard(chunk_x, chunk_y):
	var c = get_chunk(chunk_x, chunk_y)
	if(c == null):
		print("try loading chunk at y ="+str(chunk_y))
		return
	if (!c.active):
		c.position = Vector2(chunk_x*chunk_w*tile_w, chunk_y*chunk_h*tile_h)
		if(c.generated): 
			c.active = true
			add_child(c)
		else:
			c.generate(get_chunk_x(c.position.x), get_chunk_y(c.position.y), world_seed, false)

func chunk_unload(chunk_x, chunk_y):
	var c = get_chunk(chunk_x, chunk_y)
	if(c == null):
		print("try unloading chunk at y ="+str(chunk_y))
		return
	if(c.active):
		c.position=Vector2(chunk_x*chunk_w*tile_w, chunk_y*chunk_h*tile_h)
		c.active = false
		remove_child(c)
		#c.queue_free()

func get_chunk(c_x, c_y):
	var chunk_xwrap = wrapf(c_x, 0, chunks_length)
	#check if in map boundaries on y coord (no wrapping on y-axis)
	if(c_y >= chunks_depth || c_y < 0):
		return null
	return chunks[chunk_xwrap][c_y]

func get_tile(tile_x, tile_y):
	var t_x = tile_x % (chunk_w/tile_w)
	var t_y = tile_y % (chunk_h/tile_h)
	var chunk_x = floor(t_x / (chunk_w/tile_w))
	var chunk_xwrap = wrapf(chunk_x, 0, chunks_length)
	var chunk_y = floor(t_y / (chunk_h/tile_h))
	return chunks[chunk_xwrap][chunk_y].get_cell(t_x, t_y)

func get_tile_x (x):
	return floor(x / (chunk_w / tile_w))
func get_tile_y (y):
	return floor(y / (chunk_h / tile_h))
func get_chunk_x(x):
	return floor(x / (chunk_w * tile_w))
func get_chunk_y(y):
	return floor(y / (chunk_h * tile_h))