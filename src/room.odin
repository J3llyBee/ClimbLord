package main

import "core:math/rand"
import "core:math"
import "core:fmt"

Room :: struct {
	inner: []^Tile,
	width, height: int,
}

// TODO: redo all the generation

room_new :: proc(width, height, fill: int) -> ^Room {
	r := new(Room)
	r.inner = make([]^Tile, height * width)
	r.width = width
	r.height = height

	// room_random_fill(r, fill)

	room_gen_walls(r)
	room_fill(r)
	
	// for y in 0..<r.height {
 //        for x in 0..<r.width {
 //        	cnt := room_get_neighbours(r, x, y)

 //        	if cnt > 5 {
 //        		if r.inner[y * r.width + x] == nil do r.inner[y * r.width + x] = tile_new({f32(x) * 16 + 8, f32(y) * 16 + 8}) 
 //        	} else if cnt < 4 {
 //        		if r.inner[y * r.width + x] != nil {
 //        			free(r.inner[y * r.width + x])
 //        			r.inner[y * r.width + x] = nil
 //        		}
 //        	}
 //        }
 //    }

    room_carve_path(r)

    room_gen_walls(r)

    for y in 0..<r.height {
        for x in 0..<r.width {
        	if r.inner[y * r.width + x] != nil {
        		r.inner[y * r.width + x].sprite_index = int(room_get_ring_num(r, x, y))
    		}
        }
    }

	return r
}

room_gen_tile :: proc(r: ^Room, x, y: int) {
	if r.inner[p2i(r, x, y)] != nil do return

	r.inner[p2i(r, x, y)] = tile_new({f32(x) * 16 + 8, f32(y) * 16 + 8}) 
}

room_delete_tile :: proc(r: ^Room, x, y: int) {
	if r.inner[p2i(r, x, y)] == nil do return

	free(r.inner[p2i(r, x, y)])
	r.inner[p2i(r, x, y)] = nil
}

room_gen_walls :: proc(r: ^Room) {
	for y in 0..<r.height {
        room_gen_tile(r, 0, y)
        room_gen_tile(r, 14, y)
    }
}

room_fill :: proc(r: ^Room) {
	for y in 0..<r.height {
        for x in 0..<r.width {
        	r.inner[y * r.width + x] = tile_new({f32(x) * 16 + 8, f32(y) * 16 + 8}) 
        }
    }
}

room_random_fill :: proc(r: ^Room, fill: int) {
	for y in 0..<r.height {
        for x in 0..<r.width {
        	if rand.int31_max(100) < i32(fill) {
        		r.inner[y * r.width + x] = tile_new({f32(x) * 16 + 8, f32(y) * 16 + 8}) 
        	} else {
        		r.inner[y * r.width + x] = nil
        	}
        }
    }
}

room_carve_path :: proc(r: ^Room) {
	x := r.width / 2

	for y in 0..<r.height {
		// size := int(rand.int31_max(i32(r.width)) / 2)
		size := 2

		for dx in -size..size {
			free(r.inner[p2i(r, x + dx, y)])
        	r.inner[p2i(r, x + dx, y)] = nil
		}

		x += rand.int31_max(2) > 0 ? -1 : 1
    }
}

room_render :: proc(r: ^Room) {
	for y in 0..<r.height {
		for x in 0..<r.width {
			if r.inner[y * r.width + x] != nil do tile_render(r.inner[y * r.width + x], palettes[gs.palette][3])
		}
	}
}

room_get_neighbours :: proc(r: ^Room, x, y: int) -> (res: int) {
	for dy in -1..1 {
		for dx in -1..1 {
			res += r.inner[p2i(r, x + dx, y + dy)] != nil ? 1 : 0
		}
	}

	res -= r.inner[y * r.width + x] != nil ? 1 : 0

	return
}

room_get_ring :: proc(r: ^Room, x, y: int) -> int {
	return (r.inner[p2i(r, x - 1, y)] != nil ? 1 : 0) + (r.inner[p2i(r, x, y - 1)] != nil ? 1 : 0) + (r.inner[p2i(r, x + 1, y)] != nil ? 1 : 0) + (r.inner[p2i(r, x, y + 1)] != nil ? 1 : 0)
}

room_get_ring_num :: proc(r: ^Room, x, y: int) -> u8 {
	return 0 | (r.inner[p2i(r, x - 1, y)] != nil ? 0b1000 : 0) | (r.inner[p2i(r, x, y - 1)] != nil ? 0b0100 : 0) | (r.inner[p2i(r, x + 1, y)] != nil ? 0b0010 : 0) | (r.inner[p2i(r, x, y + 1)] != nil ? 0b0001 : 0)
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

	if x < 0 do x = r.width - 1 + x
	else if x >= r.width do x = x - r.width

	if y < 0 do y = r.height - 1 + y
	else if y >= r.height do y = y - r.height

	return clamp(y * r.width + x, 0, r.width * r.height)
}