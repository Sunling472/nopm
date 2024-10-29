package opm

import "core:bytes"
import "core:flags"
import "core:fmt"
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
}

New :: struct {
	new:  string `args:"pos=0"`,
	name: string `args:"required,pos=1"`,
	path: string,
}

Get :: struct {
	get: string `args:"pos=0"`,
	url: string `args:"pos=1,required"`,
}

Commands :: enum {
	New,
	Get,
}


Args :: [Commands]string

main :: proc() {
	context.logger = log.create_console_logger()

	commands: Args
	commands[.New] = "new"
	commands[.Get] = "get"

	opts := Options {
		args = commands,
	}

	arg: string = os.args[1]

	if !slice.contains([]string{opts.args[.New], opts.args[.Get]}, arg) {
		log.panic("argument", arg, "is not exists")
	}

	switch arg {
	case commands[.New]:
		flags.parse_or_exit(&opts.new, os.args)
		command_new(&opts.new)
	case commands[.Get]:
		flags.parse_or_exit(&opts.get, os.args)
		command_get(&opts.get)
	}
}
command_new :: proc(model: ^New) {
	path: string = model.path if model.path == "" else "./"
	{
		err: mem.Allocator_Error
		path, err = st.concatenate({path, model.name})
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
}

command_get :: proc(model: ^Get) {

	{
		LIBS_DIR :: "libs"
		if !os.exists(LIBS_DIR) {
			os.make_directory(LIBS_DIR)
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
			p, err_start := os.process_start({command = {"git", "clone", model.url}, stdout = w})
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
