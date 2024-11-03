package opm

import "core:fmt"
import "core:log"
import os "core:os/os2"
import st "core:strings"

ODIN_MODULE :: "odin"

CmdUpdate :: struct {
	update: string `args:"pos=0,hidden"`,
	module: string `args:"pos=1"`,
}

update_odin :: proc() {}

command_update :: proc(model: ^CmdUpdate, opt: ^Options) {
	ld := create_libs_path(opt.cwd)
	if model.module == ODIN_MODULE do return

	p: os.Process

}
