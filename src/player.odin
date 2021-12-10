package main

// import "core:fmt"
import "core:math"
import "core:fmt"
import vm "core:math/linalg/glsl"

import rl "vendor:raylib"

Player :: struct {
    using entity: Entity,
    sprite: []^Texatls,

    bullets: [dynamic]^Bullet,
    bullet_cooldown: f32,

    ci: f32,
    ca: int,

    vel: vec2,
    jumped: bool,
    flip: bool,
}

GRAVITY: f32 = (2.0 * 36.0) / math.pow_f32(0.5, 2)
JUMPVEL: f32 = math.sqrt(2 * GRAVITY * 36)
TERMVEL: f32 = math.sqrt(math.pow(JUMPVEL, 2) + 2 * GRAVITY)

player_update :: proc(p: ^Player) {
    tiles := room_get_tiles(gs.room)

    p.bullet_cooldown -= rl.GetFrameTime()

    hinp: f32 = (input_is_down("RIGHT") ? 1.0 : 0.0) - (input_is_down("LEFT") ? 1.0 : 0.0)
    vinp: f32 = (input_is_down("DOWN") ? 1.0 : 0.0) - (input_is_down("UP") ? 1.0 : 0.0)

    anispd: f32
    frames: f32

    if p.bullet_cooldown > 0.0 {
        anispd = 14
        frames = 9
        p.ca = 3    
    } else if !entity_on_tile(p, &tiles) {
        anispd = 1
        frames = 1
        p.ca = 2
    } else if hinp == 0.0 {
        anispd = 4
        frames = 4
        p.ca = 0
    } else {
        if p.ca != 1 do p.ci = 0
        anispd = 15
        frames = 4
        p.ca = 1
    }


    p.ci += rl.GetFrameTime() * anispd
    if p.ci > frames do p.ci = 0

    if hinp != 0 do p.flip = hinp == -1

    p.vel.y = p.vel.y + GRAVITY * rl.GetFrameTime() // Gravity
    p.vel.x = p.vel.x / (1 + 10 * rl.GetFrameTime()) // Friction

    if vinp != -1.0 && entity_on_tile(p, &tiles) {
        p.jumped = false
    }

    if vinp == -1.0 && entity_on_tile(p, &tiles) && !p.jumped {
        p.vel.y = -JUMPVEL
        rl.PlaySound(jump_sfx)
        p.jumped = true
    }

    if vinp == 1.0 && p.vel.y < TERMVEL && p.jumped {
        p.vel.y = TERMVEL
    }

    p.vel.x += 60 * hinp
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

            p.vel.x = 0
            p.pos.x += current * hdir
        }
    }


    p.pos.x = p.pos.x + p.vel.x * rl.GetFrameTime()

    bh: f32 = (input_is_down("S_RIGHT") ? 1.0 : 0.0) - (input_is_down("S_LEFT") ? 1.0 : 0.0)

    if (bh != 0) && p.bullet_cooldown <= 0.0 {
        fmt.println(gs.score)
        rl.PlaySound(shoot_sfx)
        // bvel: vec2 = ({bh * 0.7, bv * 0.7} + (p.vel == {0.0, 0.0} ? {0.0, 0.0} : vm.normalize(p.vel) * 0.3)) * 100
        bvel: vec2 = {bh, 0} * 100

        // fmt.println(vec2 {bh * 0.7, bv * 0.7})
        // fmt.println(vm.normalize(p.vel) * 0.3)
        // fmt.println(p.vel)
        // fmt.println(bvel)

        append(&p.bullets, bullet_new(bvel))
        p.bullet_cooldown = 0.56


    }
    if p.pos.y > gs.camera.target.y + 240 + p.size.y / 2 {
        rl.PlaySound(playerdie_sfx)
        gs.state = .DEAD
    }
}

player_check_collisions :: proc(p: ^Player) {

}

player_render :: proc(using p: ^Player) {
    texatls_render(sprite[ca], {pos.x - size.x / 2 - 1, pos.y - size.y / 2 - 0.5, 16, 16}, int(p.ci), 0, flip, palettes[gs.palette][1])
    texatls_render(sprite[ca], {pos.x - size.x / 2 - 1, pos.y - size.y / 2 - 0.5, 16, 16}, int(p.ci), 1, flip, palettes[gs.palette][2])
}
// 0.211