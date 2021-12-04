package main

import "core:fmt"

import rl "vendor:raylib"

Player :: struct {
    using entity: Entity,
}

player_update :: proc(p: ^Player) {
    hdir: f32 = (input_is_down("RIGHT") ? 1.0 : 0.0) - (input_is_down("LEFT") ? 1.0 : 0.0)
    vdir: f32 = (input_is_down("DOWN") ? 1.0 : 0.0) - (input_is_down("UP") ? 1.0 : 0.0)

    p.pos.x += 100 * hdir * rl.GetFrameTime()

    if !entity_on_tile(p, &tiles) {
        vel += gravity * rl.GetFrameTime()
    }
    if vdir == -1 && entity_on_tile(p, &tiles) {
        vel += -10000 * rl.GetFrameTime()
    } else if vdir == 1 {
        vel += gravity * rl.GetFrameTime()
        vel += gravity * rl.GetFrameTime()
    }

    p.pos.y += vel * rl.GetFrameTime()

    dx := false
    dy := false

    if entity_check_col(p, &tiles) {
        cols := entity_get_col_rec(p, &tiles)

        for i in &cols {
            rl.DrawRectangleRec(i, rl.BLACK)

            if abs(i.width) < abs(i.height) && !dx {
                p.pos.x += i.width * (p.pos.x - i.x > 0.0 ? 1.0 : -1.0) - 1

                dx = true
            } else if !dy {
                p.pos.y += i.height * (p.pos.y - i.y > 0.0 ? 1.0 : -1.0) - 1

                dy = true
            }
        }
    }
}
// 0.211