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

function java_lang_Object_hashCode(class, method, thread, args)
	local this = args[1][2]
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
	os.exit(args[2][2])
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

function java_lang_Object_newClass(class, method, thread, args)
	local this = args[1][2]
	local thisClass = this.class[2].class
	return classLoader.classObject(thisClass, thread)
end

function java_lang_Class_getClassName(class, method, thread, args)
	local ref = args[1][2]
	return native.luaToString(classLoader.getReferencedClass(ref).name, thread)
end

-- Lua Object native
function lukyt_LuaObject_envHandle(class, method, thread, args)
	local t = types.new("long", 1)
	t._lua = _ENV
	return t
end

function lukyt_LuaObject_nilHandle(class, method, thread, args)
	local t = types.new("long", 1)
	t._lua = nil
	return t
end

function lukyt_LuaObject_get0(class, method, thread, args)
	local handle = args[1][2].object.handle
	local key = native.stringToLua(args[2])
	if handle._lua[key] then
		local t = types.new("long", 1)
		t._lua = handle._lua[key]
		return t
	end
	return types.new("long", 0)
end

function lukyt_LuaObject_set0(class, method, thread, args)
	local handle = args[1][2].object.handle
	local key = native.stringToLua(args[2])
	local handle2 = args[3][2].object.handle
	handle._lua[key] = handle2._lua
end

function lukyt_LuaObject_executeAll(class, method, thread, args)
	local object = args[1][2].object
	local handle = object.handle
	local cl, err = classLoader.loadClass("lukyt/LuaObject", true)
	if not cl then
		error("could not import lukyt/LuaObject: " .. err)
	end

	local fArgs = {}
	for _, obj in pairs(args[2][2].array) do
		table.insert(fArgs, obj[2].object.handle._lua)
	end
	local results = table.pack(handle._lua(table.unpack(fArgs)))
	local resultsArray = {}
	for _, res in ipairs(results) do
		local t = types.new("long", 1)
		t._lua = res
		local object = thread:instantiateClass(cl, {t}, true, "(J)V")
		table.insert(resultsArray, object)
	end
	return types.referenceForArray(resultsArray)
end

function lukyt_LuaObject_asDouble(class, method, thread, args)
	return types.new("double", args[1][2].object.handle._lua)
end

function lukyt_LuaObject_asLong(class, method, thread, args)
	return types.new("long", args[1][2].object.handle._lua)
end

function lukyt_LuaObject_asString(class, method, thread, args)
	return native.luaToString(tostring(args[1][2].object.handle._lua), thread)
end

function lukyt_LuaObject_handleFromL(class, method, thread, args)
	local t = types.new("long", 1)
	t._lua = args[1][2]
	return t
end

function lukyt_LuaObject_handleFromD(class, method, thread, args)
	local t = types.new("long", 1)
	t._lua = args[1][2]
	return t
end

function lukyt_LuaObject_handleFromS(class, method, thread, args)
	local t = types.new("long", 1)
	t._lua = native.stringToLua(args[1])
	return t
end

function lukyt_LuaObject_getType(class, method, thread, args)
	return native.luaToString(type(args[1][2].object.handle._lua), thread)
end