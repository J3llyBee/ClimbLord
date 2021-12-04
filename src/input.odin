package main

import "core:fmt"

import rl "vendor:raylib"

Inputs :: distinct map[string][]rl.KeyboardKey

inputs := Inputs {
	"UP" = {rl.KeyboardKey.W, rl.KeyboardKey.UP},
	"DOWN" = {rl.KeyboardKey.S, rl.KeyboardKey.DOWN},
	"LEFT" = {rl.KeyboardKey.A, rl.KeyboardKey.LEFT},
	"RIGHT" = {rl.KeyboardKey.D, rl.KeyboardKey.RIGHT},
	"SWITCH" = {rl.KeyboardKey.Q},
}

@private
input_is_func :: proc(action: string, fn: proc "cdecl" (rl.KeyboardKey) -> bool) -> bool {
	for v in inputs[action] {
		if fn(v) do return true
	}

	return false
}

input_is_down :: proc(action: string) -> bool do return input_is_func(action, rl.IsKeyDown)
input_is_pressed :: proc(action: string) -> bool do return input_is_func(action, rl.IsKeyPressed)
input_is_released :: proc(action: string) -> bool do return input_is_func(action, rl.IsKeyReleased)
input_is_up :: proc(action: string) -> bool do return input_is_func(action, rl.IsKeyUp)