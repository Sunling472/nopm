package nopm

import "core:encoding/json"
import "core:log"
import "core:os"
import sp "core:path/slashpath"

Config :: struct {
	odin_path:    string,
	install_path: string,
}

FILE_NAME :: "config.json"

load_config :: proc(path: string) -> (c: Config) {
	cwd := os.get_env("PWD")
	home := os.get_env("HOME")

	path := sp.join({path, FILE_NAME})

	if home == "" {
		log.panic("environment variable HOME is required")
	}

	os.set_current_directory(home)
	defer os.set_current_directory(cwd)

	data, ok := os.read_entire_file_from_filename(path, context.allocator)
	defer delete(data)

	if !ok {
		err_make_config_dir := os.make_directory(path)
		if err_make_config_dir != nil do log.panic(err_make_config_dir)

		cfg, err_create_cfg := os.open("", os.O_APPEND, 0777)
		if err_create_cfg != nil do log.panic(err_create_cfg)
		defer os.close(cfg)

		os.write_string(cfg, "{\n\"odin_path\": null, \"install_path: null\"\n}")
	}

	log.info(path)

	err_unmarshal := json.unmarshal(data, &c)
	if err_unmarshal != nil do log.panic(err_unmarshal)

	return
}
