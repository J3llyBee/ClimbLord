package main

import "core:fmt"
import "core:time"
import "core:strings"
import "core:intrinsics"

import rl "vendor:raylib"

State :: struct {
    player: Player,
    room: ^Room,
    camera: rl.Camera2D,
    palette: int,
    switched: bool,
    switch_timout: f32,
}

gs: State

palettes := [?][4]rl.Color {
    { hexcol(0x141319ff), hexcol(0x30303dff), hexcol(0x7b7aa4ff), hexcol(0xdadadaff) },
    { hexcol(0x1b0326ff), hexcol(0xba5044ff), hexcol(0x7a1c4bff), hexcol(0xeff9d6ff) },
    { hexcol(0x000000ff), hexcol(0x6772a9ff), hexcol(0x3a3277ff), hexcol(0xffffffff) },
    { hexcol(0x300030ff), hexcol(0xf89020ff), hexcol(0x602878ff), hexcol(0xf8f088ff) },
    { hexcol(0x565656ff), hexcol(0xe58fadff), hexcol(0xad5cd6ff), hexcol(0xf7efeeff) },
}

GameState := "GAME"

room_width := 13
room_height := 20

main :: proc() {
    when ODIN_OS == "darwin" {
        rl.InitWindow(240 * 3, 240 * 3, "ClimbLord")

        gs.palette = 3

        gs.camera.zoom = 3
    } else {
        rl.InitWindow(240 * 4, 240 * 4, "ClimbLord")

        gs.palette = 3

        gs.camera.zoom = 4
    }

    rl.InitAudioDevice()

    gs.room = room_new(15, 15, 65)

    gs.player.pos = {100, 110}
    gs.player.vel = {0, 0}
    gs.player.sprite = load_texture("amon.png")
    gs.player.size = {f32(gs.player.sprite.width) - 2, f32(gs.player.sprite.height) - 0.5}

    gs.player.flag = load_texture("flag.png")
    // gs.player.flag.size = {f32(gs.player.sprite.width), f32(gs.player.sprite.height)}

    tile_sprites = map[TileType][]rl.Texture {
        TileType.BASIC = []rl.Texture{
            load_texture("ground/0.png"),  load_texture("ground/1.png"),  load_texture("ground/2.png"),  load_texture("ground/3.png"),
            load_texture("ground/4.png"),  load_texture("ground/5.png"),  load_texture("ground/6.png"),  load_texture("ground/7.png"),
            load_texture("ground/8.png"),  load_texture("ground/9.png"),  load_texture("ground/10.png"), load_texture("ground/11.png"),
            load_texture("ground/12.png"), load_texture("ground/13.png"), load_texture("ground/14.png"), load_texture("ground/15.png"),
        },
    }

    for !rl.WindowShouldClose() {
        rl.PollInputEvents()
        switch GameState {
            case "MENU":
                // menu screen
                break
            case "GAME":
                update()
                break
            case "OPTIONS":
                // option screen
                break
        }
    }
}

update :: proc() {

    // fmt.println(rl.GetFrameTime())\

    gs.switch_timout -= rl.GetFrameTime()
  
    if input_is_down("SWITCH") && gs.switch_timout <= 0 {
        gs.switched = !gs.switched

        gs.switch_timout = 0.5
    }

    
    // gs.camera.offset.y += 50 * rl.GetFrameTime()

    rl.BeginDrawing()
        rl.ClearBackground(palettes[gs.palette][gs.switched ? 3 : 0])

        rl.BeginMode2D(gs.camera)
            // entity_render(&gs.player, palettes[gs.palette][1])
            // entity_render(&gs.player.flag, palettes[gs.palette][2])
            player_render(&gs.player)
            room_render(gs.room)

            player_update(&gs.player)
        rl.EndMode2D()

        rl.DrawFPS(0, 0)
    rl.EndDrawing()
}