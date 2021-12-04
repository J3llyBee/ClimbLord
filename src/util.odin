package main

import rl "vendor:raylib"

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