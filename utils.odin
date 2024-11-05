package opm

import "core:fmt"
import "core:log"
import dos "core:os"
import os "core:os/os2"
import p "core:path/slashpath"
import sl "core:slice"
import st "core:strings"
import ln "core:sys/linux"
// import "vendor:libc"

create_libs_path :: proc(cwd: string) -> (lib_dir: string) {
	lib_dir = p.join({cwd, "libs"})
	if !os.exists(lib_dir) {
		os.make_directory(lib_dir)
	}
	return
}

// TODO! Add progress
cmd_start :: proc(args: ..string) {
	defer os.exit(0)

	pd := os.Process_Desc {
		command = args,
	}

	p: os.Process
	{
		state, out, std_err, err := os.process_exec(pd, context.temp_allocator)
		if err != nil do log.panic(err)

		// log.info(string(std_err))
		// log.info(string(out))
	}
	// log.info("Done")
}

cmd_process_replace :: proc(name: string, args: ..string) {
	defer os.exit(0)

	log.info("Start process")
	err_exec := dos.execvp(name, args)
	if err_exec != nil do log.panic(err_exec)
}
