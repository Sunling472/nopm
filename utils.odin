package opm

import "core:fmt"
import "core:log"
import os "core:os/os2"
import p "core:path/slashpath"
import sl "core:slice"

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
		p, err := os.process_start(pd)
		log.info("Start")
		if err != nil do log.panic(err)
	}
	log.info("Waiting...")
	{
		_, err := os.process_wait(p)
		if err != nil && err != .EINVAL do log.panic(err)
	}
	log.info("Done")
}
