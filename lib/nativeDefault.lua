-- Default native library 
local native = require("native") -- native integration

function java_io_ConsolePrintStream_print(class, method, args)
	if not args[2] then
		error("invalid args")
	end
	io.stdout:write(native.stringToLua(args[2]))
end
