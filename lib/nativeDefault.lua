-- Default native library for standalone Lua

local native = require("native") -- native integration
local types = require("type")

function java_io_ConsolePrintStream_print(class, method, thread, args)
	if not args[2] then
		error("invalid args")
	end
	io.stdout:write(native.stringToLua(args[2]))
end

function java_io_ConsoleInputStream_read(class, method, thread, args)
	local ok, result = pcall(function()
		return types.new("int", string.byte(io.read(1)))
	end)
	if ok then
		return result
	else
		os.exit(0) -- user-trigerred interruption
	end
end

function java_lang_System_arraycopy(class, method, thread, args)
	local src = args[1][2]
	local srcPos = args[2][2]
	local dest = args[3][2]
	local destPos = args[4][2]
	local length = args[5][2]
	if src.type ~= "array" then
		error("src is not an array!")
	elseif dest.type ~= "array" then
		error("dest is not an array!")
	end

	for i=1,length do
		dest.array[i+destPos] = src.array[i+srcPos]
	end
end

function lukyt_OS_time()
	return types.new("double", os.time())
end

function lukyt_OS_clock()
	return types.new("double", os.clock())
end

function java_lang_Object_hashCode(class, method, thread, args)
	local this = args[1]
	return types.new("int", this.hashCode)
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
