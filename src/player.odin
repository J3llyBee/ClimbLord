package main

import "core:fmt"

import rl "vendor:raylib"

Player :: struct {
    using entity: Entity,
}


player_update :: proc(p: ^Player) {
    hspd: f32 =  (rl.IsKeyDown(rl.KeyboardKey.D) ? 1.0 : 0.0) - (rl.IsKeyDown(rl.KeyboardKey.A) ? 1.0 : 0.0)
    p.pos.x += 100 * hspd * rl.GetFrameTime()
    p.pos.y += gravity * rl.GetFrameTime()

    if entity_check_col(p, &t) {
        col := entity_get_col_rec(p, &t)

        if abs(col.width) < abs(col.height) {
            p.pos.x += col.width * (p.pos.x == col.x ? 1.0 : -1.0)
        } else {
            p.pos.y += col.height * (p.pos.y == col.y ? 1.0 : -1.0)
        }
    }
}

player_render :: proc(using p: ^Player) {
    rl.DrawTexture(sprite, i32(pos.x), i32(pos.y), rl.WHITE)
} 
// 0.211