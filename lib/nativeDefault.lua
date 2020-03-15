-- Default native library for standalone Lua

local native = require("native") -- native integration
local types = require("type")

function java_io_ConsolePrintStream_print(class, method, thread, args)
	if not args[2] then
		error("invalid args")
	end
	io.stdout:write(native.stringToLua(args[2]))
end

function java_lang_System_currentTimeMillis(class, method, thread, args)
	return types.new("long", math.floor(os.time()*1000))
end

function java_lang_System_nanoTime(class, method, thread, args)
	return types.new("long", math.floor(os.clock()*1000000))
end

function lukyt_OS_time()
	return types.new("double", os.time())
end

function lukyt_OS_clock()
	return types.new("double", os.clock())
end

function java_lang_System_getProperty(class, method, thread, args)
	local key = args[1]
	if key.type == "null" then
		error("null key")
	end
	local keyString = native.stringToLua(key)
	local entry = systemProperties[keyString]
	if not entry then
		return types.nullReference()
	else
		return native.luaToString(entry, thread)
	end
end

function java_lang_Runtime_gc(class, method, thread, args)
	collectgarbage("collect")
end

function java_lang_Runtime_load(class, method, thread, args)
	dofile(native.stringToLua(args[2]))
end

function java_lang_Runtime_halt(class, method, thread, args)
	os.exit()
end

function java_lang_Long_parseLong(class, method, thread, args)
	local s = native.stringToLua(args[1])
	local radix = args[2][2]
	return types.new("long", tonumber(s, radix))
end

function java_lang_Long_toString(class, method, thread, args)
	local s = native.luaToString(tostring(args[1][2]), thread)
	return s
end
