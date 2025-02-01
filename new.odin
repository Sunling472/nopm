package nopm

import "core:fmt"
import "core:log"
import "core:mem"
import os "core:os/os2"
import st "core:strings"

ols_file := #load("./templates/ols", string)
odin_fmt_file := #load("./templates/odinfmt", string)
main_file := #load("./templates/main", string)
bin_zed_tasks_file := #load("./templates/zed/bin_tasks", string)

ZED_DIR :: ".zed"


// TODO! Rename flags
CmdNew :: struct {
	name: string `args:"required,pos=0" usage:"project name"`,
	path: string `usage:"Path to project, optional"`, 
	zed:  bool `usage:"Generate zed tasks config, optional"`, 
	lib:  bool `usage:"Create lib file structure, optional"`,
}

FileMap :: map[string]string

lib_root_map := map[string]string {
	"main.odin"    = main_file,
	"ols.json"     = ols_file,
	"odinfmt.json" = odin_fmt_file,
}

bin_root_map := FileMap {
	"ols.json"     = ols_file,
	"odinfmt.json" = odin_fmt_file,
}

src_map := FileMap {
	"main.odin" = main_file,
}

zed_map := FileMap {
	"tasks.json" = bin_zed_tasks_file,
}

bin_dir_map := map[string]FileMap {
	"root" = bin_root_map,
	"src"  = src_map,
	".zed" = zed_map,
}

lib_dir_map := map[string]FileMap {
	"root" = lib_root_map,
	".zed" = zed_map,
}

init_package :: proc(model: ^CmdNew, path: string) {
	os.set_working_directory(path)
	create_files(model)
	cmd_process_start("git", "init")
}

create_files :: proc(model: ^CmdNew) {
	MAIN_FILE_NAME :: "main.odin"
	if !model.lib do os.mkdir("bin")
	dir_map := lib_dir_map if model.lib else bin_dir_map
	for dir, files in dir_map {
		for name, &file in files {
			switch dir {
			case "root":
				f, err_f := os.create(name)
				defer os.close(f)
				if err_f != nil do log.panic(err_f)
				
				if name == MAIN_FILE_NAME {
					file = fmt.aprintf(file, model.name)
				}

				_, err_write := os.write_string(f, file)
				if err_write != nil do log.panic(err_write)
				continue
			case:
				if dir == ZED_DIR && !model.zed do continue

				err_d := os.mkdir(dir)
				if err_d != nil do log.panic(err_d)
				os.chdir(dir)
				defer os.chdir("..")

				f, err_f := os.create(name)
				defer os.close(f)
				if err_f != nil do log.panic(err_f)

				if name == "tasks.json" {
					file = fmt.aprintf(file, model.name, model.name)
				} else if name == MAIN_FILE_NAME {
					file = fmt.aprintf(file, model.name)
				}

				_, err_write := os.write_string(f, file)
				if err_write != nil do log.panic(err_write)
			}
		}
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

	init_package(model, path)
	log.info("Done")
}

