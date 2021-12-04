package main

import rl "vendor:raylib"

Tile :: struct {
    using entity: Entity,
}

tile_render :: proc(using tile: ^Tile) {
    rl.DrawTexture(sprite, i32(pos.x), i32(pos.y), rl.WHITE)
}