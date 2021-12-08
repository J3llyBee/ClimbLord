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
    scolling: bool,
    state: enum {
        MENU,
        GAME,
        DEAD,
        OPTIONS,
    },
}

jump_sfx: rl.Sound

start_button: UI
option_button: UI
death_img: rl.Texture2D

gs: State


palettes := [?][4]rl.Color {
    { hexcol(0x141319ff), hexcol(0x30303dff), hexcol(0x7b7aa4ff), hexcol(0xdadadaff) },
    { hexcol(0x1b0326ff), hexcol(0xba5044ff), hexcol(0x7a1c4bff), hexcol(0xeff9d6ff) },
    { hexcol(0x000000ff), hexcol(0x6772a9ff), hexcol(0x3a3277ff), hexcol(0xffffffff) },
    { hexcol(0x300030ff), hexcol(0xf89020ff), hexcol(0x602878ff), hexcol(0xf8f088ff) },
    { hexcol(0x565656ff), hexcol(0xe58fadff), hexcol(0xad5cd6ff), hexcol(0xf7efeeff) },
}

room_width := 13
room_height := 20

main :: proc() {
    gs.state = .MENU
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

    jump_sfx = load_sound("jump.wav")

    start_button = {
        entity = {{100, 100}, {32, 16}},
        sprite = load_texture("startbutton.png"),
        fn = proc() {
            gs.state = .GAME
        },
    }

    option_button = {
        entity = {{100, 200}, {32, 16}},
        sprite = load_texture("startbutton.png"),
        fn = proc() {
            gs.state = .OPTIONS
        },
    }

    death_img = load_texture("death.png")

    gs.room = room_new(15, 15, 65)
    gs.room.bi = 3

    gs.player.pos = {100, 110}
    gs.player.vel = {0, 0}
    gs.player.sprite = texatls_new(load_texture("player/idle.png"), 16, 16)
    gs.player.size = {16 - 2, 16 - 0.5}

    // gs.camera.offset.y = -240 * 3

    tile_sprites = map[TileType][]rl.Texture {
        TileType.BASIC = {
            load_texture("ground/0.png"),  load_texture("ground/1.png"),  load_texture("ground/2.png"),  load_texture("ground/3.png"),
            load_texture("ground/4.png"),  load_texture("ground/5.png"),  load_texture("ground/6.png"),  load_texture("ground/7.png"),
            load_texture("ground/8.png"),  load_texture("ground/9.png"),  load_texture("ground/10.png"), load_texture("ground/11.png"),
            load_texture("ground/12.png"), load_texture("ground/13.png"), load_texture("ground/14.png"), load_texture("ground/15.png"),
        },
        TileType.SPIKE = {
            load_texture("spike/0.png"),
        },
    }


    for !rl.WindowShouldClose() {
        rl.PollInputEvents()
        rl.BeginDrawing()

        switch gs.state {
            case .MENU:
                clear_background()
                // menu()
                update()
                break
            case .GAME:
                clear_background()
                update()
                break
            case .DEAD:
                start_button.pos.y = 200
                dead()
                break
            case .OPTIONS:
                clear_background()
                break
        }

        rl.EndDrawing()
    }
}


cooldown: f32 = 0

dead :: proc() {
    clear_background()

    rl.BeginMode2D(gs.camera)
        
        // entity_render(&gs.player, palettes[gs.palette][1])
        // entity_render(&gs.player.flag, palettes[gs.palette][2])
        player_render(&gs.player)
        room_render(gs.room)
        rl.DrawTexture(death_img, 0, 0, rl.WHITE)
        rl.DrawText("You died", 50, 50, 32, rl.WHITE)
        rl.DrawText("Distance: 100m", 62, 100, 16, rl.WHITE)

        button_render(&start_button)
        button_update(&start_button)

    rl.EndMode2D()

    rl.DrawFPS(0, 0)
}

menu :: proc() {
    clear_background()

    rl.BeginMode2D(gs.camera)

    button_render(&start_button)
    button_render(&option_button)

    button_update(&start_button)
    button_update(&option_button)

    rl.EndMode2D()

    rl.DrawFPS(0, 0)
}

update :: proc() {
    if gs.player.pos.y < 50 do gs.scolling = true

    room_update(gs.room)
    if rl.IsKeyDown(rl.KeyboardKey.B) {
        room_insert(gs.room, 2, #load("../room1"))
    }
    room_editor()
    cooldown -= rl.GetFrameTime()

    if input_is_down("PALETTE") && cooldown < 0 {
        gs.palette = gs.palette + 1 > len(palettes) - 1 ? 0 : gs.palette + 1
        cooldown = 0.1
    }

    // fmt.println(rl.GetFrameTime())\

    gs.switch_timout -= rl.GetFrameTime()
  
    if input_is_down("SWITCH") && gs.switch_timout <= 0 {
        gs.switched = !gs.switched

        gs.switch_timout = 0.5
    }

    
    if gs.scolling do gs.camera.target.y -= 35 * rl.GetFrameTime()
    clear_background()

    rl.BeginMode2D(gs.camera)
        // entity_render(&gs.player, palettes[gs.palette][1])
        // entity_render(&gs.player.flag, palettes[gs.palette][2])
        player_render(&gs.player)
        room_render(gs.room)

        player_update(&gs.player)
    rl.EndMode2D()

    rl.DrawFPS(0, 0)
}