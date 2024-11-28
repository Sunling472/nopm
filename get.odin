package nopm

import "core:fmt"
import "core:log"
import os "core:os/os2"
import sp "core:path/slashpath"
import st "core:strings"


// TODO! Rename flags
CmdGet :: struct {
	url:       string `args:"pos=0,required"`,
	submodule: bool `args:"name=sb"`,
	global:    bool `args:"name=g"`,
	odin_path: string `args:"name=op"`,
	clib:      bool `args:"name=cl"`,
}

LIBS_DIR :: "libs"
DEFAUL_CONFIG_PATH :: ".config/nopm/config.json"
GIT :: "git"


parse_lib_name :: proc(url: string) -> (name: string) {
	url_split := st.split(url, "/")
	git_name := url_split[len(url_split) - 1]
	name = st.trim_suffix(git_name, ".git")
	return
}

get_submodule :: proc(url, ld: string) {
	args := []string{"submodule", "add", url, ld}
	cmd_process_replace(GIT, ..args)
}

command_get :: proc(model: ^CmdGet, opt: ^Options) {
	cfg := load_config(DEFAUL_CONFIG_PATH)

	ld: string
	if model.global {
		if model.odin_path == "" {
			ld = sp.join({cfg.odin_path, "shared"})
		} else {
			ld = sp.join({model.odin_path, "shared"})
		}

	} else if model.clib {
		ld = create_libs_path(opt.cwd, "clibs")
	} else {
		ld = create_libs_path(opt.cwd)
	}


	lib_name := parse_lib_name(model.url)
	result_wd := sp.join({ld, lib_name})

	os.chdir(ld)
	if model.submodule {
		get_submodule(model.url, result_wd)
	} else {
		cmd_process_replace(GIT, "clone", model.url, result_wd)
	}
}
