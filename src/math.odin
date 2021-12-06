package main

import "core:math"

vec2 :: distinct [2]f32

length_between :: proc(a, b: vec2) -> f32 {
	return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2))
}