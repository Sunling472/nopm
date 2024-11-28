package nopm

import "core:fmt"
import "core:log"
import "core:mem"
import os "core:os/os2"
import st "core:strings"

ols_file := #load("./templates/ols", string)
odin_fmt_file := #load("./templates/odinfmt", string)
main_file := #load("./templates/main", string)

// TODO! Rename flags
CmdNew :: struct {
	name: string `args:"required,pos=0"`,
	path: string,
}

file_map := map[string]string {
	"main.odin"    = main_file,
	"ols.json"     = ols_file,
	"odinfmt.json" = odin_fmt_file,
}

init_package :: proc(name, path: string) {
	os.set_working_directory(path)
	create_files(name)
	cmd_process_start("git", "init")
}

create_files :: proc(project_name: string) {
	for name, &file in file_map {
		f, err_f := os.create(name)
		defer os.close(f)
		if err_f != nil do log.panic(err_f)

		if name == "main.odin" {
			file = fmt.aprintf(file, project_name)
		}

		_, err_write := os.write_string(f, file)
		if err_write != nil do log.panic(err_write)
	}
}

command_new :: proc(model: ^CmdNew, opt: ^Options) {

	path: string = model.path if model.path != "" else opt.cwd
	{
		err: mem.Allocator_Error
		path, err = st.concatenate({path, "/", model.name})
		if err != nil {
			log.panic(err)
		}
	}

	{
		err := os.make_directory(path)
		assert(err == nil, os.error_string(err))
	}

	init_package(model.name, path)
	log.info("Done")
}
