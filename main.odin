package nopm

import "core:flags"
import "core:io"
import "core:log"
import os "core:os/os2"
import sp "core:path/slashpath"
import "core:slice"
import st "core:strings"


LIBS_DIR :: "libs"
DEFAUL_CONFIG_PATH :: ".config/nopm"
GIT :: "git"

Options :: struct {
	new:     CmdNew,
	get:     CmdGet,
	install: CmdInstall,
	cwd:     string,
}

Commands :: enum {
	New,
	Get,
	Init,
	Update,
	Install,
	Clean,
}

Args :: [Commands]string

main :: proc() {
	context.logger = log.create_console_logger()

	home := os.get_env("HOME", context.allocator)
	tmp_path := sp.join({home, "odin-tmp"})

	if len(os.args) < 2 {
		get_help()
	}

	commands: Args = {
		.New     = "new",
		.Get     = "get",
		.Init    = "init",
		.Update  = "update",
		.Install = "install",
		.Clean   = "clean",
	}

	cwd, err_cwd := os.get_working_directory(context.allocator)
	if err_cwd != nil do log.panic(err_cwd)

	opts := Options {
		cwd = cwd,
	}

	args := os.args[1:]
	arg := os.args[1]

	switch arg {
	case commands[.New]:
		flags.parse_or_exit(&opts.new, args)
		command_new(&opts.new, &opts)
	case commands[.Get]:
		flags.parse_or_exit(&opts.get, args)
		command_get(&opts.get, &opts)
	case commands[.Init]:
		buff := st.split(opts.cwd, "/")
		name := buff[len(buff) - 1]
		init_package(&opts.new, opts.cwd)
	case commands[.Update]:
	case commands[.Install]:
		flags.parse_or_exit(&opts.install, args)
		cmd_install(&opts.install, &opts)
	case commands[.Clean]:
		clean_temp_dir(tmp_path)
	case "-h", "-help", "--help":
		get_help()
	case:
		log.panic("argument", arg, "is not exists")
	}

}
