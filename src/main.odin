package main

import "core:fmt"
import "core:time"

import rl "vendor:raylib"

p := Player {}
t := Tile {}

tiles: []Tile
camera: rl.Camera2D

room: [10][10]Maybe(Tile)

gravity: f32 = 400
vel: f32 = 0

main :: proc() {
    rl.InitWindow(224 * 4, 224 * 4, "ClimbLord")
    camera.zoom = 2

    tiles = []Tile{ tile_new({100, 100}, load_texture("tile.png")), tile_new({140, 100}, load_texture("tile.png")), tile_new({180, 100}, load_texture("tile.png")), tile_new({220, 60}, load_texture("tile.png")), tile_new({220, 100}, load_texture("tile.png")) }

    p.pos = {100, 0}
    p.sprite = load_texture("amon.png")
    p.size = {f32(p.sprite.width), f32(p.sprite.height)}

    t.pos = {100, 100}
    t.sprite = load_texture("tile.png")
    t.size = {f32(t.sprite.width), f32(t.sprite.height)}

    for !rl.WindowShouldClose() {
        rl.PollInputEvents()

        update()
    }
}

update :: proc() {
    rl.BeginDrawing()
    rl.BeginMode2D(camera)

    rl.ClearBackground(rl.WHITE)

    rl.DrawFPS(0, 0)
 
    entity_render(&p)
    entity_render(&tiles)

    player_update(&p)

    rl.EndMode2D()
    rl.EndDrawing()
}