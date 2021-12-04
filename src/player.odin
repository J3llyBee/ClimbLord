package main

import "core:fmt"

import rl "vendor:raylib"

Player :: struct {
    using entity: Entity,
}

player_update :: proc(p: ^Player) {
    hdir: f32 = (rl.IsKeyDown(rl.KeyboardKey.D) ? 1.0 : 0.0) - (rl.IsKeyDown(rl.KeyboardKey.A) ? 1.0 : 0.0)
    vdir: f32 = (rl.IsKeyDown(rl.KeyboardKey.S) ? 1.0 : 0.0) - (rl.IsKeyDown(rl.KeyboardKey.W) ? 1.0 : 0.0)

    p.pos.x += 100 * hdir * rl.GetFrameTime()

    if !rl.CheckCollisionPointRec({p.pos.x, p.pos.y + p.size.y + 1}, entity_get_rec(&t)) {
        vel += gravity * rl.GetFrameTime()
    }
    if vdir == -1 && rl.CheckCollisionPointRec({p.pos.x, p.pos.y + p.size.y + 1}, entity_get_rec(&t)) {
        vel += -5000 * rl.GetFrameTime()
    }
    
    p.pos.y += vel * rl.GetFrameTime()

    if entity_check_col(p, &t) {
        col := entity_get_col_rec(p, &t)

        rl.DrawRectangleRec(col, rl.BLACK)

        if abs(col.width) < abs(col.height) {
            p.pos.x += col.width * (p.pos.x - col.x > 0.0 ? 1.0 : -1.0)
        } else {
            p.pos.y += col.height * (p.pos.y - col.y > 0.0 ? 1.0 : -1.0)
        }
    }
}
// 0.211