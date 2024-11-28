package nopm

import "core:fmt"
import "core:log"
import os "core:os/os2"
import st "core:strings"

ODIN_MODULE :: "odin"

CmdUpdate :: struct {
	module: string `args:"pos=0"`,
}

update_odin :: proc() {}

update_all_submodules_cmd :: proc() {
	os.set_working_directory(LIBS_DIR)
	args := []string{"submodule", "update", "--remote", "--recursive"}

	cmd_process_replace(GIT, ..args)
}

command_update :: proc(model: ^CmdUpdate, opt: ^Options) {
	ld := create_libs_path(opt.cwd)
	if model.module == ODIN_MODULE do return


}
