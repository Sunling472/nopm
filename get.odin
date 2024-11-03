package opm

import "core:fmt"
import "core:log"
import os "core:os/os2"
import sp "core:path/slashpath"
import st "core:strings"

CmdGet :: struct {
	get:    string `args:"pos=0,hidden"`,
	url:    string `args:"pos=1,required"`,
	global: string,
}

LIBS_DIR :: "libs"


parse_lib_name :: proc(url: string) -> (name: string) {
	url_split := st.split(url, "/")
	git_name := url_split[len(url_split) - 1]
	name = st.trim_suffix(git_name, ".git")
	return
}

command_get :: proc(model: ^CmdGet, opt: ^Options) {
	create_libs_path(opt.cwd)
	ld := create_libs_path(opt.cwd)
	lib_name := parse_lib_name(model.url)
	result_wd := sp.join({ld, lib_name})

	os.chdir(ld)
	args := []string{"git", "clone", model.url, result_wd}
	log.info(ld)
	log.info(args)
	cmd_start(..args)
}
