package main

import rl "vendor:raylib"

Entity :: struct {
    pos: vec2,
    size: vec2,
    sprite: rl.Texture2D,
}

entity_get_rec :: proc(using e: ^Entity) -> rl.Rectangle {
    return rl.Rectangle { pos.x, pos.y, size.x, size.y }
}

entity_check_col :: proc(e1, e2: ^Entity) -> bool {
    return rl.CheckCollisionRecs(entity_get_rec(e1), entity_get_rec(e2))
}

entity_get_col_rec :: proc(e1, e2: ^Entity) -> rl.Rectangle {
    return rl.GetCollisionRec(entity_get_rec(e1), entity_get_rec(e2))
}