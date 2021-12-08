package main

import "core:math/rand"
import "core:math"
import "core:fmt"
import "core:os"

import rl "vendor:raylib"

Room :: struct {
	inner: []^Tile,
	width, height: int,
	bi: int,
}

rooms := [?][]u8 {
	#load("../room1"),
	#load("../chez.clr"),
}

// TODO: redo all the generation

room_new :: proc(width, height, fill: int) -> ^Room {
	r := new(Room)
	r.inner = make([]^Tile, height * width * 4)
	r.width = width
	r.height = height * 4

	// EDITOR

	// for y in 0..<r.height {
 //        for x in 0..<r.width {
 //        	room_gen_tile(r, x, y)
 //        }
 //    }

	// END OF EDITOR

	room_init(r, 0, #load("../room1"))
	room_init(r, 1, #load("../room1"))
	room_init(r, 2, #load("../room1"))

	// Base Level
	room_init(r, 3, #load("../chez.clr"))

    room_update_sprites(r)

	return r
}

delay: f32 = 0.0

room_update :: proc(r: ^Room) {
	delay -= rl.GetFrameTime()

	if int(gs.camera.target.y) % 240 == 0 && int(gs.camera.target.y) != 0 && delay <= 0.0 {
		r2 := rand.int_max(len(rooms))
		fmt.println(r2)
		room_insert(r, r.bi, rooms[r2])

		r.bi = r.bi - 1 < 0 ? 3 : r.bi - 1

		delay = 0.2

		room_update_sprites(r)
	}
}

room_update_sprites :: proc(r: ^Room) {
    for y in 0..<r.height {
        for x in 0..<r.width {
        	if r.inner[y * r.width + x] != nil {
        		r.inner[y * r.width + x].sprite_index = int(room_get_ring_num(r, x, y))
    		}
        }
    }
}

room_gen_tile :: proc(r: ^Room, x, y: int, type := TileType.BASIC, offset: f32 = 0) {
	if r.inner[p2i(r, x, y)] != nil do room_delete_tile(r, x, y)

	r.inner[p2i(r, x, y)] = tile_new({f32(x) * 16 + 8, f32(y) * 16 + 8 + offset}, type) 
}

room_gen_tile_dif :: proc(r: ^Room, dx, dy, x, y: int, type := TileType.BASIC) {
	if r.inner[p2i(r, dx, dy)] != nil do room_delete_tile(r, x, y)

	r.inner[p2i(r, dx, dy)] = tile_new({f32(x) * 16 + 8, f32(y) * 16 + 8 + gs.camera.target.y - 240 * 3}, type) 
}

room_delete_tile :: proc(r: ^Room, x, y: int) {
	if r.inner[p2i(r, x, y)] == nil do return

	free(r.inner[p2i(r, x, y)])
	r.inner[p2i(r, x, y)] = nil
}

room_fill :: proc(r: ^Room) {
	for y in 0..<r.height {
        for x in 0..<r.width {
        	room_gen_tile(r, x, y)
        }
    }
}

room_clear :: proc(r: ^Room) {
	for y in 0..<r.height {
        for x in 0..<r.width {
        	room_delete_tile(r, x, y)
        }
    }
}

room_render :: proc(r: ^Room) {
	for y in 0..<r.height {
		for x in 0..<r.width {
			if r.inner[y * r.width + x] != nil do tile_render(r.inner[y * r.width + x])
		}
	}
}

room_get_ring_num :: proc(r: ^Room, x, y: int) -> u8 {
	t := r.inner[p2i(r, x, y)].type

	return 0 | (r.inner[p2i(r, x - 1, y)] != nil && r.inner[p2i(r, x - 1, y)].type == t ? 0b1000 : 0) | (r.inner[p2i(r, x, y - 1)] != nil && r.inner[p2i(r, x, y - 1)].type == t ? 0b0100 : 0) | (r.inner[p2i(r, x + 1, y)] != nil && r.inner[p2i(r, x + 1, y)].type == t ? 0b0010 : 0) | (r.inner[p2i(r, x, y + 1)] != nil && r.inner[p2i(r, x, y + 1)].type == t ? 0b0001 : 0)
}

room_get_tiles :: #force_inline proc(r: ^Room) -> []Tile {
	nt := make([dynamic]Tile, context.temp_allocator)
    for i in &gs.room.inner {
        if i != nil do append_elem(&nt, i^)
    }

    return nt[:]
}

room_dump :: proc(r: ^Room) {
    data: [15 * 15]u8

    for y in 0..<15 {
        for x in 0..<15 {
            if r.inner[p2i(r, x, y)] != nil {
            	data[p2i(r, x, y)] = u8(r.inner[p2i(r, x, y)].type)
        	}
        }
    }

    os.write_entire_file(get_input("ENTER PATH: "), data[:])
}

room_load :: proc(r: ^Room) {
	data, _ := os.read_entire_file(get_input("ENTER PATH: "))

	for y in 0..<15 {
        for x in 0..<15 {
            if data[p2i(r, x, y)] == 0 {
            	room_delete_tile(r, x, y)
            } else {
            	room_gen_tile(r, x, y, TileType(data[p2i(r, x, y)]))
            }
        }
    }
}

room_insert :: proc(r: ^Room, y: int, data: []u8) {
	offset := 15 * y

	for y in 0..<15 {
		for x in 0..<15 {
			room_delete_tile(r, x, y + offset)

			if data[p2i(r, x, y)] == 0 {
            	room_delete_tile(r, x, y + offset)
            } else {
            	room_gen_tile_dif(r, x, y + offset, x, y, TileType(data[p2i(r, x, y)]))
            }
		}
	}
}

room_init :: proc(r: ^Room, y: int, data: []u8) {
	offset := 15 * y

	for y in 0..<15 {
		for x in 0..<15 {
			room_delete_tile(r, x, y + offset)

			if data[p2i(r, x, y)] == 0 {
            	room_delete_tile(r, x, y + offset)
            } else {
            	room_gen_tile(r, x, y + offset, TileType(data[p2i(r, x, y)]), -240 * 3)
            }
		}
	}
}

current_tile: u8 = 1

room_editor :: proc() {
    posx := int(f32(rl.GetMouseX()) / (240 * 3) * 15)
    posy := int(f32(rl.GetMouseY()) / (240 * 3) * 15)

    if rl.IsMouseButtonDown(.LEFT) {
        room_gen_tile(gs.room, posx, posy, TileType(current_tile))

        room_update_sprites(gs.room)
    } else if rl.IsMouseButtonDown(.RIGHT) {
        room_delete_tile(gs.room, posx, posy)

        room_update_sprites(gs.room)
    }

    if rl.IsKeyDown(rl.KeyboardKey.G) {
        room_dump(gs.room)
    }

    rl.GetKeyPressed()

    if rl.IsKeyDown(rl.KeyboardKey.ONE) {
    	current_tile = 1
    } else if rl.IsKeyDown(rl.KeyboardKey.TWO) {
    	current_tile = 2
    }
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