import("core.base.option")
import("lib.detect.find_program")
import("net.http")
import("utils.archive")
import("create_xmake_file")
import("create_ld_linker")
import("common")

local verbose = option.get("verbose")

-- name not to be build, core, include, lib, src and name just be made in characters
function legal_name(name)
    if not string.match(name, "%w") == name then
        common.error_message("name must be made in characters")
    end
    if name == "build" or name == "core" or name == "include" or name == "lib" or name == "src" then
        common.error_message("name not to be " .. name .. ", try other name")
    end
end

function correct_tools(tools)
    for _, tool in ipairs(tools) do
        if not find_program(tool) then
            cprint("${color.error}error: %s not found!", tool)
            return false
        else
            if verbose then
                cprint("${color.success}%s found!", tool)
            end
        end
    end
    return true
end

function main()
    -- find arm-gcc and openocd
    tools = {"arm-none-eabi-gcc", "openocd"}
    if not correct_tools(tools) then
        return
    end

    -- correct project dir
    local project_dir = option.get("dir")
    if verbose then
        cprint("project dir: %s", project_dir)
    end

    -- correct project name
    local project_name = option.get("name")
    legal_name(project_name)
    cprint("create project: %s", project_name)

    -- correct project lib.zip
    local lib_name = option.get("lib")
    legal_name(lib_name)
    local lib_zip = lib_name .. ".zip"
    local lib_dir = project_dir .. "/" .. lib_name
    cprint("stm32 lib name: %s", lib_name)

    -- download stm32 lib
    if(not os.exists(project_dir .. "/" .. lib_zip)) then
        cprint("download stm32 lib")
        http.download("https://github.com/topshihun/xmake-stm32plg/releases/download/stm32/en.stsw-stm32054_v3-6-0.zip", 
            project_dir .. "/" .. lib_zip)
        cprint("${color.success}download finished")
    end
    cprint("extract stm32 lib")
    archive.extract(project_dir .. "/" .. lib_zip, project_dir .. "/" .. lib_name)
    cprint("${color.success}extract finished")

    -- collect all source files and copy to correct directory
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/STM32F10x_StdPeriph_Driver/**.h", project_dir .. "/lib/include/")
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/STM32F10x_StdPeriph_Driver/**.c", project_dir .. "/lib/src/")
    cprint("/lib/include/ and /lib/src/ created")

    -- create include directory
    os.mkdir(project_dir .. "/include")
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/stm32f10x.h", project_dir .. "/include/stm32f10x.h")
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Project/STM32F10x_StdPeriph_Template/stm32f10x_conf.h", project_dir .. "/include/stm32f10x_conf.h")
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Project/STM32F10x_StdPeriph_Template/stm32f10x_it.h", project_dir .. "/include/stm32f10x_it.h")
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/system_stm32f10x.h", project_dir .. "/include/system_stm32f10x.h")
    cprint("/include/stm32f10x_conf.h and /include/stm32f10x_it.h created")

    -- create src directory
    os.mkdir(project_dir .. "/src")
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Project/STM32F10x_StdPeriph_Template/stm32f10x_it.c", project_dir .. "/src/stm32f10x_it.c")
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Project/STM32F10x_StdPeriph_Template/system_stm32f10x.c", project_dir .. "/src/system_stm32f10x.c")
    cprint("/src/stm32f10x_it.c and /src/system_stm32f10x.c created")
    -- create main
    local main_str = [[#define USE_STDPERIPH_DRIVER
#define STM32F10X_HD
#include "stm32f10x.h"
    
int main(void)
{
    return 0;
}]]
    io.open(project_dir .. "/src/main.c", "w"):write(main_str)
    cprint("/src/main.c created")

    -- create core directory
    os.mkdir(project_dir .. "/core")
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/CMSIS/CM3/CoreSupport/core_cm3.c", project_dir .. "/core/core_cm3.c")
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/CMSIS/CM3/CoreSupport/core_cm3.h", project_dir .. "/core/core_cm3.h")
    cprint("/core/core_cm3.c and /core/core_cm3.h created")

    -- create startup file
    os.cp(lib_dir .. "/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/gcc_ride7/startup_stm32f10x_hd.s", project_dir .. "/startup_stm32f10x_hd.s")
    cprint("/startup_stm32f10x_hd.s created")

    -- create linker file
    local file_name = "stm32.ld"
    create_ld_linker(project_dir, file_name)
    cprint("create linker file finished")

    -- create xmake.lua
    create_xmake_file(project_name, project_dir)
    cprint("${color.success}create xmake file finished")
end