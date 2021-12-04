package main

import "core:fmt"
import "core:time"
import "core:strings"

import rl "vendor:raylib"

p := Player {}
t := Tile {}

tiles: []Tile
camera: rl.Camera2D

room: [dynamic]Tile = make([dynamic]Tile)


room_width: = 13
room_height: = 20
gravity: f32 = 100
vel: f32 = 0

shader: rl.Shader
render_tex: rl.RenderTexture2D

main :: proc() {
    rl.InitWindow(224 * 4, 224 * 4, "ClimbLord")
    camera.zoom = 4

    shader = rl.LoadShaderFromMemory(nil, 
    `
#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

out vec4 finalColor;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;

uniform vec4 palette[4];

void main()
{
    int index = int(texture(texture0, fragTexCoord).r * 255);

    finalColor = palette[index];
}

    `)

    // 0.0 == 0 == enemy
    // 0.2 == 51 == player
    // 0.4 == 102 == accent
    // 0.6 == 153 == tile

    // rl.SetShaderValue(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "enemyCol")), &[4]f32{1.0, 0.0, 0.0, 1.0}, rl.ShaderUniformDataType.VEC4)
    // rl.SetShaderValue(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "playerCol")), &[4]f32{0.0, 1.0, 0.0, 1.0}, rl.ShaderUniformDataType.VEC4)
    // rl.SetShaderValue(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "accentCol")), &[4]f32{1.0, 0.0, 1.0, 1.0}, rl.ShaderUniformDataType.VEC4)
    // rl.SetShaderValue(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "tileCol")), &[4]f32{1.0, 0.0, 1.0, 1.0}, rl.ShaderUniformDataType.VEC4)
    // rl.SetShaderValue(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "backCol")), &[4]f32{0.0, 1.0, 1.0, 1.0}, rl.ShaderUniformDataType.VEC4)
    rl.SetShaderValueV(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "palette")), &[4][4]f32{
        {1.0, 1.0, 1.0, 1.0},
        {0.0, 1.0, 0.0, 1.0},
        {0.0, 0.0, 1.0, 1.0},
        {1.0, 1.0, 0.0, 1.0},
    }, rl.ShaderUniformDataType.VEC4, 4);

    render_tex = rl.LoadRenderTexture(224 * 4, 224 * 4)
    for a in 0..room_height {
        for i in 0..room_width {
            append_elem(&room, tile_new({16 * f32(i) + 8, 216 - f32(a) * 16}, load_texture("tile.png")))
        }
    }

    p.pos = {100, 0}
    p.sprite = load_texture("amon.png")
    p.size = {f32(p.sprite.width), f32(p.sprite.height)}

    t.pos = {100, 100}
    t.sprite = load_texture("tile.png")
    t.size = {f32(t.sprite.width), f32(t.sprite.height)}

    // for i in 0..28 {
    //     append_elem(&room, tile_new({16 * f32(i) + 8, 200}, load_texture("tile.png")))
    // }

    for !rl.WindowShouldClose() {
        rl.PollInputEvents()

        update()
    }
}

render_room :: proc(room: ^[dynamic]Tile) {
    for i in room {
        entity_render(&i)
    }
}

make_path :: proc() {
    // sus
}

update :: proc() {
    v := fmt.tprintf("%f", vel)
    cstr := strings.unsafe_string_to_cstring(v)

    // fmt.println(rl.GetFrameTime())\

    player_update(&p)

    rl.BeginTextureMode(render_tex)
        rl.ClearBackground(rl.BLANK)

        rl.BeginMode2D(camera)
            entity_render(&p)
            render_room(&room)
        rl.EndMode2D()
    rl.EndTextureMode()

    rl.BeginDrawing()
        rl.ClearBackground(rl.BLUE)

        rl.BeginShaderMode(shader)
            rl.DrawTextureRec(render_tex.texture, {0, 0, f32(render_tex.texture.width), -f32(render_tex.texture.height)}, {0, 0}, rl.WHITE)
        rl.EndMode2D()

        // rl.DrawFPS(0, 0)
        // rl.DrawText(cstr, 100, 100, 20, rl.BLACK)
    rl.EndDrawing()
}