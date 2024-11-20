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
end