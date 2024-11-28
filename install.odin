package nopm

import "core:log"
import "core:os"
import sp "core:path/slashpath"
import st "core:strings"

CmdInstall :: struct {
	path: string `args:"pos=0"`,
	url:  bool,
}

create_bin_dir :: proc(path: string) {
	ok := os.exists(path)
	if !ok {
		err := os.make_directory(path)
		if err != nil do log.panic(err)
	}

	// cwd := os.get_current_directory()
	// bin_dir :: "odin-apps"
	// home := os.get_env("HOME")

	// err_set_dir := os.set_current_directory(home)
	// if err_set_dir != nil do log.panic(err_set_dir)
	// defer os.set_current_directory(cwd)

	// dir_exists := os.exists(bin_dir)
	// if !dir_exists {
	// 	err_md := os.make_directory(bin_dir)
	// 	if err_md != nil do log.panic(err_md)
	// }

	// res_path = sp.join({home, bin_dir})

	// return
}

cmd_install :: proc(model: ^CmdInstall, opts: ^Options) {
	cfg := load_config(DEFAUL_CONFIG_PATH)
	create_bin_dir(cfg.install_path)
	if model.url {
		install_from_git(model.path, &cfg)
	} else {
		install_from_dir(model.path, opts, &cfg)
	}
}

install_from_dir :: proc(path: string, opts: ^Options, cfg: ^Config) {
	package_path: string

	switch path {
	case ".", "./":
		package_path = opts.cwd
	case:
		package_path = path
	}

	path_slice := st.split(package_path, "/")
	app_name := path_slice[len(path_slice) - 1]
	os.set_current_directory(package_path)

	install_path := sp.join({cfg.install_path, app_name})
	install_path = st.trim_suffix(install_path, "/")

	out_flag, err_conc := st.concatenate({"-out=", install_path})
	if err_conc != nil do log.panic(err_conc)

	cmd_process_replace("odin", "build", ".", out_flag)
}

install_from_git :: proc(url: string, cfg: ^Config) {
	tmp_dir :: "odin-tmp"
	home := os.get_env("HOME")

	// cd home dir
	err_set_dir_home := os.set_current_directory(home)
	if err_set_dir_home != nil do log.panic(err_set_dir_home)

	// check-create temporary dir
	dir_exists := os.exists(tmp_dir)
	if !dir_exists {
		os.make_directory(tmp_dir)
	}

	// enter to temporary dir
	err_set_dir_tmp := os.set_current_directory(tmp_dir)
	if err_set_dir_tmp != nil do log.panic(err_set_dir_tmp)

	// get lib name and git clone
	lib_name := parse_lib_name(url)
	if !os.exists(lib_name) {
		cmd_process_start("git", "clone", url)
	}

	// enter to lib dir
	err_set_dir_lib := os.set_current_directory(lib_name)
	if err_set_dir_lib != nil do log.panic(err_set_dir_lib)

	// odin build
	install_path := sp.join({cfg.install_path, lib_name})
	out_flag := st.concatenate({"-out=", install_path})
	log.info("install path:", install_path)
	log.info("out_flag:", out_flag)
	log.info("cwd:", os.get_current_directory())
	cmd_process_start("odin", "build", ".", out_flag)

	tmp_path := sp.join({home, tmp_dir})
	clean_temp_dir(tmp_path)
}

clean_temp_dir :: proc(path: string) {
	cmd_process_replace("rm", "-rf", path)
}
