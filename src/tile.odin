package main

import rl "vendor:raylib"

Tile :: struct {
    using entity: Entity,
}

tile_new :: #force_inline proc(pos: vec2, sprite: rl.Texture2D) -> ^Tile {
    t := new(Tile)
    t.entity = { pos, {f32(sprite.width), f32(sprite.height)}, sprite }
    return t
}