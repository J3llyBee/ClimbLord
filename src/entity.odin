package main

import "core:intrinsics"

import rl "vendor:raylib"

Entity :: struct {
    pos: vec2,
    size: vec2,
}

Dir :: enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
    NONE,
}

// Get Entity Collision Rectangle

entity_get_rect_e :: proc(using e: ^Entity) -> rl.Rectangle {
    return rl.Rectangle { pos.x - size.x / 2, pos.y - size.y / 2, size.x, size.y }
}

entity_get_rect_r :: proc(e: rl.Rectangle) -> rl.Rectangle {
    return e
}

entity_get_rect :: proc{entity_get_rect_e, entity_get_rect_r}

// Check For Entity Collisions

entity_check_col_single :: proc(e1: $E, e2: $T) -> bool
    where !intrinsics.type_is_indexable(intrinsics.type_elem_type(E)) &&
          !intrinsics.type_is_indexable(intrinsics.type_elem_type(T)) {
    return rl.CheckCollisionRecs(entity_get_rect(e1), entity_get_rect(e2))
}

entity_check_col_multi :: proc(e1: $E, es: ^[]$T) -> bool {
    for i in es {
        if entity_check_col_single(e1, &i) do return true
    }

    return false
}

entity_check_col :: proc{entity_check_col_single, entity_check_col_multi}

// Get All Entity Collisions

entity_get_cols :: #force_inline proc(e1: rl.Rectangle, es: ^[]$T) -> [dynamic]T {
    cols := make([dynamic]T, context.temp_allocator)

    for i in es {
        if entity_check_col(e1, &i) do append_elem(&cols, i)
    }

    return cols
}

// Check if Player on Ground

entity_on_tile_single :: proc(e1: $E, e2: $T) -> bool
    where !intrinsics.type_is_indexable(intrinsics.type_elem_type(E)) &&
          !intrinsics.type_is_indexable(intrinsics.type_elem_type(T)) {
    rec := entity_get_rect(e1)
    rec.height += 2
    rec.x += 1
    rec.width -= 2

    return rl.CheckCollisionRecs(rec, entity_get_rect(e2))
}

entity_on_tile_multi :: proc(e1: $E, es: ^[]$T) -> bool {
    for i in es {
        if entity_on_tile_single(e1, &i) do return true
    }

    return false
}

entity_on_tile :: proc{entity_on_tile_single, entity_on_tile_multi}