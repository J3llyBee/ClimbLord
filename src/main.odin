package main

import "core:fmt"
import "core:time"
import "core:strings"
import "core:intrinsics"
import "core:math/rand"

import rl "vendor:raylib"

State :: struct {
    score: i32,
    player: Player,
    enemies: [dynamic]^Enemy,
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
shoot_sfx: rl.Sound
enemydie_sfx: rl.Sound
playerdie_sfx: rl.Sound

tutorialtext: rl.Texture
tutorialtext2: rl.Texture
tutorialtext3: rl.Texture

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

    // rl.SetTargetFPS(60)

    // rl.InitAudioDevice()
    // rl.SetMasterVolume(0.1)

    jump_sfx = load_sound("jump.wav")
    shoot_sfx = load_sound("shoot.wav")
    enemydie_sfx = load_sound("deathsound.wav")
    playerdie_sfx = load_sound("playerdeath.wav")

    tutorialtext = load_texture("tutorialtext.png")
    tutorialtext2 = load_texture("tutorialtext2.png")
    tutorialtext3 = load_texture("tutorialtext3.png")

    start_button = {
        entity = {{100, 100}, {32, 64}},
        sprite = load_texture("respan.png"),
        fn = proc() {
            reset()
            // gs.state = .GAME
        },
    }

    option_button = {
        entity = {{100, 200}, {32, 64}},
        sprite = load_texture("respan.png"),
        fn = proc() {
            gs.state = .OPTIONS
        },
    }

    death_img = load_texture("death.png")

    gs.player.pos = {100, 110}
    gs.player.vel = {0, 0}
    gs.player.sprite = {
        texatls_new(load_texture("player/idle.png"), 16, 16),
        texatls_new(load_texture("player/run.png"), 16, 16),
        texatls_new(load_texture("player/jump.png"), 16, 16),
        texatls_new(load_texture("player/swing.png"), 16, 16),
    }
    gs.player.size = {16 - 2, 16 - 0.5}
    gs.player.bullets = make([dynamic]^Bullet)

    gs.enemies = make([dynamic]^Enemy)

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

    enemy_sprites = map[EnemyType]^Texatls {
        .WALKER = texatls_new(load_texture("enemy/goom.png"), 16, 16),
        .GHOST = texatls_new(load_texture("ghostguy-Recovered.png"), 16, 16),
    }

    gs.room = room_new(15, 15, 65)
    gs.room.bi = 3

    // append(&gs.enemies, enemy_new({100, 100}, .GHOST))

    for !rl.WindowShouldClose() {
        rl.PollInputEvents()
        rl.BeginDrawing()

        switch gs.state {
            case .MENU:
                clear_background()
                // menu()
                update()
            case .GAME:
                clear_background()
                update()
            case .DEAD:
                dead()
            case .OPTIONS:
                clear_background()
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
        rl.DrawTexture(death_img, 0, 0 + i32(gs.camera.target.y), rl.WHITE)
        rl.DrawText("You died", 50, 50 + i32(gs.camera.target.y), 32, rl.WHITE)

        distance := fmt.tprintf("Distance: %dm", gs.score)
        cd := strings.unsafe_string_to_cstring(distance)
        rl.DrawText(cd, 62, 100 + i32(gs.camera.target.y), 16, rl.WHITE)

        start_button.pos.y = gs.camera.target.y + 140
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

reset :: proc() {
    room_clear(gs.room)
    clear_dynamic_array(&gs.enemies)

    for i in 0..<3 do room_init(gs.room, i, rooms[rand.int_max(len(rooms))])

    room_init(gs.room, 3, #load("../res/rooms/room0"))

    room_update_sprites(gs.room)

    gs.room.bi = 3

    gs.player.pos = {100, 110}
    gs.player.vel = {0, 0}

    gs.camera.target.y = 0

    gs.scolling = false
    gs.score = 0

    gs.state = .GAME
}

update :: proc() {
    if gs.player.pos.y < 50 do gs.scolling = true
    gs.score = i32(abs(gs.player.pos.y) / 16)

    room_update(gs.room)



    // room_editor()
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

    
    if gs.scolling do gs.camera.target.y -= 25 * rl.GetFrameTime()
    clear_background()

    rl.BeginMode2D(gs.camera)
        // entity_render(&gs.player, palettes[gs.palette][1])
        // entity_render(&gs.player.flag, palettes[gs.palette][2])

        for i in &gs.player.bullets {
            bullet_update(i)
            // base_render(i, palettes[gs.palette][2])
            if abs(i.vel.x) > abs(i.vel.y) {
                if i.vel.x < 0.0 {
                    texatls_render(i.sprite, {i.pos.x, i.pos.y + 5, 10, 10}, int(i.ci), 0, false, palettes[gs.palette][2], -90)
                } else {
                    texatls_render(i.sprite, {i.pos.x, i.pos.y - 5, 10, 10}, int(i.ci), 0, false, palettes[gs.palette][2], 90)
                }
            } else {
                texatls_render(i.sprite, {i.pos.x - 5, i.pos.y - 5, 10, 10}, int(i.ci), 0, false, palettes[gs.palette][2])
            }
        }
        for i in &gs.enemies {
            enemy_update(i)
            texatls_render(i.sprite, {i.pos.x - i.size.x / 2, i.pos.y - i.size.y / 2, 16, 16}, int(i.ci), 0, false, palettes[gs.palette][0])
            // base_render(i, palettes[gs.palette][0])
        }
        player_render(&gs.player)
        room_render(gs.room)
        rl.DrawTexture(tutorialtext, 50, 50, palettes[gs.palette][3])
        rl.DrawTexture(tutorialtext2, 120, 50, palettes[gs.palette][0])
        rl.DrawTexture(tutorialtext3, 30, 170, palettes[gs.palette][0])

        

        player_update(&gs.player)
    rl.EndMode2D()

    rl.DrawFPS(0, 0)
}