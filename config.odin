package opm

import "core:encoding/json"
import "core:log"
import "core:os"

Config :: struct {
	odin_path: string,
}

load_config :: proc(path: string) -> (c: Config) {
	path := "../../.config/opm/config.json"
	data, ok := os.read_entire_file(path)
	defer delete(data)

	if !ok do panic("Error read")

	err := json.unmarshal(data, &c)
	if err != nil do log.panic(err)

	return
}
