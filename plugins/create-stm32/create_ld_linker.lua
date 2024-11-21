
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
        file:write("}\n")


        file:close()
    end
end