package main

import "core:fmt"
import "core:time"

import rl "vendor:raylib"

p := Player {}
t := Tile {}
gravity: f32 = -100
vel: f32 = 0

main :: proc() {
    rl.InitWindow(224 * 4, 224 * 4, "ClimbLord")

    p.pos = {100, 400}
    p.sprite = rl.LoadTexture("./amon.png")
    p.size = {f32(p.sprite.width), f32(p.sprite.height)}

    t.pos = {100, 100}
    t.sprite = rl.LoadTexture("./tile.png")
    t.size = {f32(t.sprite.width), f32(t.sprite.height)}

    for !rl.WindowShouldClose() {
        rl.PollInputEvents()

        update()
    }
}

update :: proc() {
    rl.BeginDrawing()

    rl.ClearBackground(rl.WHITE)
 
    entity_render(&p)
    entity_render(&t)

    player_update(&p)

    rl.EndDrawing()
}