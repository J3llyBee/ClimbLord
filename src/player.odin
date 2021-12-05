package main

import "core:fmt"

import rl "vendor:raylib"

jump_cooldown: f32 = 0.05

Player :: struct {
    using entity: Entity,
    flag: Entity,
}

player_update :: proc(p: ^Player) {
    tiles := gs.room[:]

    hspd: f32 = 0
    hdir: f32 = (input_is_down("RIGHT") ? 1.0 : 0.0) - (input_is_down("LEFT") ? 1.0 : 0.0)
    vdir: f32 = (input_is_down("DOWN") ? 1.0 : 0.0) - (input_is_down("UP") ? 1.0 : 0.0)

    // hspd += 100 * hdir * rl.GetFrameTime()

    p.pos.x += 100 * hdir * rl.GetFrameTime()

    jump_cooldown -= rl.GetFrameTime()


    if vdir == -1 && entity_on_tile(p, &tiles) && jump_cooldown < 0 {
        jump_cooldown = 0.05
        vel += -100
    } else if entity_on_tile(p, &tiles) {
        vel = 0
    }

    if !entity_on_tile(p, &tiles) {
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
                p.pos.x += i.width * (p.pos.x - i.x > 0.0 ? 1.0 : -1.0)

                dx = true
            } else if !dy {
                p.pos.y += i.height * (p.pos.y - i.y > 0.0 ? 1.0 : -1.0)

                dy = true
            }
        }
    }

    p.flag.pos = p.pos
}
// 0.211