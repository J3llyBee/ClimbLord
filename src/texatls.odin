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

texatls_render :: proc(ta: ^Texatls, out: rl.Rectangle, ci: int, color := rl.WHITE) {
	rl.DrawTexturePro(ta.texture, { ta.width * f32(ci), 0, ta.width, ta.height }, out, { 0.0, 0.0 }, 0.0, color)
}