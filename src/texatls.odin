package main

import rl "vendor:raylib"

Texatls :: struct {
	texture: rl.Texture,
	width, height: f32,
}

texatls_new :: proc(tex: rl.Texture, width, height: f32) -> ^Texatls {
	ta := new(Texatls)

	ta.texture = tex
	ta.width = width
	ta.height = height

	return ta
}

texatls_render :: proc(ta: ^Texatls, out: rl.Rectangle, x, y: int, flip: bool, color := rl.WHITE, rotation: f32 = 0.0) {
	rl.DrawTexturePro(ta.texture, { ta.width * f32(x), ta.height * f32(y), flip ? -ta.width : ta.width, ta.height }, out, { 0.0, 0.0 }, rotation, color)
}