package main

import "core:fmt"
import "core:time"

import rl "vendor:raylib"

p := Player {}
t := Tile {}
gravity: f32 = 100

main :: proc() {
    rl.InitWindow(224 * 4, 224 * 4, "ClimbLord")

    p.pos = {0, 0}
    p.sprite = rl.LoadTexture("./amon.png")
    p.size = {f32(p.sprite.width), f32(p.sprite.height)}

    t.pos = {0, 100}
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
 
    player_render(&p)
    player_update(&p)
    tile_render(&t)

    rl.EndDrawing()
}