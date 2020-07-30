-- Default native library for standalone Lua

local native = require("native") -- native integration
local types = require("type")
local classLoader = require("classLoader")
local internedStrings = {}

-- Deprecated
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

function java_lang_StringBuilder_append(class, method, thread, args)
	local this = args[1]
	local array = args[2]
	local chars = this[2].object.chars
	local arrayArray = array[2].array
	local charsArray = chars[2].array
	for i=1, #arrayArray do
		charsArray[#charsArray+1] = arrayArray[i]
	end
	return this
end

-- I/O functions
function java_io_FileDescriptor_openStandard(class, method, thread, args)
	local this = args[1]
	local fd = args[2][2]

	local handle = nil
	if fd == 0 then
		handle = io.stdin
	elseif fd == 1 then
		handle = io.stdout
	elseif fd == 2 then
		handle = io.stderr
	else
		return types.new("byte", 0) -- false
	end
	local handleObj = types.new("long", 1)
	handleObj.io = handle
	this[2].object.handle = handleObj
	return types.new("byte", 1) -- true
end

function java_io_FileDescriptor_open(class, method, thread, args)
	local this = args[1]
	local path = native.stringToLua(args[2])
	local mode = args[3][2]
	local modeStr

	local handle = nil
	if mode == 0 then
		modeStr = "r"
	elseif mode == 1 then
		modeStr = "w"
	elseif mode == 2 then
		modeStr = "w+"
	else
		return types.new("byte", 0) -- false
	end
	local handle, err = io.open(path, modeStr)
	if err then
		print("file error: " .. err)
		return types.new("byte", 0) -- false
	end
	local handleObj = types.new("long", 1)
	handleObj.io = handle
	this[2].object.handle = handleObj
	return types.new("byte", 1) -- true
end

function java_io_FileDescriptor_write(class, method, thread, args)
	local this = args[1]
	local handleObj = this[2].object.handle
	local handle = handleObj.io
	local array = args[2][2]
	local off = args[3][2]
	local len = args[4][2]

	local str = ""
	for i=1, len do
		local i = off + i
		local byte = array.array[i]
		if not byte then
			error("out of bounds: " .. i) -- todo throw exception
		end
		str = str .. string.char(byte[2])
	end
	handle:write(str)
end

function java_io_FileDescriptor_close(class, method, thread, args)
	local this = args[1]
	local handleObj = this[2].object.handle
	local handle = handleObj.io
	handle:close()
	this[2].object.handle = types.new("long", 0)
end

function java_io_FileDescriptor_read(class, method, thread, args)
	local this = args[1]
	local handleObj = this[2].object.handle
	local handle = handleObj.io
	local array = args[2][2]
	local off = args[3][2]
	local len = args[4][2]

	local str = handle:read(len)
	if not str then
		return types.new("int", -1)
	end
	for i=1, #str do
		local i = off + i
		if not array.array[i] then
			error("out of bounds") -- todo throw exception
		end
		array.array[i] = types.new("byte", string.byte(str:sub(i, i)))
	end
	return types.new("int", #str)
end

function java_io_FileDescriptor_size(class, method, thread, args)
	local this = args[1]
	local handleObj = this[2].object.handle
	local handle = handleObj.io

	local curPos = handle:seek()
	local size, err = handle:seek("end")
	if not size then -- prob tried to get size of a standard stream
		return types.new("int", 1)
	end
	handle:seek("set", curPos)
	return types.new("int", size)
end

function java_lang_System_arraycopy(class, method, thread, args)
	local src = args[1][2].array
	local srcPos = args[2][2]
	local dest = args[3][2].array
	local destPos = args[4][2]
	local length = args[5][2]
	if args[1][2].type ~= "array" then
		error("src is not an array!")
	elseif args[3][2].type ~= "array" then
		error("dest is not an array!")
	end

	for i=1,length do
		dest[i+destPos] = src[i+srcPos]
	end
end

function java_lang_Math_cos_native(class, method, thread, args)
	return types.new("double", math.cos(args[1][2]))
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

function java_lang_System_getenv(class, method, thread, args)
	local name = native.stringToLua(args[1])
	if os.getenv(name) == nil then
		return types.nullReference()
	else
		return native.luaToString(os.getenv(name), thread)
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
		table.insert(stackTrace, thread:instantiateClass(objectClass, {declaringClass, methodName, fileName, types.new("int", v.lineNumber), isNative}, true, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IZ)V"))
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
	})
	return this
end

function java_lang_String_valueOf(class, method, thread, args)
	local val = args[1]
	if val[1] == "D" then
		local num = val[2]
		return native.luaToString(tostring(num), thread)
	end
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

function lukyt_LuaObject_trueHandle(class, method, thread, args)
	local t = types.new("long", 3)
	t._lua = true
	return t
end

function lukyt_LuaObject_falseHandle(class, method, thread, args)
	local t = types.new("long", 2)
	t._lua = false
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
		local v = handle._lua[key]
		local handleId = 1
		if v == false then
			handleId = 2
		elseif v == true then
			handleId = 3
		end
		local t = types.new("long", handleId)
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


function java_lang_Thread_initNewHandle(class, method, thread, args)
	local th = require("thread").new()
	local t = types.new("long", th.id)
	t._thread = th
	th._cl = class
	th._method = require("thread").findMethod(thread, args[1][2].class[2].class, "run", "()V")
	th._args = {args[1]}
	th.coroutine = coroutine.create(require("thread").executeMethod)
	th.coroutineStarted = true
	return t
end

function java_lang_Thread_getMainThreadHandle(class, method, thread, args)
	error("not yet main thread handle")
end

function java_lang_Thread_start(class, method, thread, args)
	local th = args[1][2].object.handle._thread
	table.insert(runningThreads, th)
end

function java_lang_Thread_sleep(class, method, thread, args)
	local millis = args[1][2]
	local time = os.time() + (millis / 1000)
	while time < os.time() do
		coroutine.yield()
	end
end
