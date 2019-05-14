extends Node

enum NoiseType{
		SELECT, MOUNTAINS, HILLS, PLAINS
	}

#holds noise parameters: [octaves, period, persistence, lacunarity]
var params = {
	SELECT = [4, 128, 0.5, 16],
	MOUNTAINS = [4, 32, 0.8, 4],
	HILLS = [4, 128, 0.7, 16],
	PLAINS = [4, 512, 0.5, 64]
	}

func get_noise(w_seed, type):
	var noise = OpenSimplexNoise.new()
	noise.seed = w_seed
	noise.octaves = params.get(type)[0]
	noise.period = params.get(type)[1]
	noise.persistence = params.get(type)[2]
	noise.lacunarity = params.get(type)[3]
	return noise