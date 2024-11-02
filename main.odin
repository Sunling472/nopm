package opm

import "core:bytes"
import "core:flags"
import "core:fmt"
import "core:io"
import "core:log"
import "core:mem"
import os "core:os/os2"
import "core:slice"
import sc "core:strconv"
import st "core:strings"
import ln "core:sys/linux"


Options :: struct {
	new:  New,
	get:  Get,
	args: Args,
	cwd:  string,
}

New :: struct {
	new:  string `args:"pos=0,hidden"`,
	name: string `args:"required,pos=1"`,
	path: string,
}

Get :: struct {
	get: string `args:"pos=0,hidden"`,
	url: string `args:"pos=1,required"`,
}

Commands :: enum {
	New,
	Get,
}

CommandUnion :: union {
	New,
	Get,
}


Args :: [Commands]string
StringArgs :: map[string]typeid
ArgsHelp :: [Commands]string

ols_file := #load("./ols.json", string)
odin_fmt_file := #load("./odinfmt.json", string)


Answer :: 42

main :: proc() {
	context.logger = log.create_console_logger()

	cu := StringArgs {
		"new" = New,
		"get" = Get,
	}
	commands: Args
	commands[.New] = "new"
	commands[.Get] = "get"

	commands_help: ArgsHelp
	commands_help[.New] = "Example: opm new <project_name> [flags]"
	commands_help[.Get] = "Example: opm get <repo_url> [flags]"

	cwd, err_cwd := os.get_working_directory(context.allocator)
	if err_cwd != nil do log.panic(err_cwd)

	opts := Options {
		args = commands,
		cwd  = cwd,
	}

	{
		out := os.stdout
		w := os.to_writer(out)
		if len(os.args) < 2 {
			for cmd, i in commands {
				b: st.Builder
				defer st.builder_destroy(&b)
				st.write_string(&b, "Command: ")
				st.write_string(&b, cmd)

				fmt.println(st.to_string(b))
				fmt.println(commands_help[i])

				flags.write_usage(w, cu[cmd])

			}
			defer os.close(out)
			defer os.exit(0)
		}
	}

	arg: string = os.args[1]

	if !slice.contains([]string{opts.args[.New], opts.args[.Get]}, arg) {
		log.panic("argument", arg, "is not exists")
	}
	log.info(arg)
	switch arg {
	case commands[.New]:
		flags.parse_or_exit(&opts.new, os.args)
		command_new(&opts.new, &opts)
	case commands[.Get]:
		flags.parse_or_exit(&opts.get, os.args)
		command_get(&opts.get, &opts)
	}
}
command_new :: proc(model: ^New, opt: ^Options) {
	cwd, err_cwd := os.get_working_directory(context.allocator)
	if err_cwd != nil do log.panic(err_cwd)

	path: string = model.path if model.path != "" else cwd
	log.info(path)
	{
		err: mem.Allocator_Error
		path, err = st.concatenate({path, "/", model.name})
		log.info(path)
		if err != nil {
			log.panic(err)
		}
	}

	{
		err := os.make_directory(path)
		assert(err == nil, os.error_string(err))
	}

	os.set_working_directory(path)
	{
		f, err := os.create("main.odin")
		defer os.close(f)
		if err != nil {
			log.panic(err)
		}

		main_text: string = "package %s\n\nmain :: proc () {{}}"
		_, err_write := os.write_string(f, fmt.aprintf(main_text, model.name))
		if err_write != nil {
			log.panic(err_write)
		}
	}
	{
		f, err_f := os.create("ols.json")
		defer os.close(f)
		if err_f != nil do log.panic(err_f)

		_, err_write := os.write_string(f, ols_file)
		if err_write != nil do log.panic(err_write)
	}
	{
		f, err_f := os.create("odinfmt.json")
		defer os.close(f)
		if err_f != nil do log.panic(err_f)

		_, err_write := os.write_string(f, odin_fmt_file)
		if err_write != nil do log.panic(err_write)
	}
}

command_get :: proc(model: ^Get, opt: ^Options) {
	LIBS_DIR :: "libs"
	ld := st.concatenate({opt.cwd, "/", LIBS_DIR})

	{
		log.info(ld)
		if !os.exists(ld) {
			os.make_directory(ld)
		}
		os.chdir(LIBS_DIR)
	}

	{
		r, w, err_pipe := os.pipe()
		if err_pipe != nil do log.panic(err_pipe)
		defer os.close(r)

		p: os.Process
		{
			defer os.close(w)

			lib_name: string
			url_split := st.split(model.url, "/")
			git_name := url_split[len(url_split) - 1]
			lib_name = st.trim_suffix(git_name, ".git")
			log.info(lib_name)
			result_wd := st.concatenate({ld, "/", lib_name})

			p, err_start := os.process_start(
				{command = {"git", "clone", model.url, result_wd}, stdout = w},
			)
			if err_start != nil do log.panic(err_start)
		}

		output, err_out := os.read_entire_file(r, context.temp_allocator)
		if err_out != nil do log.panic(err_out)

		_, process_err := os.process_wait(p)
		if process_err != nil {
			if process_err != .EINVAL {
				log.panic(process_err)
			}
		}


		fmt.print(string(output))
	}

}
