-- 整体思路
-- 验证工具链
-- -- 确定arm-gcc、openocd在环境变量中，或者使用config指定工具的路径
-- 确定工作目录
-- -- 默认使用当前目录
-- 确定项目名称，默认为stm32
-- 确定stm32库文件，通过lib指定文件路径，默认从网络上下载
-- -- 解压下载的文件
-- -- 将stm32库文件（lib/Libraries下）复制到工作目录，源文件放到lib/src下，头文件放到lib/include目录下
-- 建立include目录，放入stm32f10x_conf.h、stm32f10x_it.h（templete里）
-- 建立src目录，里面放入main.c、stm32f10x_it.c、system_stm32f10x.c（templete里）
-- 编写项目的xmake.lua

import("core.base.option")
import("lib.detect.find_program")
import("net.http")
import("utils.archive")
import("create_xmake_file")

function main()
    -- find arm-gcc and openocd
    local arm_gcc = find_program("arm-none-eabi-gcc")
    if not arm_gcc then
        cprint("${color.error}arm-gcc not found!")
        return
    else
        cprint("${color.success}%s found!", arm_gcc)
    end
    local openocd = find_program("openocd")
    if not openocd then
        cprint("${color.error}openocd not found!")
        return
    else
        cprint("${color.success}%s found!", openocd)
    end

    -- correct project dir
    local project_dir = option.get("dir")
    if not project_dir then
        project_dir = os.curdir()
    end
    cprint("project dir: %s", project_dir)

    -- correct project name
    local project_name = option.get("name")
    cprint("create project: %s", project_name)

    -- download stm32 lib
    if(not os.exists(project_dir .. "/en.stsw-stm32054_v3-6-0.zip")) then
        http.download("https://github.com/topshihun/xmake-stm32plg/releases/download/stm32/en.stsw-stm32054_v3-6-0.zip", 
            project_dir .. "en.stsw-stm32054_v3-6-0.zip")
    end
    archive.extract(project_dir .. "en.stsw-stm32054_v3-6-0.zip", project_dir .. "/en.stsw-stm32054_v3-6-0")

    -- collect all source files and copy to correct directory
    os.cp(project_dir .. "/en.stsw-stm32054_v3-6-0/**.h", project_dir .. "/lib/include/")
    os.cp(project_dir .. "/en.stsw-stm32054_v3-6-0/**.c", project_dir .. "/lib/src/")

    -- create include directory
    os.mkdir(project_dir .. "/include")

    -- create src directory
    os.mkdir(project_dir .. "/src")
    -- create main.c
    os.writefile(project_dir .. "/src/main.c", [[]])

    -- create xmake.lua
    create_xmake_file(project_name, project_dir)
end