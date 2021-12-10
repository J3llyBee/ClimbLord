package main

import rl "vendor:raylib"
// import "core:fmt"

UI :: struct {
	using entity: Entity,
	sprite: rl.Texture2D,
	fn: proc(),
}

button_update :: proc(e: ^UI) {
	if rl.IsMouseButtonDown(.LEFT) && rl.CheckCollisionPointRec({f32(rl.GetMouseX() / 4), f32(rl.GetMouseY() / 4 + i32(gs.camera.target.y))}, entity_get_rect(e)) {
		e.fn()
	}
	// rl.DrawRectangleRec(entity_get_rect(e), rl.BLACK)
	rl.DrawCircle(rl.GetMouseX() / 4, rl.GetMouseY() / 4 + i32(gs.camera.target.y), 2, rl.BLACK)
}

button_render :: proc(using e: ^UI) {
	rl.DrawTexture(sprite, i32(pos.x / 2), i32(pos.y / 2), rl.WHITE)
}