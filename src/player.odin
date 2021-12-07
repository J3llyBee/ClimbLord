package main

import "core:fmt"
import "core:math"

import rl "vendor:raylib"

Player :: struct {
    using entity: Entity,
    ci: f32,
    sprite: ^Texatls,
    flag: rl.Texture,

    vel: vec2,
    jumped: bool,
    flip: bool,
}

GRAVITY: f32 = (2.0 * 36.0) / math.pow_f32(0.5, 2)
JUMPVEL: f32 = math.sqrt(2 * GRAVITY * 36)
TERMVEL: f32 = math.sqrt(math.pow(JUMPVEL, 2) + 2 * GRAVITY)

player_update :: proc(p: ^Player) {
    p.ci += rl.GetFrameTime() * 4
    if p.ci > 4 do p.ci = 0

    tiles := room_get_tiles(gs.room)

    hinp: f32 = (input_is_down("RIGHT") ? 1.0 : 0.0) - (input_is_down("LEFT") ? 1.0 : 0.0)
    vinp: f32 = (input_is_down("DOWN") ? 1.0 : 0.0) - (input_is_down("UP") ? 1.0 : 0.0)

    p.flip = hinp == -1

    p.vel.y = p.vel.y + GRAVITY * rl.GetFrameTime() // Gravity
    p.vel.x = p.vel.x / (1 + 10 * rl.GetFrameTime()) // Friction

    if vinp == -1.0 && entity_on_tile(p, &tiles) {
        p.vel.y = -JUMPVEL
        // rl.PlaySound(load_sound("jump.wav"))
        p.jumped = true
    }

    if vinp == 1.0 && p.vel.y < TERMVEL && p.jumped {
        p.vel.y = TERMVEL
    }

    p.vel.x += 100 * hinp
    p.vel.x = clamp(p.vel.x, -100, 100)
    
    vdir: f32 = math.sign(p.vel.y)
    if p.vel.y != 0 {
        ycol := rl.Rectangle {p.pos.x - p.size.x / 2, p.pos.y, p.size.x, (p.size.y / 2 + 2) * vdir + (p.vel.y * rl.GetFrameTime())}
        sign_rect(&ycol)

        // rl.DrawRectangleRec(ycol, rl.BLACK)
        if entity_check_col(ycol, &tiles) {
            cols := entity_get_cols(ycol, &tiles)
            current := abs(p.pos.y)
            for i in &cols {
                dist := abs(length_between({0, p.pos.y}, {0, i.pos.y}) - (i.size.y / 2 + p.size.y / 2))
                if dist < current {
                    current = dist
                }
            }

            p.vel.y = 0
            p.pos.y += current * vdir
        }
    }

    p.pos.y = p.pos.y + p.vel.y * rl.GetFrameTime()

    hdir: f32 = math.sign(p.vel.x)
    if p.vel.x != 0 {
        xcol := rl.Rectangle {p.pos.x, p.pos.y - p.size.y / 2, p.size.x / 2 * hdir + (p.vel.x * rl.GetFrameTime()), p.size.y}
        sign_rect(&xcol)

        // rl.DrawRectangleRec(xcol, rl.BLACK)
        if entity_check_col(xcol, &tiles) {
            cols := entity_get_cols(xcol, &tiles)
            current := abs(p.pos.x)
            for i in &cols {
                dist := abs(length_between({p.pos.x, 0}, {i.pos.x, 0}) - (i.size.x / 2 + p.size.x / 2))
                if dist < current {
                    current = dist
                }
            }

            p.vel.x = 0
            p.pos.x += current * hdir
        }
    }


    p.pos.x = p.pos.x + p.vel.x * rl.GetFrameTime()
}

player_check_collisions :: proc(p: ^Player) {

}

player_render :: proc(using p: ^Player) {
    // base_render(p, palettes[gs.palette][1])
    // rl.DrawTextureRec(p.sprite[p.ci], {0, 0, p.flip ? -16 : 16, 16}, {pos.x - size.x / 2, pos.y - size.y / 2}, palettes[gs.palette][1])
    texatls_render(p.sprite, {pos.x - size.x / 2 - 1, pos.y - size.y / 2 - 0.5, 16, 16}, int(p.ci), palettes[gs.palette][1])
    rl.DrawTextureRec(p.flag, {0, 0, p.flip ? -16 : 16, 16}, {pos.x - size.x / 2, pos.y - size.y / 2}, palettes[gs.palette][2])
}
// 0.211