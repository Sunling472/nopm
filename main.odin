package opm

import "core:flags"
import "core:io"
import "core:log"
import os "core:os/os2"
import "core:slice"
import st "core:strings"


Options :: struct {
	new: CmdNew,
	get: CmdGet,
	cwd: string,
}

Commands :: enum {
	New,
	Get,
}

Args :: [Commands]string

main :: proc() {
	context.logger = log.create_console_logger()

	if len(os.args) < 2 {
		get_help()
	}

	commands: Args
	commands[.New] = "new"
	commands[.Get] = "get"

	cwd, err_cwd := os.get_working_directory(context.allocator)
	if err_cwd != nil do log.panic(err_cwd)

	opts := Options {
		cwd = cwd,
	}

	arg: string = os.args[1]

	switch arg {
	case commands[.New]:
		flags.parse_or_exit(&opts.new, os.args)
		command_new(&opts.new, &opts)
	case commands[.Get]:
		flags.parse_or_exit(&opts.get, os.args)
		command_get(&opts.get, &opts)
	case "-h", "-help", "--help":
		get_help()
	case:
		log.panic("argument", arg, "is not exists")
	}

}
