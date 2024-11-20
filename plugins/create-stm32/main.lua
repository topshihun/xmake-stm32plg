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
-- 建立core目录，里面放入core_cm3.c，core_cm3.h
-- 选定启动文件，默认startup_stm32f10x_hd.s（armgcc里面）
-- 编写链接文件STM32F103ZETx_FLASH.ld（自写）
-- 编写项目的xmake.lua
-- 修改core_cm3.c（arm-gcc编译需要修改汇编）

--[[
项目目录结构
include/
    stm32f10x_conf.h
    stm32f10x_it.h
src/
    main.c
    stm32f10x_conf.c
    stm32f10x_it.c
    system_stm32f10x.c
core/
    core_cm3.c
    core_cm3.h
lib/
    include/
        misc.h
        stm32f10x_adc.h
        stm32f10x_bkp.h
        stm32f10x_can.h
        stm32f10x_cec.h
        stm32f10x_crc.h
        stm32f10x_dac.h
        stm32f10x_dbgmcu.h
        stm32f10x_dma.h
        stm32f10x_exti.h
        stm32f10x_flash.h
        stm32f10x_fsmc.h
        stm32f10x_gpio.h
        stm32f10x_i2c.h
        stm32f10x_iwdg.h
        stm32f10x_pwr.h
        stm32f10x_rcc.h
        stm32f10x_rtc.h
        stm32f10x_sdio.h
        stm32f10x_spi.h
        stm32f10x_tim.h
        stm32f10x_usart.h
        stm32f10x_wwdg.h
    src/
        misc.c
        stm32f10x_adc.c
        stm32f10x_bkp.c
        stm32f10x_can.c
        stm32f10x_cec.c
        stm32f10x_crc.c
        stm32f10x_dac.c
        stm32f10x_dbgmcu.c
        stm32f10x_dma.c
        stm32f10x_exti.c
        stm32f10x_flash.c
        stm32f10x_fsmc.c
        stm32f10x_gpio.c
        stm32f10x_i2c.c
        stm32f10x_iwdg.c
        stm32f10x_pwr.c
        stm32f10x_rcc.c
        stm32f10x_rtc.c
        stm32f10x_sdio.c
        stm32f10x_spi.c
        stm32f10x_tim.c
        stm32f10x_usart.c
        stm32f10x_wwdg.c
startup_stm32f10x_hd.s
STM32F103ZETx_FLASH.ld
xmake.lua
--]]

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

    -- correct project lib.zip
    local lib_zip = option.get("lib")
    cprint("current lib: %s", lib_zip)

    -- download stm32 lib
    if(not os.exists(project_dir .. "/" .. lib_zip)) then
        cprint("download stm32 lib")
        http.download("https://github.com/topshihun/xmake-stm32plg/releases/download/stm32/en.stsw-stm32054_v3-6-0.zip", 
            project_dir .. "/" .. lib_zip)
        cprint("${color.success}download finished")
    end
    cprint("extract stm32 lib")
    archive.extract(project_dir .. "/" .. lib_zip, project_dir .. "/lib_dir")
    cprint("${color.success}extract finished")

    -- collect all source files and copy to correct directory
    os.cp(project_dir .. "/lib_dir/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/STM32F10x_StdPeriph_Driver/**.h", project_dir .. "/lib/include/")
    os.cp(project_dir .. "/lib_dir/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/STM32F10x_StdPeriph_Driver/**.c", project_dir .. "/lib/src/")
    cprint("/lib/include/ and /lib/src/ created")

    -- create include directory
    os.mkdir(project_dir .. "/include")
    os.cp(project_dir .. "/lib_dir/STM32F10x_StdPeriph_Lib_V3.6.0/Project/STM32F10x_StdPeriph_Template/stm32f10x_conf.h", project_dir .. "/include/stm32f10x_conf.h")
    os.cp(project_dir .. "/lib_dir/STM32F10x_StdPeriph_Lib_V3.6.0/Project/STM32F10x_StdPeriph_Template/stm32f10x_it.h", project_dir .. "/include/stm32f10x_it.h")
    cprint("/include/stm32f10x_conf.h and /include/stm32f10x_it.h created")

    -- create src directory
    os.mkdir(project_dir .. "/src")
    os.cp(project_dir .. "/lib_dir/STM32F10x_StdPeriph_Lib_V3.6.0/Project/STM32F10x_StdPeriph_Template/stm32f10x_it.c", project_dir .. "/src/stm32f10x_it.c")
    os.cp(project_dir .. "/lib_dir/STM32F10x_StdPeriph_Lib_V3.6.0/Project/STM32F10x_StdPeriph_Template/system_stm32f10x.c", project_dir .. "/src/system_stm32f10x.c")
    os.cp(project_dir .. "/lib_dir/STM32F10x_StdPeriph_Lib_V3.6.0/Project/STM32F10x_StdPeriph_Template/main.c", project_dir .. "/src/main.c")
    cprint("/src/stm32f10x_it.c and /src/system_stm32f10x.c created")
    cprint("/src/main.c created")

    -- create core directory
    os.mkdir(project_dir .. "/core")
    os.cp(project_dir .. "/lib_dir/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/CMSIS/CM3/CoreSupport/core_cm3.c", project_dir .. "/core/core_cm3.c")
    os.cp(project_dir .. "/lib_dir/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/CMSIS/CM3/CoreSupport/core_cm3.h", project_dir .. "/core/core_cm3.h")
    cprint("/core/core_cm3.c and /core/core_cm3.h created")

    -- create startup file
    os.cp(project_dir .. "/lib_dir/STM32F10x_StdPeriph_Lib_V3.6.0/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/gcc_ride7/startup_stm32f10x_hd.s", project_dir .. "/startup_stm32f10x_hd.s")
    cprint("/startup_stm32f10x_hd.s created")

    -- create linker file

    cprint("create linker file finished")

    -- create xmake.lua
    create_xmake_file(project_name, project_dir)
    cprint("${color.success}create xmake file finished")
end