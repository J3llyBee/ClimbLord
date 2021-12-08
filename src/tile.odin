package main

import rl "vendor:raylib"

TileType :: enum u8 {
    BASIC = 1,    
}

Tile :: struct {
    using entity: Entity,
    type: TileType,
    sprite_index: int,
    // using entity: Entity,
}

tile_sprites: map[TileType][]rl.Texture

tile_new :: #force_inline proc(pos: vec2) -> ^Tile {
    t := new(Tile)
    t.pos = pos
    t.size = { 16, 16 }
    t.type = .BASIC
    // t.entity = { pos, {f32(sprite.width), f32(sprite.height)}, sprite }
    return t
}

tile_render :: proc(using t: ^Tile, color := rl.WHITE) {
    rl.DrawTexture(tile_sprites[type][sprite_index] , i32(pos.x - 8), i32(pos.y - 8), color)
}

tile_get_rect :: proc(using t: ^Tile) -> rl.Rectangle {
    return rl.Rectangle { pos.x - 8, pos.y - 8, 16, 16 }
}