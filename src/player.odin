package main

import "core:fmt"

import rl "vendor:raylib"

jump_cooldown: f32 = 0.05

Player :: struct {
    using entity: Entity,
    vel: vec2,
    flag: Entity,
}

player_update :: proc(p: ^Player) {
    tiles := room_get_tiles(gs.room)

    hdir: f32 = (input_is_down("RIGHT") ? 1.0 : 0.0) - (input_is_down("LEFT") ? 1.0 : 0.0)
    vdir: f32 = (input_is_down("DOWN") ? 1.0 : 0.0) - (input_is_down("UP") ? 1.0 : 0.0)

    p.vel.x = 0
    p.vel.x += 100 * hdir * rl.GetFrameTime()

    if p.vel.x != 0 {
        xcol := rl.Rectangle {p.pos.x, p.pos.y - p.size.y / 2, p.vel.x + (p.size.x * hdir), p.size.y}
        sign_rect(&xcol)
        rl.DrawRectangleRec(xcol, rl.BLACK)
        if rect_check_col(xcol, &tiles) {
            cols := rect_get_col_rec_multi(xcol, &tiles)
            current := abs(p.vel.x)
            for i in &cols {
                dist := length_between({p.pos.x, 0}, {i.pos.x, 0}) - (i.size.x / 2 + p.size.x / 2)
                if dist < current {
                    current = dist
                }
            }
            p.vel.x = current * hdir
        }
    }
    p.pos.x += p.vel.x

    p.vel.y = 0
    p.vel.y += 100 * vdir * rl.GetFrameTime()

    if p.vel.y != 0 {
        ycol := rl.Rectangle {p.pos.x - p.size.x / 2, p.pos.y, p.size.x, p.vel.y + (p.size.y * vdir)}
        sign_rect(&ycol)
        rl.DrawRectangleRec(ycol, rl.BLACK)
        if rect_check_col(ycol, &tiles) {
            cols := rect_get_col_rec_multi(ycol, &tiles)
            current := abs(p.vel.y)
            for i in &cols {
                dist := length_between({0, p.pos.y}, {0, i.pos.y}) - (i.size.y / 2 + p.size.y / 2)
                if dist < current {
                    current = dist
                }
            }
            p.vel.y = current * vdir
        }
    }
    p.pos.y += p.vel.y

    // jump_cooldown -= rl.GetFrameTime()

    // if vdir == -1 && entity_on_tile(p, &tiles) && jump_cooldown < 0 {
    //     jump_cooldown = 0.05
    //     vel += -100
    // } else if entity_on_tile(p, &tiles) {
    //     vel = 0
    // }

    // if !entity_on_tile(p, &tiles) {
    //     vel += gravity * rl.GetFrameTime()
    // }
    // dx := false
    // dy := false

    // if entity_check_col(p, &tiles) {
    //     cols := entity_get_col_rec(p, &tiles)

    //     for i in &cols {
    //         rl.DrawRectangleRec(i, rl.BLACK)

    //         if abs(i.width) < abs(i.height) && !dx {
    //             p.pos.x += i.width * (p.pos.x - i.x > 0.0 ? 1.0 : -1.0)

    //             dx = true
    //         } else if !dy {
    //             p.pos.y += i.height * (p.pos.y - i.y > 0.0 ? 1.0 : -1.0)

    //             dy = true
    //         }
    //     }
    // }

    p.flag.pos = p.pos
}
// 0.211