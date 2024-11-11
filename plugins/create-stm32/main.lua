-- 整体思路
-- 验证工具链
-- -- 确定arm-gcc、openocd在环境变量中，或者使用config指定工具的路径
-- 确定工作目录
-- -- 默认使用当前目录
-- 确定项目名称，默认为stm32
-- 确定stm32库文件，通过config指定文件路径，默认从网络上下载
-- -- 将stm32库文件复制到工作目录，源文件放到lib/src下，头文件放到lib/include目录下
-- 确定target
-- 确定编译器以及编译选项

import("core.base.option")
import("lib.detect.find_program")

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

    local project_name = option.get("name")
    cprint("create project: %s", project_name)

end