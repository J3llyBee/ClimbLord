package main

import "core:math"
import vm "core:math/linalg/glsl"

import rl "vendor:raylib"


EnemyType :: enum {
	WALKER = 3,
	GHOST,
}

Enemy :: struct {
	using entity: Entity,
	vel: vec2,
	type: EnemyType,

	ci: f32,
	sprite: ^Texatls,
}

enemy_sprites: map[EnemyType]^Texatls

enemy_new :: proc(pos: vec2, type: EnemyType) -> ^Enemy {
	e := new(Enemy)
	
	e.type = type
	e.entity = {pos, {16, 16}}
	e.sprite = enemy_sprites[type]

	return e
}

enemy_update :: proc(using p: ^Enemy) {
	tiles := room_get_tiles(gs.room)

	p.ci += rl.GetFrameTime() * 7
    if p.ci > 4 do p.ci = 0

	#partial switch type {
		case .GHOST:
			if length_between(gs.player.pos, pos) < 50 {
				dir := vm.normalize(gs.player.pos - pos)

				pos += dir * 60 * rl.GetFrameTime()
			}
		case .WALKER:
			if p.vel.x == 0.0 do p.vel.x = 100
			p.vel.y = p.vel.y + GRAVITY * rl.GetFrameTime()

		    vdir: f32 = math.sign(p.vel.y)
		    if p.vel.y != 0 {
		        ycol := rl.Rectangle {p.pos.x - p.size.x / 2, p.pos.y, p.size.x, (p.size.y / 2 + 2) * vdir + (p.vel.y * rl.GetFrameTime())}
		        sign_rect(&ycol)

		        // rl.DrawRectangleRec(ycol, rl.BLACK)
		        if entity_check_col(ycol, &tiles) {
		            cols := entity_get_cols(ycol, &tiles)
		            current := abs(p.pos.y)
		            for i in &cols {
		                dist := length_between({0, p.pos.y}, {0, i.pos.y}) - (i.size.y / 2 + p.size.y / 2)
		                if dist < current {
		                    current = dist
		                }
		            }

		            p.vel.y = 0
		            p.pos.y += current * vdir - 0.1 * vdir
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
		                dist := length_between({p.pos.x, 0}, {i.pos.x, 0}) - (i.size.x / 2 + p.size.x / 2)
		                if dist < current {
		                    current = dist
		                }
		            }

		            p.vel.x *= -1
		            // p.pos.x += current * hdir
		        }
		    }


		    p.pos.x = p.pos.x + p.vel.x * rl.GetFrameTime()			
	}
}