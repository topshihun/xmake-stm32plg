task("create-stm32")
    set_category("plugin")
    on_run("main")
    set_menu {
        usage = "xmake create-stm32 [options] [arguments]",
        description = "Create a stm32 project.",
        options = 
        {
            -- {'abbreviation', "full name", "mode(kv,k,vs)", "describe"}
            {'n', "name", "kv", "stm32", "Set the project name."},
            {nil, "dir", "kv", "./", "Set the project dirctory."},
            {nil, "lib", "kv", "stm32_lib", "Set lib zip."},
            {'v', "verbose", "k", false, "Print lots of verbose information."}
        }
    }