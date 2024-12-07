common = {}

function common.error_message(msg)
    cprint("${color.error}error: %s", msg)
    os.exit(1)
end

return common