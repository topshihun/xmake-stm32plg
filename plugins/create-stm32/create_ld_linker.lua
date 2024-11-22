
function main(project_dir, file_name)
    local file = io.open(project_dir .. "/" .. file_name, "w")
    if file then

        file:write("ENTRY(Reset_Handler)\n")

        file:write("_estack = ORIGIN(RAM) + LENGTH(RAM)\n")

        file:write("MEMORY\n")
        file:write("{\n")
        file:write("\tRAM (xrw) : ORIGIN = 0x20000000, LENGTH = 64K\n")
        file:write("\tFLASH (rx) : ORIGIN = 0x8000000, LENGTH = 512K\n")
        file:write("}\n")


        file:write("SECTIONS\n")
        file:write("{\n")

        file:write("\t.isr_vector :\n")
        file:write("\t{\n")
        file:write("\t\t. = ALIGN(4);\n")
        file:write("\t\tKEEP(*(.isr_vector))")
        file:write("\t\t. = ALIGN(4);")
        file:write("\t} >FLASH\n")

        file:write("\t.text :\n")
        file:write("\t{\n")
        file:write("\t\t. = ALIGN(4);\n")
        file:write("\t\t*(.text)\n")
        file:write("\t\t*(.text*)\n")
        file:write("\t\t*(.glue_7)\n")
        file:write("\t\t*(.glue_7t)\n")
        file:write("\t\t*(.eh_frame)\n")
        file:write("\t\t KEEP (*(.init))\n")
        file:write("\t\t KEEP (*(.fini))\n")
        file:write("\t\t. = ALIGN(4);\n")
        file:write("\t\t_etext = .;")
        file:write("\t} >FLASH\n")

        file:write("\t.rodata :\n")
        file:write("\t{\n")
        file:write("\t\t. = ALIGN(4);\n")
        file:write("\t\t*(.rodata)\n")
        file:write("\t\t*(.rodata*)\n")
        file:write("\t\tALIGN(4);\n")
        file:write("\t} >FLASH\n")

        file:write("\t.ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH\n")

        file:write("\t.ARM : {\n")
        file:write("\t\t__exidx_start = .;\n")
        file:write("\t\t*(.ARM.exidx)\n")
        file:write("\t\t__exidx_end = .;\n")
        file:write("\t} >FLASH\n")

        file:write("\t.preinit_array : {\n")
        file:write("\t\tPROVIDE_HIDDEN (__preinit_array_start = .);\n")
        file:write("\t\tKEEP (*(.preinit_array))\n")
        file:write("\t\tPROVIDE_HIDDEN (__preinit_array_end = .);\n")
        file:write("\t} >FLASH\n")

        file:write("\t.init_array : {\n")
        file:write("\t\tPROVIDE_HIDDEN (__init_array_start = .);\n")
        file:write("\t\tKEEP (*(.init_array))\n")
        file:write("\t\tPROVIDE_HIDDEN (__init_array_end = .);\n")
        file:write("\t} >FLASH\n")

        file:write("\t.fini_array : {\n")
        file:write("\t\tPROVIDE_HIDDEN (__fini_array_start = .);\n")
        file:write("\t\tKEEP (*(.fini_array))\n")
        file:write("\t\tPROVIDE_HIDDEN (__fini_array_end = .);\n")
        file:write("\t} >FLASH\n")

        file:write("_sidata = LOADADDR(.data);")

        file:write("\t.data : {\n")
        file:write("\t\t. = ALIGN(4);\n")
        file:write("\t\t_sdata = .;\n")
        file:write("\t\t*(.data)\n")
        file:write("\t\t*(.data*)\n")
        file:write("\t\t. = ALIGN(4);\n")
        file:write("\t\t_edata = .;\n")
        file:write("\t} >RAM AT> FLASH\n")

        file:write("\t. = ALIGN(4);\n")

        file:write("\t.bss : {\n")
        file:write("\t\t_sbss = .;\n")
        file:write("\t\t__bss_start__ = _sbss;\n")
        file:write("\t\t*(.bss)\n")
        file:write("\t\t*(.bss*)\n")
        file:write("\t\t*(COMMON)\n")
        file:write("\t\t. = ALIGN(4);\n")
        file:write("\t\t_ebss = .;\n")
        file:write("\t\t__bss_end__ = _ebss;\n")
        file:write("\t} >RAM\n")

        file:write("\t._user_heap_stack : {\n")
        file:write("\t\t. = ALIGN(8);\n")
        file:write("\t\tPROVIDE ( end = . );\n")
        file:write("\t\tPROVIDE ( _end = . );\n")
        file:write("\t\t. = . + 0x200;\n")
        file:write("\t\t. = . + 0x400;\n")
        file:write("\t\t. = ALIGN(8);\n")
        file:write("\t} >RAM\n")

        file:write("\t/DISCARD/ : {\n")
        file:write("\t\tlibc.a (*)")
        file:write("\t\tlibm.a (*)")
        file:write("\t\tlibgcc.a (*)")
        file:write("\t}\n")

        file:write("\t.ARM.attributes 0 : { *(.ARM.attributes) }\n")
        
        file:write("}\n")


        file:close()
    else
        -- fail
        print("Failed to create linker script")
    end
end