package main

import rl "vendor:raylib"
import "core:math"

load_texture :: proc($path: string) -> rl.Texture2D {
	data := #load("../res/" + path)
	return rl.LoadTextureFromImage(rl.LoadImageFromMemory(".png", &data[0], i32(len(data))))
}

coinflip :: proc(a, b: int) -> int {
	return rl.GetRandomValue(0, 1) == 1 ? a : b
}

hexcol :: #force_inline proc(x: u32) -> (res: rl.Color) {
	res.r = u8((x & 0xFF000000) >> 24)
	res.g = u8((x & 0x00FF0000) >> 16)
	res.b = u8((x & 0x0000FF00) >> 8)
	res.a = u8(x & 0x000000FF)
	
	return
}

check_room :: proc(x, i: int) {
    for a in 0..<len(gs.room) {
        if gs.room[a].pos.x == (16 * f32(x) + 8) && gs.room[a].pos.y == 216 - f32(i) * 16 {
            ordered_remove(&gs.room, a)
        }
    }
}

length_between :: proc(a, b: vec2) -> f32 {
	return math.sqrt_f32(math.pow_f32((a.x - b.x), 2) + math.pow_f32((a.y - b.y), 2))
}