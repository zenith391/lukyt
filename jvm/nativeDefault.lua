-- Default native library for standalone Lua

local native = require("native") -- native integration
local types = require("type")
local classLoader = require("classLoader")
local internedStrings = {}

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

function java_lang_Throwable_currentStackTrace(class, method, thread, args)
	local stackTrace = {}
	local threadTrace = thread.stackTrace

	local objectClass, err = require("classLoader").loadClass("java/lang/StackTraceElement", true)
	if not objectClass then
		error("could not import " .. path .. ": " .. err)
	end

	for i=#threadTrace-1,1,-1 do
		local v = threadTrace[i]
		local m = v.method
		local declaringClass = native.luaToString(string.gsub(m.class.name, "/", "."), thread)
		local methodName = native.luaToString(m.name, thread)
		local fileName = types.nullReference()
		if m.class.sourceFile then
			fileName = native.luaToString(m.class.sourceFile, thread)
		end
		local isNative = 0
		if m.code.nativeName then
			isNative = 1
		end
		isNative = types.new("I", isNative)
		table.insert(stackTrace, thread:instantiateClass(objectClass, {declaringClass, methodName, fileName, types.new("int", -1), isNative}, true, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IZ)V"))
	end
	return types.referenceForArray(stackTrace)
end

function java_lang_String_intern(class, method, thread, args)
	local this = args[1]
	local luaRepresentation = native.stringToLua(this)
	for k, v in pairs(internedStrings) do
		if v[1] == luaRepresentation then
			return v[2]
		end
	end
	table.insert(internedStrings, {
		{
			luaRepresentation,
			this
		}
	});
	return this
end

function java_lang_Object_getClass(class, method, thread, args)
	local this = args[1][2]
	local thisClass = this.class[2].class
	return classLoader.classObject(thisClass, thread)
end

function java_lang_Class_getClassName(class, method, thread, args)
	local ref = args[1][2]
	return native.luaToString(classLoader.getReferencedClass(ref).name, thread)
end
