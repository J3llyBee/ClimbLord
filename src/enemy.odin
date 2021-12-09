package main

import rl "vendor:raylib"

EnemyType :: enum {
	SHOOTER = 3,
	WALKER,
	GHOST,
}

Enemy :: struct {
	using entity: Entity,
	vel: vec2,
	type: EnemyType,
	sprite: rl.Texture2D,
}

enemy_sprites := map[EnemyType]rl.Texture {
	.SHOOTER = load_texture("amon.png"),
}

enemy_new :: proc(pos: vec2, type: EnemyType) -> ^Enemy {
	e := new(Enemy)
	
	e.type = type
	e.entity = {pos, {16, 16}}
	e.sprite = enemy_sprites[type]

	return e
}