package main

import "core:fmt"
import "core:math"
import "core:slice"

import rl "vendor:raylib"


Bullet :: struct {
	using entity: Entity,
	vel: vec2,
	sprite: rl.Texture2D,
}

bullet_new :: proc(vel: vec2) -> ^Bullet {
	b := new(Bullet)

	b.entity = {gs.player.pos, {8, 8}} 
	b.vel = vel
	b.sprite = load_texture("bullet.png")


	return b
}

bullet_update :: proc(using e: ^Bullet) {
	tiles := room_get_tiles(gs.room)
	enemies := gs.enemies[:]

    hdir: f32 = math.sign(vel.x)
    if vel.x != 0 {
        xcol := rl.Rectangle {pos.x, pos.y - size.y / 2, size.x / 2 * hdir + (vel.x * rl.GetFrameTime()), size.y}
        sign_rect(&xcol)

        // rl.DrawRectangleRec(xcol, rl.BLACK)
        if entity_check_col(xcol, &tiles) {
        	i, suc := slice.linear_search(gs.player.bullets[:], e)

        	if suc do unordered_remove(&gs.player.bullets, i)
        }

        
        if entity_check_col(xcol, &enemies) {
        	i, suc := slice.linear_search(gs.player.bullets[:], e)
        	if suc do unordered_remove(&gs.player.bullets, i)

        	cols := entity_get_cols(entity_get_rect(e), &enemies)

        	i, suc = slice.linear_search(gs.enemies[:], cols[0])
        	if suc do unordered_remove(&gs.enemies, i)
        }
    }


    pos.x = pos.x + vel.x * rl.GetFrameTime()

    vdir: f32 = math.sign(vel.y)
    if vel.y != 0 {
        ycol := rl.Rectangle {pos.x - size.x / 2, pos.y, size.x, (size.y / 2 + 2) * vdir + (vel.y * rl.GetFrameTime())}
        sign_rect(&ycol)

        // rl.DrawRectangleRec(ycol, rl.BLACK)
        if entity_check_col(ycol, &tiles) {
	     	i, suc := slice.linear_search(gs.player.bullets[:], e)
	    	if suc do unordered_remove(&gs.player.bullets, i)       	
        }
    }

    pos.y = pos.y + vel.y * rl.GetFrameTime()
}