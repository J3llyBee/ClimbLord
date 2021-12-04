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

entity_check_col_single :: proc(e1, e2: ^Entity) -> bool {
    return rl.CheckCollisionRecs(entity_get_rec(e1), entity_get_rec(e2))
}

entity_check_col_multi :: proc(e1: ^Entity, es: ^[]$T) -> bool {
    for i in es {
        if entity_check_col_single(e1, &i) do return true
    }

    return false
}

entity_check_col :: proc{entity_check_col_single, entity_check_col_multi}

entity_get_col_rec_single :: proc(e1, e2: ^Entity) -> rl.Rectangle {
    return rl.GetCollisionRec(entity_get_rec(e1), entity_get_rec(e2))
}

entity_get_col_rec_multi :: #force_inline proc(e1: ^Entity, es: ^[]$T) -> [dynamic]rl.Rectangle {
    cols := make([dynamic]rl.Rectangle, context.temp_allocator)

    for i in es {
        if entity_check_col(e1, &i) do append_elem(&cols, entity_get_col_rec_single(e1, &i))
    }

    return cols
}

entity_get_col_rec :: proc{entity_get_col_rec_single, entity_get_col_rec_multi}

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
entity_on_tile_single :: proc(e1, e2: ^Entity) -> bool {
    rec := entity_get_rec(e1)
    rec.height += 1
    rec.x += 1
    rec.width -= 2

    return rl.CheckCollisionRecs(rec, entity_get_rec(e2))
}

entity_on_tile_multi :: proc(e1: ^Entity, es: ^[]$T) -> bool {
    for i in es {
        if entity_on_tile_single(e1, &i) do return true
    }

    return false
}

entity_on_tile :: proc{entity_on_tile_single, entity_on_tile_multi}

entity_render_single :: proc(using e: ^Entity, color := rl.WHITE) {
    rl.DrawTexture(sprite, i32(pos.x - size.x / 2), i32(pos.y - size.y / 2), color)
}

entity_render_multi :: proc(es: ^[]$T, color := rl.WHITE) {
    for i in es do entity_render_single(&i, color)
}

entity_render :: proc{entity_render_single, entity_render_multi}