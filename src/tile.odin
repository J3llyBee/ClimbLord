package main

import rl "vendor:raylib"

TileType :: enum u8 {
    BASIC = 1,
    SPIKE,    
}

Tile :: struct {
    using entity: Entity,
    type: TileType,
    sprite_index: int,
    // using entity: Entity,
}

tile_sprites: map[TileType][]rl.Texture

tile_new :: #force_inline proc(pos: vec2, type := TileType.BASIC) -> ^Tile {
    t := new(Tile)
    t.pos = pos
    t.size = { 16, 16 }
    t.type = type
    // t.entity = { pos, {f32(sprite.width), f32(sprite.height)}, sprite }
    return t
}

tile_render :: proc(using t: ^Tile) {
    rl.DrawTexture(tile_sprites[type][clamp(sprite_index, 0, len(tile_sprites[type]) - 1)] , i32(pos.x - 8), i32(pos.y - 8), tile_is_enemy(t.type) ? palettes[gs.palette][0] : palettes[gs.palette][3])
}

tile_is_enemy :: proc(t: TileType) -> bool {
    switch t {
        case .BASIC: return false
        case .SPIKE: return true
    }

    unreachable()
}

tile_update :: proc(using t: ^Tile) {
    #partial switch type {
        case .SPIKE:
            gs.state = .DEAD
            break
    }
}