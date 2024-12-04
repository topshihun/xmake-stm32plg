-- 编写项目的xmake.lua
-- -- 
-- -- 确定编译器以及编译选项

function main(project_name, project_dir)
--[[
local target_name = "target_name"
set_project("stm32-xmake")

set_version("1.0.0")

add_rules("mode.debug", "mode.release")

toolchain("arm-none-eabi")
    set_kind("standalone")
    set_sdkdir("D:/arm-gnu-toolchain")
toolchain_end()

task("download")

    on_run(function ()

        os.exec("openocd -f \"your path\" -f \"your path\" -c init -c halt -c \"flash write_image erase ./build/".. target_name .. ".bin 0x08000000\" -c reset -c shutdown")

    end)

    set_menu {
                -- usage
                usage = "xmake download"

                -- description
            ,   description = "Use opocd command. You must to change some params in xmake.lua."

                -- options
            ,   options = {}
            }



target(target_name..".elf")
    set_kind("binary") 

    set_toolchains("arm-none-eabi")  

    set_plat("cross")
    set_arch("m3")
    
    -- add_defines("STM32F10X_HD", "USE_STDPERIPH_DRIVER")
    
    add_links("c", "m", "nosys", "rdimon");
    
    add_files("startup_stm32f10x_hd.s");

    add_cflags(
        "-Og",
        "-mcpu=cortex-m3",
        "-mthumb",
        "-Wall",
        "-fdata-sections",
        "-ffunction-sections",
        "-g -gdwarf-2",
        {force = true}
    )

    add_asflags(
        "-Og",
        "-mcpu=cortex-m3",
        "-mthumb",
        "-Wall",
        "-fdata-sections", 
        "-ffunction-sections",
        "-g -gdwarf-2",
        {force = true}
    )

    add_ldflags(
        "-Og",
        "-mcpu=cortex-m3",
        "-TSTM32F103VETx_FLASH.ld",
        "-Wl,--gc-sections",
        "--specs=nosys.specs",
        "-u _printf_float",  
        {force = true}
    )
    
    add_includedirs("core/include", "lib/include", "include")
    add_files("core/src/*.c", "lib/src/*.c", "src/*.c")
   
    if is_mode("debug") then 
        add_cflags("-g", "-gdwarf-2")
    end

    after_build(
        function(target)
        cprint("Compile finished!!!")
        cprint("Next, generate hex and bin files.")
        os.exec("arm-none-eabi-objcopy -O ihex ./build/cross/m3/release/" .. target_name .. ".elf ./build/"..target_name..".hex")
        os.exec("arm-none-eabi-objcopy -O binary ./build/cross/m3/release/" .. target_name .. ".elf ./build/" .. target_name .. ".bin")
        print("Generate hex and bin files ok!!!")

        print(" ");
        print("****************Storage space occupancy situation*************************")
        os.exec("arm-none-eabi-size -Ax ./build/cross/m3/release/"..target_name..".elf")
        os.exec("arm-none-eabi-size -Bx ./build/cross/m3/release/"..target_name..".elf")
        os.exec("arm-none-eabi-size -Bd ./build/cross/m3/release/"..target_name..".elf")
        -- print("heap-堆, stack-栈, .data-已初始化的变量全局/静态变量, .bss-未初始化的data, .text-代码和常量")
        -- os.run("arm-none-eabi-objdump.exe -D ./build/cross/m3/release/"..target_name..".elf > "..target_name..".s")
    end)

--]]
    local elf_name = project_name .. ".elf"
    local hex_name = project_name .. ".hex"
    local bin_name = project_name .. ".bin"

    local init_project = vformat("set_project(\"%s\")\nset_version(\"1.0.0\")", project_name)

    local init_mode = {"mode.debug", "mode.release"}

    local init_toolchain = {}
    init_toolchain["toolchain"] = "arm-none-eabi"
    init_toolchain["kind"] = "standalone"
    init_toolchain["sdkdir"] = "D:/arm-gnu-toolchain"

    local init_task = {}
    init_task["task"] = "download"
    local buff = vformat("os.exec(\"openocd -f interface/cmsis-dap.cfg -f target/stm32f10x.cfg -c init -c halt -c \\\"flash write_image erase ./build/%s 0x08000000\\\" -c reset -c shutdown\")", elf_name)
    init_task["on_run"] = vformat("function()\n\t\t%s\n\tend", buff)
    init_task["menu"] = {}
    init_task["menu"]["usage"] = "xmake download"
    init_task["menu"]["description"] = "Use opocd command. You must to change some params in xmake.lua."
    init_task["menu"]["options"] = {}

    local init_target = {}
    init_target["target"] = elf_name
    init_target["kind"] = "binary"
    init_target["toolchains"] = {"arm-none-eabi"}
    init_target["plat"] = "cross"
    init_target["arch"] = "m3"
    -- init_target["defines"] = {"STM32F10X_HD", "USE_STDPERIPH_DRIVER"}
    init_target["links"] = {"c", "m", "nosys", "rdimon"}
    init_target["files"] = {"startup_stm32f10x_hd.s"}
    init_target["cflags"] = {"-Og", "-mcpu=cortex-m3", "-mthumb", "-Wall", "-fdata-sections", "-ffunction-sections", "-g -gdwarf-2"}
    init_target["asflags"] = {"-Og", "-mcpu=cortex-m3", "-mthumb", "-Wall", "-fdata-sections", "-ffunction-sections", "-g -gdwarf-2"}
    init_target["ldflags"] = {"-Og", "-mcpu=cortex-m3", "-Tstm32.ld", "-Wl,--gc-sections", "--specs=nosys.specs", "-u _printf_float"}
    init_target["includedirs"] = {"core", "lib/include", "include"}
    init_target["files"] = {"core/*.c", "lib/src/*.c", "src/*.c"}
    init_target["after_build"] = vformat([[
    after_build(
        function(target)
        cprint("Compile finished!!!")
        cprint("Next, generate hex and bin files.")
        os.exec("arm-none-eabi-objcopy -O ihex ./build/cross/m3/release/]] .. elf_name .. [[ ./build/]] .. hex_name .. [[")
        os.exec("arm-none-eabi-objcopy -O binary ./build/cross/m3/release/]] .. elf_name .. [[ ./build/]] .. bin_name .. [[")
        print("Generate hex and bin files ok!!!")

        print(" ");
        print("****************Storage space occupancy situation*************************")
        os.exec("arm-none-eabi-size -Ax ./build/cross/m3/release/]] .. elf_name .. [[")
        os.exec("arm-none-eabi-size -Bx ./build/cross/m3/release/]] .. elf_name .. [[")
        os.exec("arm-none-eabi-size -Bd ./build/cross/m3/release/]] .. elf_name .. [[")
        end)]]
    )

    -- write file
    local file = io.open(project_dir .. "/xmake.lua", "w")
    if file then
        file:write(init_project .. "\n")

        file:write(vformat("add_rules("))
        for k, v in pairs(init_mode) do
            file:write(vformat("\"%s\"", v))
            if k ~= #init_mode then
                file:write(", ")
            end
        end
        file:write(")\n")
        file:write("\n")

        file:write(vformat("toolchain(\"%s\")\n", init_toolchain["toolchain"]))
        file:write(vformat("\tset_kind(\"%s\")\n", init_toolchain["kind"]))
        file:write(vformat("\tset_sdkdir(\"%s\")\n", init_toolchain["sdkdir"]))
        file:write("toolchain_end()\n")
        file:write("\n")

        file:write(vformat("task(\"%s\")\n", init_task["task"]))
        file:write(vformat("\ton_run(%s)\n", init_task["on_run"]))
        file:write(vformat("\tset_menu {\n"))
        file:write(vformat("\t\tusage = \"%s\",\n", init_task["menu"]["usage"]))
        file:write(vformat("\t\tdescription = \"%s\",\n", init_task["menu"]["description"]))
        file:write(vformat("\t\toptions = {\n"))
        for k, v in pairs(init_task["menu"]["options"]) do
            file:write(vformat("\t\t\t{\"%s\", \"%s\"}\n", k, v))
        end
        file:write(vformat("\t\t}\n"))
        file:write(vformat("\t}\n"))
        file:write("task_end()\n")
        file:write("\n")

        file:write(vformat("target(\"%s\")\n", init_target["target"]))

        file:write(vformat("\tif is_mode(\"%s\") then\n", init_mode[1]))
        file:write(vformat("\t\tadd_cflags(\"-g\", \"-gdwarf-2\")\n"))
        file:write(vformat("\tend\n"))
        
        file:write(vformat("\tset_kind(\"%s\")\n", init_target["kind"]))
        file:write(vformat("\tset_toolchains({\"%s\"})\n", table.concat(init_target["toolchains"], ", ")))
        file:write(vformat("\tset_plat(\"%s\")\n", init_target["plat"]))
        file:write(vformat("\tset_arch(\"%s\")\n", init_target["arch"]))
        file:write("\tadd_links(")
        for k, v in pairs(init_target["links"]) do
            file:write(vformat("\"%s\"", v))
            if k ~= #init_target["links"] then
                file:write(", ")
            end
        end
        file:write(")\n")
        file:write("\tadd_files(")
        for k, v in pairs(init_target["files"]) do
            file:write(vformat("\"%s\"", v))
            if k ~= #init_target["files"] then
                file:write(", ")
            end
        end
        file:write(")\n")
        file:write("\tadd_includedirs(")
        for k, v in pairs(init_target["includedirs"]) do
            file:write(vformat("\"%s\"", v))
            if k ~= #init_target["includedirs"] then
                file:write(", ")
            end
        end
        file:write(")\n")
        file:write("\tadd_cflags(")
        for k, v in pairs(init_target["cflags"]) do
            file:write(vformat("\"%s\", ", v))
        end
        file:write("{force = true})\n")
        file:write("\tadd_asflags(")
        for k, v in pairs(init_target["asflags"]) do
            file:write(vformat("\"%s\", ", v))
        end
        file:write("{force = true})\n")
        file:write("\tadd_ldflags(")
        for k, v in pairs(init_target["ldflags"]) do
            file:write(vformat("\"%s\", ", v))
        end
        file:write("{force = true})\n")
        file:write(init_target["after_build"] .. "\n")
        file:write("target_end()\n")

        file:close()
    end

end