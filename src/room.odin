package main

import "core:math/rand"
import "core:math"
import "core:fmt"

Room :: struct {
	inner: []^Tile,
	width, height: int,
}

room_new :: proc(width, height, fill: int) -> ^Room {
	r := new(Room)
	r.inner = make([]^Tile, height * width)
	r.width = width
	r.height = height

	room_random_fill(r, fill)

	for y in 0..<r.height {
        for x in 0..<r.width {
        	cnt := room_get_neighbours(r, x, y)

        	if cnt > 5 {
        		if r.inner[y * r.width + x] == nil do r.inner[y * r.width + x] = tile_new({f32(x) * 16 + 8, f32(y) * 16 + 8}, load_texture("tile.png")) 
        	} else if cnt < 4 {
        		if r.inner[y * r.width + x] != nil {
        			free(r.inner[y * r.width + x])
        			r.inner[y * r.width + x] = nil
        		}
        	}
        }
    }

	return r
}

room_random_fill :: proc(r: ^Room, fill: int) {
	for y in 0..<r.height {
        for x in 0..<r.width {
        	if rand.int31_max(100) < i32(fill) {
        		r.inner[y * r.width + x] = tile_new({f32(x) * 16 + 8, f32(y) * 16 + 8}, load_texture("tile.png")) 
        	} else {
        		r.inner[y * r.width + x] = nil
        	}
        }
    }
}

room_render :: proc(r: ^Room) {
	for y in 0..<r.height {
		for x in 0..<r.width {
			if r.inner[y * r.width + x] != nil do entity_render(r.inner[y * r.width + x], palettes[gs.palette][3])
		}
	}
}

room_get_neighbours :: proc(r: ^Room, x, y: int) -> (res: int) {
	for dy in -1..1 {
		for dx in -1..1 {
			res += r.inner[p2i(r, y + dy, x + dx)] != nil ? 1 : 0
		}
	}

	return
}

room_get_tiles :: #force_inline proc(r: ^Room) -> []Tile {
	nt := make([dynamic]Tile, context.temp_allocator)
    for i in &gs.room.inner {
        if i != nil do append_elem(&nt, i^)
    }

    return nt[:]
}

@(private="file")
p2i :: proc(r: ^Room, x, y: int) -> int {
	x := x
	y := y

	if x < 0 do x = r.width + x
	else if x > r.width - 1 do x = x - r.width

	if y < 0 do y = r.height + y
	else if y > r.height - 1 do y = y - r.height

	return y * r.width + x
}