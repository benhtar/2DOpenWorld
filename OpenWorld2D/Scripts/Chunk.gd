extends TileMap

var noise
#var noise = OpenSimplexNoise.new()
#var period = 800
#var octaves = 8
#var persistence = 0.88
#var lacunarity = 80
var generated = false
var active = false

enum type {
	DIRT, STONE, EMPTY
	}

var surface_line = 0
var dirt_amplitude = 0.8
var dirt_frequency = 1000
var width = Globals.chunk_width
var height = Globals.chunk_height
var tile_w = Globals.tile_width
var tile_h = Globals.tile_height
var world_length = Globals.world_length * width * tile_w

func init():
	#tile_w = get_parent().tile_w
	#tile_h = get_parent().tile_h
	#width = get_parent().chunk_w
	#height = get_parent().chunk_h
	#world_length = get_parent().chunks_length * width * tile_w
	pass

func generate(chunk_x, chunk_y, w_seed, soft):
	#init()
	noise = $TerrainNoise.get_noise(w_seed, "PLAINS")
	var current_x = chunk_x * width * tile_w
	var current_y = chunk_y * height * tile_h
	if(chunk_y <= 2):
		for x in range(width):
			if(soft): yield(get_tree(),"idle_frame")
			var surface = get_noise_1d(x*tile_w+current_x, -current_y+surface_line, dirt_amplitude, dirt_frequency)
			for yy in range(height):
				if (yy > surface): set_cell(x,yy,type.DIRT)
	else:
		for x in range(width):
			if(soft): yield(get_tree(),"idle_frame")
			for y in range(height):
				set_cell(x,y,type.STONE)
	
	generated = true
	active = true

func get_noise_1d(x, y, y_amplitude, y_frequency):
	var res = y + floor(((get_height(x,y_frequency)+1)/2)*height)*y_amplitude
	return res

func get_height(x, y_frequency):
	#noise range
	var x1=0; var x2=1
	#var y1=0; var y2=1
	var dx = x2 - x1; #var dy = y2 - y1
	#sample noise at smaller intervals
	var s = x/world_length
	#var t = y/(tile_h*height)
	#compute 2D circle coordinate for 1D wrapping
	var nx = x1 + cos(s*2*PI) * dx / (2*PI)
	var ny = x1 + sin(s*2*PI) * dx / (2*PI)
	return noise.get_noise_2dv(Vector2(nx, ny)*y_frequency)

func get_chunk_coord():
	var res = Vector2(self.position.x/(tile_w*width), self.position.y/(tile_h*height))
	return res