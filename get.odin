package opm

import "core:fmt"
import "core:log"
import os "core:os/os2"
import sp "core:path/slashpath"
import st "core:strings"

CmdGet :: struct {
	get:        string `args:"pos=0,hidden"`,
	url:        string `args:"pos=1,required"`,
	global:     bool `args:"name=g"`,
	share_path: string `args:"name=sp"`,
}

LIBS_DIR :: "libs"

when ODIN_OS == .Linux {
	ODIN_PATH :: "/home/sunling/.odin"
}


parse_lib_name :: proc(url: string) -> (name: string) {
	url_split := st.split(url, "/")
	git_name := url_split[len(url_split) - 1]
	name = st.trim_suffix(git_name, ".git")
	return
}

command_get :: proc(model: ^CmdGet, opt: ^Options) {
	ld: string
	if model.global {
		if model.share_path == "" {
			model.share_path = sp.join({ODIN_PATH, "shared"})
		}
		ld = model.share_path
	} else {
		create_libs_path(opt.cwd)
		ld = create_libs_path(opt.cwd)
	}


	lib_name := parse_lib_name(model.url)
	result_wd := sp.join({ld, lib_name})

	os.chdir(ld)
	args := []string{"git", "clone", model.url, result_wd}
	cmd_start(..args)
}
