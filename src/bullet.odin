package main

// import "core:fmt"
import "core:math"
import "core:slice"

import rl "vendor:raylib"


Bullet :: struct {
    using entity: Entity,
    vel: vec2,

    ci: f32,
    sprite: ^Texatls,
}

bullet_new :: proc(vel: vec2) -> ^Bullet {
    b := new(Bullet)

    b.entity = {gs.player.pos, {8, 8}} 
    b.vel = vel
    b.sprite = texatls_new(load_texture("player/flag.png"), 8, 8)

    return b
}

bullet_update :: proc(using e: ^Bullet) {
    tiles := room_get_tiles(gs.room)
    enemies := gs.enemies[:]

    e.ci += rl.GetFrameTime() * 15
    if e.ci > 7 do e.ci = 0

    // rl.DrawRectangleRec(entity_get_rect(e), rl.BLACK)

    hdir: f32 = math.sign(vel.x)
    if vel.x != 0 {
        xcol := rl.Rectangle {pos.x, pos.y - size.y / 2, size.x / 2 * hdir + (vel.x * rl.GetFrameTime()) - (hdir * 3), size.y}
        sign_rect(&xcol)

        // rl.DrawRectangleRec(xcol, rl.BLACK)
        if entity_check_col(xcol, &tiles) {
            i, suc := slice.linear_search(gs.player.bullets[:], e)

            if suc do unordered_remove(&gs.player.bullets, i)
        }

        
        if entity_check_col(xcol, &enemies) {
            i, suc := slice.linear_search(gs.player.bullets[:], e)
            if suc do unordered_remove(&gs.player.bullets, i)

            cols := entity_get_cols(xcol, &enemies)

            i, suc = slice.linear_search(enemies, cols[0])
            if suc {
                unordered_remove(&gs.enemies, i) 
                rl.PlaySound(enemydie_sfx) 
            } 
        }
    }


    pos.x = pos.x + vel.x * rl.GetFrameTime()
}