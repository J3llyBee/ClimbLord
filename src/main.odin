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

shader: rl.Shader
render_tex: rl.RenderTexture2D

main :: proc() {
    rl.InitWindow(224 * 4, 224 * 4, "ClimbLord")
    camera.zoom = 2

    shader = rl.LoadShaderFromMemory(nil, 
    `
#version 330

in vec2 fragTexCoord;

out vec4 finalColor;

uniform sampler2D texture0;
uniform vec4 enemyCol;
uniform vec4 playerCol;
uniform vec4 accentCol;
uniform vec4 tileCol;

uniform vec4 backCol;

void main()
{
    vec4 color = texture(texture0, fragTexCoord);

    if (color == vec4(0.0, 0.0, 0.0, 1.0)) {
        finalColor = enemyCol;
    } else if (color == vec4(0.25, 0.25, 0.25, 1.0)) {
        finalColor = playerCol;
    } else if (color == vec4(0.50, 0.50, 0.50, 1.0)) {
        finalColor = accentCol;
    } else if (color == vec4(0.75, 0.75, 0.75, 1.0)) {
        finalColor = tileCol;
    } else {
        finalColor = backCol;
    }
}

    `)

    rl.SetShaderValue(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "enemyCol")), &[4]f32{1.0, 0.0, 0.0, 1.0}, rl.ShaderUniformDataType.VEC4)
    rl.SetShaderValue(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "playerCol")), &[4]f32{1.0, 0.0, 0.0, 1.0}, rl.ShaderUniformDataType.VEC4)
    rl.SetShaderValue(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "accentCol")), &[4]f32{1.0, 0.0, 0.0, 1.0}, rl.ShaderUniformDataType.VEC4)
    rl.SetShaderValue(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "tileCol")), &[4]f32{1.0, 0.0, 0.0, 1.0}, rl.ShaderUniformDataType.VEC4)
    rl.SetShaderValue(shader, transmute(rl.ShaderLocationIndex)(rl.GetShaderLocation(shader, "backCol")), &[4]f32{0.0, 1.0, 0.0, 1.0}, rl.ShaderUniformDataType.VEC4)

    render_tex = rl.LoadRenderTexture(224 * 4, 224 * 4)

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
    player_update(&p)

    rl.BeginTextureMode(render_tex)
        rl.ClearBackground(rl.WHITE)

        rl.BeginMode2D(camera)
            entity_render(&p)
            entity_render(&tiles)
        rl.EndMode2D()
    rl.EndTextureMode()

    rl.BeginDrawing()
        rl.ClearBackground(rl.WHITE)

        rl.DrawFPS(0, 0)

        rl.BeginShaderMode(shader)
            rl.DrawTextureRec(render_tex.texture, {0, 0, f32(render_tex.texture.width), -f32(render_tex.texture.height)}, {0, 0}, rl.WHITE)
        rl.EndMode2D()
    rl.EndDrawing()
}