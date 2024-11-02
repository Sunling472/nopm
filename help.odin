package opm

import "core:flags"
import "core:fmt"
import os "core:os/os2"
import st "core:strings"

command_list := map[string]typeid {
	"new" = CmdNew,
	"get" = CmdGet,
}

command_help := map[string]string {
	"new" = "Example: opm new <project_name> [flags]",
	"get" = "Example: opm get <repo_url> [flags]",
}

get_help :: proc() {
	out := os.stdout
	defer os.close(out)
	w := os.to_writer(out)

	for k, v in command_list {
		b: st.Builder
		defer st.builder_destroy(&b)
		st.write_string(&b, "Command: ")
		st.write_string(&b, k)

		fmt.println(st.to_string(b))
		fmt.println(command_help[k])

		flags.write_usage(w, command_list[k])
	}
	defer os.exit(0)
}
