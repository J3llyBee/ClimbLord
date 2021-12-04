build:
	odin build src/ -target:darwin_amd64 -extra-linker-flags:"-framework OpenGL -framework Cocoa -framework IOKit" -out:build/main

run:
	odin run src/ -target:darwin_amd64 -extra-linker-flags:"-framework OpenGL -framework Cocoa -framework IOKit" -out:build/main