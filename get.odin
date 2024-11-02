package opm

import "core:fmt"
import "core:log"
import os "core:os/os2"
import st "core:strings"

CmdGet :: struct {
	get: string `args:"pos=0,hidden"`,
	url: string `args:"pos=1,required"`,
}

parse_lib_name :: proc(url: string) -> (name: string) {
	url_split := st.split(url, "/")
	git_name := url_split[len(url_split) - 1]
	name = st.trim_suffix(git_name, ".git")
	return
}

command_get :: proc(model: ^CmdGet, opt: ^Options) {
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
			lib_name := parse_lib_name(model.url)
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
