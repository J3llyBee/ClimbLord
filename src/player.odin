package main

import rl "vendor:raylib"

Player :: struct {
    using entity: Entity,
}

player_update :: proc(using player: ^Player) {
    hspd: f32 =  (rl.IsKeyDown(rl.KeyboardKey.D) ? 1.0 : 0.0) - (rl.IsKeyDown(rl.KeyboardKey.A) ? 1.0 : 0.0)
    pos.x += 100 * hspd * rl.GetFrameTime()
    if !entity_check_col(player, &t) {
        pos.y += gravity * rl.GetFrameTime()
    }
}

player_render :: proc(using player: ^Player) {
    rl.DrawTexture(sprite, i32(pos.x), i32(pos.y), rl.WHITE)
}