package main

import rl "vendor:raylib"

Entity :: struct {
    pos: vec2,
    size: vec2,
    sprite: rl.Texture2D,
}

Dir :: enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
    NONE,
}

entity_get_rec :: proc(using e: ^Entity) -> rl.Rectangle {
    return rl.Rectangle { pos.x - size.x / 2, pos.y - size.y / 2, size.x, size.y }
}

entity_check_col :: proc(e1, e2: ^Entity) -> bool {
    return rl.CheckCollisionRecs(entity_get_rec(e1), entity_get_rec(e2))
}

entity_get_col_rec :: proc(e1, e2: ^Entity) -> rl.Rectangle {
    return rl.GetCollisionRec(entity_get_rec(e1), entity_get_rec(e2))
}

entity_col_dir :: proc(e1, e2: ^Entity) -> Dir {
    if entity_check_col(e1, e2) {
        col := entity_get_col_rec(e1, e2)

        if abs(col.width) < abs(col.height) {
            if e1.pos.x == col.x do return .RIGHT else do return .LEFT
        } else {
            if e1.pos.y == col.y do return .DOWN else do return .UP
        }
    }

    return .NONE
}

// Wont work for upside down
entity_on_tile :: proc(e1, e2: ^Entity) -> bool {
    x := entity_get_rec(e1)
    x.height += 1

    return rl.CheckCollisionRecs(x, entity_get_rec(e2))
}


entity_render :: proc(using e: ^Entity) {
    rl.DrawTexture(sprite, i32(pos.x - size.x / 2), i32(pos.y - size.y / 2), rl.WHITE)
}