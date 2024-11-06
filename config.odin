package nopm

import "core:encoding/json"
import "core:log"
import "core:os"

Config :: struct {
	odin_path: string,
}

load_config :: proc(path: string) -> (c: Config) {
	cwd := os.get_env("PWD")
	home := os.get_env("HOME")
	if home == "" {
		log.panic("environment variable HOME is required")
	}

	os.set_current_directory(home)
	defer os.set_current_directory(cwd)

	data, ok := os.read_entire_file_from_filename(path, context.allocator)
	defer delete(data)

	if !ok do panic("Error read")

	err := json.unmarshal(data, &c)
	if err != nil do log.panic(err)

	return
}
