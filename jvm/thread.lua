local lib = {}
local types = require("type")
local classLoader = require("classLoader")

-- Options can be disabled to gain a bit of performance in exchange of less standard compatiblity
local INTERN_STRINGS = 1
local COMPUTE_LINE_NUMBERS = 1
local nextId = 0

function lib:createFrame()
	local frame = {}
	frame.localVariables = {}
	frame.operandStack = {}
	frame.opStackPointer = 1
	return frame
end

function lib:operandStackDepth()
	local depth = 0
	for i=1, self.currentFrame.opStackPointer-1 do
		local t = types.type(self.currentFrame.operandStack[i])
		if t == "double" or t == "long" then
			depth = depth + 2
		else
			depth = depth + 1
		end
	end
	return depth
end

function lib:pushOperand(operand)
	if operand == nil then
		error("attempt to push a nil value")
		return
	end
	local frame = self.currentFrame
	frame.operandStack[frame.opStackPointer] = operand
	frame.opStackPointer = frame.opStackPointer + 1
end

function lib:popOperand()
	local frame = self.currentFrame
	frame.opStackPointer = frame.opStackPointer - 1
	local operand = frame.operandStack[frame.opStackPointer]
	frame.operandStack[frame.opStackPointer] = nil
	return operand
end

function lib:getLocalVariable(idx)
	return self.currentFrame.localVariables[idx]
end

function lib:setLocalVariable(idx, val)
	self.currentFrame.localVariables[idx] = val
end

function lib:pushNewFrame()
	local frame = self:createFrame()
	table.insert(self.stack, frame)
	self.currentFrame = frame
	return frame
end

function lib:popFrame()
	local lastFrame = table.remove(self.stack)
	lastFrame.localVariables = nil
	lastFrame.operandStack = nil
	self.currentFrame = self.stack[#self.stack]
	return lastFrame
end

function lib:instantiateException(path, details)
	local objectClass, err = classLoader.loadClass(path, true)
	if not objectClass then
		error("could not import exception " .. path .. ": " .. err .. ". Exception was " .. path .. ": " .. details)
	end

	if details then
		return self:instantiateClass(objectClass, {require("native").luaToString(details, self)}, true, "(Ljava/lang/String;)V")
	else
		return self:instantiateClass(objectClass, {}, true, "()V")
	end
end

-- the function returns true if class "class" a subclass of "ofClass"
function lib.isSubclassOf(class, ofClass)
	if class == ofClass then
		return true
	elseif class.superClass then
		return lib.isSubclassOf(class.superClass, ofClass)
	else
		return false
	end
end

local inc = 1
function lib:executeMethod(class, method, parameters)
	class = method.class
	local trace = self.stackTrace[#self.stackTrace]
	if trace then
		local m = trace.method
		if m.code.lineNumbers and COMPUTE_LINE_NUMBERS == 1 then
			for _, lineNumber in ipairs(m.code.lineNumbers) do
				if self.pc+1 > lineNumber.startPc then
					trace.lineNumber = lineNumber.lineNumber
				else
					break
				end
			end
		end
	end
	table.insert(self.stackTrace, {
		method = method,
		lineNumber = self.lineNumber
	})
	if method.code.nativeName then -- native method
		if not _ENV[method.code.nativeName] then
			table.remove(self.stackTrace)
			return self:instantiateException("java/lang/UnsatisfiedLinkError", method.class.name .. "." .. method.name)
		end
		local ret = _ENV[method.code.nativeName](class, method, self, parameters)
		if self.currentFrame and ret then
			self:pushOperand(ret)
		end
	elseif method.code.jit then -- if the method has been transpiled by jit
		method.code.jit(method, class, self, parameters)
	else
		local frame = self:pushNewFrame()
		self:pushOperand(types.new("returnAddress", self.pc))
		self.pc = 1
		self.lineNumber = -1
		local code = method.code.code
		local id = 1
		for k, v in ipairs(parameters) do
			self:setLocalVariable(id, v)
			if v[1] == "J" or v[1] == "D" then
				id = id + 2
			else
				id = id + 1
			end
		end
		local ok = false
		local ret = true
		local throwable = nil
		while ret == true do
			if inc >= 5 then
				if coroutine.isyieldable() then
					coroutine.yield()
				end
				inc = 1
			end
			ok, ret, throwable = xpcall(self.execute, function (err)
				print("lua error: " .. err)
				print(debug.traceback("lua stack traceback:", 2))
				print("reduced java stack traceback:")
				local trace = self.stackTrace[#self.stackTrace]
				if trace then
					local m = trace.method
					if m.code.lineNumbers and COMPUTE_LINE_NUMBERS == 1 then
						for _, lineNumber in ipairs(m.code.lineNumbers) do
							if self.pc+1 > lineNumber.startPc then
								trace.lineNumber = lineNumber.lineNumber
							else
								break
							end
						end
					end
				end
				for i=#self.stackTrace, 1, -1 do
					local trace = self.stackTrace[i]
					io.write("\tat " .. trace.method.class.name .. "." .. trace.method.name)
					if trace.lineNumber ~= -1 then
						io.write(":" .. trace.lineNumber)
					else
						io.write(":?")
					end
					io.write("\n")
				end
				os.exit(1)
			end, self, class, code)
			inc = inc + 1
			if ret == "throwable" then
				if not throwable or throwable[2].type == "null" then
					throwable = self:instantiateException("java/lang/NullPointerException")
				end
				local foundHandler = false
				for _, handler in ipairs(method.code.exceptionHandlers) do
					local subclass = false
					if handler.catchClass == "any" then
						subclass = true
					else
						subclass = lib.isSubclassOf(throwable[2].class[2].class, classLoader.loadClass(handler.catchClass, true))
					end
					if self.pc >= handler.startPc and self.pc < handler.endPc and subclass then
						foundHandler = true
						self.pc = handler.handlerPc - 1
						local oldStartPc = self.currentFrame.operandStack[1]
						self.currentFrame.operandStack = {}
						self:pushOperand(types.new("returnAddress", oldStartPc))
						self:pushOperand(throwable)
						ret = true -- continue execution
						throwable = nil
						break
					end
				end
				if not foundHandler then
					table.remove(self.stackTrace)
					self.pc = self:popOperand()[2]
					self:popFrame()
					return throwable
				end
			end
			self.pc = self.pc + 1
		end
		if self:operandStackDepth() ~= 1 then
			error("operand stack was not cleaned before returning! (depth is " .. self:operandStackDepth() .. ")")
		end
		self.pc = self:popOperand()[2]
		self:popFrame()
		if ret ~= false and self.currentFrame then
			self:pushOperand(ret)
		end
		if jitEngine then
			jitEngine.onExecute(method)
		end
	end
	table.remove(self.stackTrace)
end

local function reverse(arr)
	local i, j = 1, #arr
	while i < j do
		arr[i], arr[j] = arr[j], arr[i]
		i = i + 1
		j = j - 1
	end
	return arr
end

local function findMethod(thread, class, name, desc, ogClass)
	for k, v in pairs(class.methods) do
		if v.name == name and v.descriptor == desc then
			return v, class
		end
	end
	if class.superClass then
		local method, throwable = findMethod(thread, class.superClass, name, desc, ogClass or class)
		if not method then
			return nil, throwable
		else
			return method, class.superClass
		end
	else
		--error("could not find: " .. name .. " with descriptor " .. desc)
		local className = (ogClass or class).name:gsub("/", ".")
		return nil, thread:instantiateException("java/lang/NoSuchMethodError", className .. "." .. name .. desc)
	end
end
lib.findMethod = findMethod

local function ldc(self, constant)
	if constant.type == "string" then
		local text = constant.text.text
		local objectClass, err = classLoader.loadClass("java/lang/String", true)
		if not objectClass then
			error("could not import java/lang/String !!! " .. err)
		end
		local array = {}
		for i=1, #text do
			table.insert(array, types.new("char", string.byte(text:sub(i,i))))
		end
		local object = self:instantiateClass(objectClass, {types.referenceForArray(array), types.new("int", INTERN_STRINGS)}, true, "([CZ)V")
		self:pushOperand(object)
	elseif constant.type == "long" or constant.type == "integer" then
		self:pushOperand(types.new(constant.type, constant.value))
	elseif constant.type == "float" or constant.type == "double" then
		self:pushOperand(types.new(constant.type, constant.value))
	elseif constant.type == "class" then
		local cl = classLoader.loadClass(constant.name.text, true)
		if not cl then
			-- TODO: throw exception
			local ex = self:instantiateException("java/lang/NoClassDefException", constant.name.text)
		end
		self:pushOperand(classLoader.classObject(cl, self))
	end
end

local function isnan(n)
	return n ~= n -- NaN cannot equals itself
end

function lib:execute(class, code)
	local op = code[self.pc]
	--print(self.pc .. "/" .. #code)
	--printDebug("0x" .. string.format("%x", op) .. " @ 0x" .. string.format("%x", self.pc)) -- only enable for debug
	if op == 0x0 then -- nop
	elseif op == 0x1 then -- aconst_null
		self:pushOperand(types.nullReference())
	elseif op==0x2 or op==0x3 or op==0x4 or op==0x5 or op==0x6 or op==0x7 or op==0x8 then -- iconst_<i>
		if op == 0x2 then
			self:pushOperand(types.new("int", -1))
		end
		if op == 0x3 then
			self:pushOperand(types.new("int", 0))
		end
		if op == 0x4 then
			self:pushOperand(types.new("int", 1))
		end
		if op == 0x5 then
			self:pushOperand(types.new("int", 2))
		end
		if op == 0x6 then
			self:pushOperand(types.new("int", 3))
		end
		if op == 0x7 then
			self:pushOperand(types.new("int", 4))
		end
		if op == 0x8 then
			self:pushOperand(types.new("int", 5))
		end
	elseif op == 0x9 or op == 0xa then -- lconst_<l>
		if op == 0x9 then
			self:pushOperand(types.new("long", 0))
		elseif op == 0xa then
			self:pushOperand(types.new("long", 1))
		end
	elseif op == 0xe then -- dconst_0
		self:pushOperand(types.new("double", 0.0))
	elseif op == 0xf then -- dconst_1
		self:pushOperand(types.new("double", 1.0))
	elseif op == 0x10 then -- bipush
		self.pc = self.pc + 1
		local byte = code[self.pc]
		self:pushOperand(types.new("int", byte))
	elseif op == 0x11 then -- sipush
		local byte = (code[self.pc+1] << 8) | code[self.pc+2]
		self:pushOperand(types.new("int", byte))
		self.pc = self.pc + 2
	elseif op == 0x12 then -- ldc
		self.pc = self.pc + 1
		local index = code[self.pc]
		local constant = class.constantPool[index]
		ldc(self, constant)
	elseif op == 0x13 or op == 0x14 then -- ldc_w and ldc2_w
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local constant = class.constantPool[index]
		ldc(self, constant)
		self.pc = self.pc + 2
	elseif op == 0x15 or op == 0x1a or op == 0x1b or op == 0x1c or op == 0x1d then -- iload and iload_<n>
		local idx = 0
		if op == 0x15 then
			self.pc = self.pc + 1
			idx = code[self.pc]
		elseif op == 0x1b then -- iload_1
			idx = 1
		elseif op == 0x1c then -- iload_2
			idx = 2
		elseif op == 0x1d then -- iload_3
			idx = 3
		end
		-- iload_0 doesn't have an if here as "idx" is by default set to 0
		self:pushOperand(self:getLocalVariable(idx+1))
	elseif op == 0x16 or op == 0x1e or op == 0x1f or op == 0x20 or op == 0x21 then -- lload and lload_<n>
		local idx = 0
		if op == 0x16 then
			self.pc = self.pc + 1
			idx = code[self.pc]
		elseif op == 0x1f then -- lload_1
			idx = 1
		elseif op == 0x20 then -- lload_2
			idx = 2
		elseif op == 0x21 then -- lload_3
			idx = 3
		end
		-- lload_0 doesn't have an if here as "idx" is by default set to 0
		self:pushOperand(self:getLocalVariable(idx+1))
	elseif op == 0x18 or op == 0x26 or op == 0x27 or op == 0x28 or op == 0x29 then -- dload and dload_<n>
		local idx = 0
		if op == 0x18 then
			self.pc = self.pc + 1
			idx = code[self.pc]
		elseif op == 0x27 then -- dload_1
			idx = 1
		elseif op == 0x28 then -- dload_2
			idx = 2
		elseif op == 0x29 then -- dload_3
			idx = 3
		end
		-- dload_0 doesn't have an if here as "idx" is by default set to 0
		self:pushOperand(self:getLocalVariable(idx+1))
	elseif op == 0x19 or op == 0x2a or op == 0x2b or op == 0x2c or op == 0x2d then -- aload and aload_<n>
		local idx = 0
		if op == 0x19 then
			self.pc = self.pc + 1
			idx = code[self.pc]
		elseif op == 0x2b then -- aload_1
			idx = 1
		elseif op == 0x2c then -- aload_2
			idx = 2
		elseif op == 0x2d then -- aload_3
			idx = 3
		end
		-- aload_0 doesn't have an if here as "idx" is by default set to 0
		self:pushOperand(self:getLocalVariable(idx+1))
	elseif op == 0x2e or op == 0x2f or op == 0x32 or op == 0x33 or op == 0x34 then -- iaload, laload, aaload, baload and caload
		local idx = self:popOperand()[2]
		local array = self:popOperand()
		if array[2].type == "null" then
			return "throwable", self:instantiateException("java/lang/NullPointerException", "array is null")
		end
		if idx < 0 then
			error("negativearrayindex: trying to get array with index " .. idx)
		elseif idx >= #array[2].array then
			error("arrayindexoutofbounds: trying to get array with index " .. idx)
		end
		self:pushOperand(array[2].array[idx+1])
	elseif op == 0x36 or op == 0x3b or op == 0x3c or op == 0x3d or op == 0x3e then -- istore and istore_<n>
		local idx = 0
		if op == 0x36 then
			self.pc = self.pc + 1
			idx = code[self.pc]
		elseif op == 0x3c then -- istore_1
			idx = 1
		elseif op == 0x3d then -- istore_2
			idx = 2
		elseif op == 0x3e then -- istore_3
			idx = 3
		end
		-- istore_0 doesn't have an if here as "idx" is by default set to 0
		self:setLocalVariable(idx+1, self:popOperand())
	elseif op == 0x37 or op == 0x3f or op == 0x40 or op == 0x41 or op == 0x42 then -- lstore and lstore_<n>
		local idx = 0
		if op == 0x37 then
			self.pc = self.pc + 1
			idx = code[self.pc]
		elseif op == 0x40 then -- lstore_1
			idx = 1
		elseif op == 0x41 then -- lstore_1
			idx = 2
		elseif op == 0x42 then -- lstore_3
			idx = 3
		end
		-- lstore_0 doesn't have an if here as "idx" is by default set to 0
		self:setLocalVariable(idx+1, self:popOperand())
	elseif op == 0x3a or op == 0x4b or op == 0x4c or op == 0x4d or op == 0x4e then -- astore and astore_<n>
		local idx = 0
		if op == 0x3a then
			self.pc = self.pc + 1
			idx = code[self.pc]
		elseif op == 0x4c then -- astore_1
			idx = 1
		elseif op == 0x4d then -- astore_2
			idx = 2
		elseif op == 0x4e then -- astore_3
			idx = 3
		end
		-- astore_0 doesn't have an if here as "idx" is by default set to 0
		self:setLocalVariable(idx+1, self:popOperand())
	elseif op == 0x47 or op == 0x48 or op == 0x49 or op == 0x4a or op == 0x39 then -- dstore and dstore_<n>
		local idx = 0
		if op == 0x39 then
			self.pc = self.pc + 1
			idx = code[self.pc]
		elseif op == 0x48 then -- astore_1
			idx = 1
		elseif op == 0x49 then -- astore_2
			idx = 2
		elseif op == 0x4a then -- astore_3
			idx = 3
		end
		-- dstore_0 doesn't have an if here as "idx" is by default set to 0
		self:setLocalVariable(idx+1, self:popOperand())
	elseif op == 0x4f or op == 0x50 or op == 0x53 or op == 0x54 or op == 0x55 then -- iastore, lastore, aastore, bastore and castore
		local val = self:popOperand()
		local idx = self:popOperand()[2]
		local array = self:popOperand()
		array[2].array[idx+1] = val
	elseif op == 0x57 then -- pop
		self:popOperand()
	elseif op == 0x59 then -- dup
		local operand = self:popOperand()
		self:pushOperand(operand)
		self:pushOperand(operand)
	elseif op == 0x5a then -- dup_x1
		local v1 = self:popOperand()
		local v2 = self:popOperand()
		self:pushOperand(v1)
		self:pushOperand(v2)
		self:pushOperand(v1)
	elseif op == 0x60 then -- iadd
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first + second))
	elseif op == 0x61 then -- ladd
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("long", first + second))
	elseif op == 0x63 then -- dadd
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("double", first + second))
	elseif op == 0x64 then -- isub
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first - second))
	elseif op == 0x65 then -- lsub
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("long", first - second))
	elseif op == 0x67 then -- dsub
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("double", first - second))
	elseif op == 0x68 then -- imul
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first * second))
	elseif op == 0x69 then -- lmul
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("long", first * second))
	elseif op == 0x6a then -- fmul
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("float", first * second))
	elseif op == 0x6b then -- dmul
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("double", first * second))
	elseif op == 0x6c then -- idiv
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		if second == 0 then
			return "throwable", self:instantiateException("java/lang/ArithmeticException", "divide by zero")
		end
		self:pushOperand(types.new("int", math.floor(first / second)))
	elseif op == 0x6d then -- ldiv
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		if second == 0 then
			return "throwable", self:instantiateException("java/lang/ArithmeticException", "divide by zero")
		end
		self:pushOperand(types.new("long", math.floor(first / second)))
	elseif op == 0x6f then -- ddiv
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		if second == 0 then
			return "throwable", self:instantiateException("java/lang/ArithmeticException", "divide by zero")
		end
		self:pushOperand(types.new("double", first / second))
	elseif op == 0x70 then -- irem
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		if second == 0 then
			return "throwable", self:instantiateException("java/lang/ArithmeticException", "divide by zero")
		end
		self:pushOperand(types.new("int", first - math.floor(first/second) * second))
	elseif op == 0x71 then -- lrem
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		if second == 0 then
			return "throwable", self:instantiateException("java/lang/ArithmeticException", "divide by zero")
		end
		self:pushOperand(types.new("long", first - math.floor(first/second) * second))
	elseif op == 0x72 then -- frem
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		local q = math.floor(first / second)
		self:pushOperand(types.new("float", first - second * q))
	elseif op == 0x73 then -- drem
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		local div = first / second
		local q = ((div < 0) and math.ceil(div)) or math.floor(div)
		self:pushOperand(types.new("double", first - second * q))
	elseif op == 0x74 then -- ineg
		local value = self:popOperand()[2]
		self:pushOperand(types.new("int", value * -1))
	elseif op == 0x75 then -- lneg
		local value = self:popOperand()[2]
		self:pushOperand(types.new("long", value * -1))
	elseif op == 0x75 then -- ishl
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first << (second & 0x1F)))
	elseif op == 0x76 then -- fneg
		local value = self:popOperand()[2]
		self:pushOperand(types.new("float", value * -1))
	elseif op == 0x77 then -- dneg
		local value = self:popOperand()[2]
		self:pushOperand(types.new("double", value * -1))
	elseif op == 0x7a then -- ishr
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first >> (second & 0x1F)))
	elseif op == 0x7e then -- iand
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first & second))
	elseif op == 0x7f then -- land
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("long", first & second))
	elseif op == 0x80 then -- ior
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first | second))
	elseif op == 0x81 then -- lor
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("long", first | second))
	elseif op == 0x84 then -- iinc
		local index = code[self.pc+1]
		local const = string.unpack("b", string.char(code[self.pc+2]))
		local var = self:getLocalVariable(index+1)
		var[2] = var[2] + const
		self.pc = self.pc + 2
	elseif op == 0x85 then -- i2l
		self:pushOperand(types.new("long", self:popOperand()[2]))
	elseif op == 0x87 then -- i2d
		self:pushOperand(types.new("double", self:popOperand()[2]))
	elseif op == 0x88 then -- l2i
		self:pushOperand(types.new("int", self:popOperand()[2]))
	elseif op == 0x8e then -- d2i
		local operand = self:popOperand()
		if types.type(operand) ~= "double" then
			error(types.type(operand) .. " is not a double")
		end
		local int = math.floor(operand[2])
		self:pushOperand(types.new("int", int))
	elseif op == 0x8f then -- d2l
		local operand = self:popOperand()
		if types.type(operand) ~= "double" then
			error(types.type(operand) .. " is not a double")
		end
		local long = math.floor(operand[2])
		self:pushOperand(types.new("long", long))
	elseif op == 0x91 then -- i2b
		self:pushOperand(types.new("byte", self:popOperand()[2]))
	elseif op == 0x92 then -- i2c
		self:pushOperand(types.new("char", self:popOperand()[2]))
	elseif op == 0x94 then -- lcmp
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		if first > second then
			self:pushOperand(types.new("int", 1))
		elseif first < second then
			self:pushOperand(types.new("int", -1))
		else
			self:pushOperand(types.new("int", 0))
		end
	elseif op == 0x96 then -- i2s
		self:pushOperand(types.new("short", self:popOperand()[2]))
	elseif op == 0x97 then -- dcmpg
		local val2 = self:popOperand()[2]
		local val1 = self:popOperand()[2]
		if val1 > val2 then
			self:pushOperand(types.new("int", 1))
		elseif val1 < val2 then
			self:pushOperand(types.new("int", -1))
		elseif isnan(val1) or isnan(val2) then
			self:pushOperand(types.new("int", 1))
		elseif val1 == val2 then
			self:pushOperand(types.new("int", 0))
		end
	elseif op == 0x98 then -- dcmpl
		local val2 = self:popOperand()[2]
		local val1 = self:popOperand()[2]
		if val1 > val2 then
			self:pushOperand(types.new("int", 1))
		elseif val1 < val2 then
			self:pushOperand(types.new("int", -1))
		elseif isnan(val1) or isnan(val2) then
			self:pushOperand(types.new("int", -1))
		elseif val1 == val2 then
			self:pushOperand(types.new("int", 0))
		end
	elseif op == 0x99 then -- ifeq
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val1 = self:popOperand()[2]
		if val1 == 0 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0x9a then -- ifne
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val1 = self:popOperand()[2]
		if val1 ~= 0 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0x9b then -- iflt
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val1 = self:popOperand()[2]
		if val1 < 0 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0x9c then -- ifge
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val1 = self:popOperand()[2]
		if val1 >= 0 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0x9d then -- ifgt
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val1 = self:popOperand()[2]
		if val1 > 0 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0x9e then -- ifle
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val1 = self:popOperand()[2]
		if val1 <= 0 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0x9f then -- if_icmpeq
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val2 = self:popOperand()[2]
		local val1 = self:popOperand()[2]
		if val1 == val2 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0xa0 then -- if_icmpne
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val2 = self:popOperand()[2]
		local val1 = self:popOperand()[2]
		if val1 ~= val2 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0xa1 then -- if_icmplt
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val2 = self:popOperand()[2]
		local val1 = self:popOperand()[2]
		if val1 < val2 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0xa2 then -- if_icmpge
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val2 = self:popOperand()[2]
		local val1 = self:popOperand()[2]
		if val1 >= val2 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0xa3 then -- if_icmpgt
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val2 = self:popOperand()[2]
		local val1 = self:popOperand()[2]
		if val1 > val2 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0xa4 then -- if_icmple
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val2 = self:popOperand()[2]
		local val1 = self:popOperand()[2]
		if val1 <= val2 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0xa5 then -- if_acmpeq
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val2 = self:popOperand()[2]
		local val1 = self:popOperand()[2]
		if val1 == val2 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0xa6 then -- if_acmpne
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val2 = self:popOperand()[2]
		local val1 = self:popOperand()[2]
		if val1 ~= val2 then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0xa7 then -- goto
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		self.pc = self.pc + branch - 1
	elseif op == 0xaa then -- tableswitch
		local orgAddress = self.pc
		local padding = 4-((self.pc-1)%4)
		self.pc = self.pc + padding
		local codeStr = string.char(table.unpack(code))
		local default = string.unpack(">i4", codeStr, self.pc)
		local low = string.unpack(">i4", codeStr, self.pc+4)
		local high = string.unpack(">i4", codeStr, self.pc+8)
		self.pc = self.pc + 12
		local offsets = {}
		for i=1, high-low+1 do
			local off = string.unpack(">i4", codeStr, self.pc)
			table.insert(offsets, off)
			self.pc = self.pc + 4
		end

		local index = self:popOperand()[2]
		if index < low or index > high then
			self.pc = orgAddress + default - 1
		else
			local off = offsets[index-low+1]
			self.pc = orgAddress + off - 1
		end
	elseif op == 0xab then -- lookupswitch
		local orgAddress = self.pc
		local padding = 4-((self.pc-1)%4)
		self.pc = self.pc + padding
		local codeStr = string.char(table.unpack(code))
		local default = string.unpack(">i4", codeStr, self.pc)
		local npairs = string.unpack(">i4", codeStr, self.pc+4)
		self.pc = self.pc + 8
		local intpairs = {}
		for i=1, npairs do
			local key = string.unpack(">i4", codeStr, self.pc)
			local off = string.unpack(">i4", codeStr, self.pc+4)
			intpairs[key] = off
			self.pc = self.pc + 8
		end

		local key = self:popOperand()[2]
		if intpairs[key] then
			self.pc = orgAddress + intpairs[key] - 1
		else
			self.pc = orgAddress + default - 1
		end
	elseif op == 0xac or op == 0xad or op == 0xaf or op == 0xb0 then -- ireturn, lreturn, dreturn and areturn
		local ref = self:popOperand()
		return ref
	elseif op == 0xb1 then -- return
		return false
	elseif op == 0xb2 then -- getstatic
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]
		local fieldClassPath = class.constantPool[index].class.name.text
		local fieldClass, err = classLoader.loadClass(fieldClassPath, true)
		if not fieldClass then
			return "throwable", self:instantiateException("java/lang/NoClassDefException", fieldClassPath)
		end
		local field = nil
		for k, v in pairs(fieldClass.fields) do
			if v.name == nat.name.text then
				field = v
				break
			end
		end
		if not field then
			local className = fieldClass.name:gsub("/", ".")
			return "throwable", self:instantiateException("java/lang/NoSuchFieldError", className .. "." .. nat.name.text)
		end
		self:pushOperand(field.staticValue)
		self.pc = self.pc + 2
	elseif op == 0xb3 then -- putstatic
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]
		local fieldClassPath = class.constantPool[index].class.name.text
		local fieldClass, err = classLoader.loadClass(fieldClassPath, true)
		if not fieldClass then
			return "throwable", self:instantiateException("java/lang/NoClassDefException", fieldClassPath)
		end
		local field = nil
		for k, v in pairs(fieldClass.fields) do
			if v.name == nat.name.text then
				field = v
				break
			end
		end
		if not field then
			local className = fieldClass.name:gsub("/", ".")
			return "throwable", self:instantiateException("java/lang/NoSuchFieldError", className .. "." .. nat.name.text)
		end
		field.staticValue = self:popOperand()
		self.pc = self.pc + 2
	elseif op == 0xb4 then -- getfield
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local objectRef = self:popOperand()
		local fieldConstant = class.constantPool[index]
		local nameAndTypeIndex = fieldConstant.nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]
		local classPath = fieldConstant.class.name.text
		local fieldClass, err = classLoader.loadClass(classPath, true)
		if not fieldClass then
			return "throwable", self:instantiateException("java/lang/NoClassDefException", classPath)
		end
		if objectRef[2].type == "null" then
			return "throwable", self:instantiateException("java/lang/NullPointerException", "attempted to get field from null value")
		end
		self:pushOperand(objectRef[2].object[nat.name.text])
		self.pc = self.pc + 2
	elseif op == 0xb5 then -- putfield
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local value = self:popOperand()
		local objectRef = self:popOperand()
		local fieldConstant = class.constantPool[index]
		local nameAndTypeIndex = fieldConstant.nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]
		local classPath = fieldConstant.class.name.text
		local fieldClass, err = classLoader.loadClass(classPath, true)
		if not fieldClass then
			return "throwable", self:instantiateException("java/lang/NoClassDefException", classPath)
		end
		if objectRef[2].type == "null" then
			return "throwable", self:instantiateException("java/lang/NullPointerException", "attempted to set field to null value")
		end
		objectRef[2].object[nat.name.text] = value
		self.pc = self.pc + 2
	elseif op == 0xb6 then -- invokevirtual
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]

		local desc = types.readMethodDescriptor(nat.descriptor.text)
		local argsCount = #desc.params
		local args = {}
		for i=1, argsCount do
			table.insert(args, self:popOperand())
		end
		local ref = self:popOperand()
		table.insert(args, ref)
		reverse(args)
		if ref[2].type == "null" then
			return "throwable", self:instantiateException("java/lang/NullPointerException", "attempted to call method on null value")
		end

		local customClass
		--print(ref[2].type .. " t: " .. nat.name.text .. " " .. nat.descriptor.text)
		if ref[2].type == "array" then
			--if nat.name.text == "clone" then
			--end
			local err
			local classPath = "java/lang/ArrayMethods"
			customClass, err = classLoader.loadClass(classPath, true)
			if not customClass then
				return "throwable", self:instantiateException("java/lang/NoClassDefException", classPath)
			end
			nat.descriptor.text = "([Ljava/lang/Object;)[Ljava/lang/Object;"
		end
		local cl = customClass or ref[2].class[2].class
		local method, methodClass = findMethod(self, cl, nat.name.text, nat.descriptor.text)
		if not method then
			return "throwable", methodClass
		end
		--print(method.class.name)
		local throwable = self:executeMethod(methodClass, method, args)
		if throwable then
			return "throwable", throwable -- re-throw catched exception
		end
		self.pc = self.pc + 2
	elseif op == 0xb7 then -- invokespecial
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]

		local desc = types.readMethodDescriptor(nat.descriptor.text)
		local argsCount = #desc.params
		local args = {}
		for i=1, argsCount do
			table.insert(args, self:popOperand())
		end
		local ref = self:popOperand()
		table.insert(args, ref)
		reverse(args)
		local classPath = class.constantPool[index].class.name.text
		local cl, err = classLoader.loadClass(classPath, true)
		if not cl then
			return "throwable", self:instantiateException("java/lang/NoClassDefException", classPath)
		end
		local method, methodClass = findMethod(self, cl, nat.name.text, nat.descriptor.text)
		if not method then
			return "throwable", methodClass
		end
		local throwable = self:executeMethod(methodClass, method, args)
		if throwable then
			return "throwable", throwable
		end
		self.pc = self.pc + 2
	elseif op == 0xb8 then -- invokestatic
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]

		local desc = types.readMethodDescriptor(nat.descriptor.text)
		local argsCount = #desc.params
		local args = {}
		for i=1, argsCount do
			table.insert(args, self:popOperand())
		end
		reverse(args)
		local classPath = class.constantPool[index].class.name.text
		local objectClass, err = classLoader.loadClass(classPath, true)
		if not objectClass then
			return "throwable", self:instantiateException("java/lang/NoClassDefException", classPath)
		end
		local method, methodClass = findMethod(self, objectClass, nat.name.text, nat.descriptor.text)
		if not method then
			return "throwable", methodClass
		end
		local throwable = self:executeMethod(methodClass, method, args)
		if throwable then
			return "throwable", throwable
		end
		self.pc = self.pc + 2
	elseif op == 0xb9 then -- invokeinterface
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local count = code[self.pc+3]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]

		local desc = types.readMethodDescriptor(nat.descriptor.text)
		local argsCount = #desc.params
		local args = {}
		for i=1, argsCount do
			table.insert(args, self:popOperand())
		end
		local ref = self:popOperand()
		table.insert(args, ref)
		reverse(args)
		if ref[2].type == "null" then
			return "throwable", self:instantiateException("java/lang/NullPointerException", classPath)
		end
		local cl = ref[2].class[2].class
		local method, methodClass = findMethod(self, cl, nat.name.text, nat.descriptor.text)
		if not method then
			return "throwable", methodClass
		end
		local throwable = self:executeMethod(methodClass, method, args)
		if throwable then
			return "throwable", throwable -- re-throw catched exception
		end
		self.pc = self.pc + 4
	elseif op == 0xbb then -- new
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local classPath = class.constantPool[index].name.text
		local objectClass, err = classLoader.loadClass(classPath, true)
		if not objectClass then
			return "throwable", self:instantiateException("java/lang/NoClassDefException", classPath)
		end
		local object = self:instantiateClass(objectClass, {}, false)
		self:pushOperand(object)
		self.pc = self.pc + 2
	elseif op == 0xbc then -- newarray
		local atype = code[self.pc + 1]
		local count = self:popOperand()[2]
		local arr = {}
		-- TODO: support other types
		local strType = ""
		if atype == 5 then -- T_CHAR
			strType = "char"
		elseif atype == 6 then -- T_FLOAT
			strType = "float"
		elseif atype == 7 then -- T_DOUBLE
			strType = "double"
		elseif atype == 8 then -- T_BYTE
			strType = "byte"
		elseif atype == 9 then -- T_SHORT
			strType = "short"
		elseif atype == 10 then -- T_INT
			strType = "int"
		elseif atype == 11 then -- T_LONG
			strType = "long"
		end
		
		for i=1, count do
			table.insert(arr, types.new(strType, 0))
		end
		self:pushOperand(types.referenceForArray(arr))
		self.pc = self.pc + 1
	elseif op == 0xbd then -- anewarray
		local index = (code[self.pc+1] << 8) | code[self.pc+2] -- no type checking yet
		local count = self:popOperand()[2]
		local arr = {}
		for i=1,count do
			table.insert(arr, types.nullReference())
		end
		self:pushOperand(types.referenceForArray(arr))
		self.pc = self.pc + 2
	elseif op == 0xbe then -- arraylength
		local arr = self:popOperand()
		self:pushOperand(types.new("int", #arr[2].array))
	elseif op == 0xbf then -- athrow
		local throwable = self:popOperand()
		-- TODO: check if it is subclass of Throwable
		return "throwable", throwable
	elseif op == 0xc0 then -- checkcast
		local index = (code[self.pc+1] << 8) | code[self.pc+2] -- no type checking yet
		local ref = self:popOperand()
		self:pushOperand(ref)
		local doThrow = true
		if ref[2].type == "null" then
			-- do nothing
			doThrow = false
		elseif ref[2].type == "array" then
			-- TODO check
			doThrow = false
		else
			local className = class.constantPool[index].name.text
			local cl = classLoader.loadClass(className, true)
			if not cl then
				print("throw")
				return "throwable", self:instantiateException("java/lang/NoClassDefException", className)
			end
			local refClass = ref[2].class[2].class
			for k, v in pairs(refClass.interfaces) do
				if v.name == className then
					doThrow = false
					break
				end
			end
			if lib.isSubclassOf(refClass, cl) then
				doThrow = false
			end
		end
		self.pc = self.pc + 2
		if doThrow then
			error("checkcast failed: todo throw exception")
		end
	elseif op == 0xc1 then -- instanceof
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local ref = self:popOperand()
		local className = class.constantPool[index].name.text
		local cl = classLoader.loadClass(className, true)
		if not cl then
			-- TOOD: throw NoClassDefException
			print("NO SUCH CLASS INSTANCEOF")
		end
		if ref[2].type == "null" then
			self:pushOperand(types.new("int", 0))
		else
			local refClass = ref[2].class[2].class
			local implements = false
			for k, v in pairs(refClass.interfaces) do
				if v.name == className then
					implements = false
					break
				end
			end
			if lib.isSubclassOf(refClass, cl) then
				implements = true
			end
			if implements then
				self:pushOperand(types.new("int", 1))
			else
				self:pushOperand(types.new("int", 0))
			end
		end
		self.pc = self.pc + 2
	elseif op == 0xc2 then -- monitorenter
		local ref = self:popOperand()[2]
		if ref.type == "null" then
			return "throwable", self:instantiateException("java/lang/NullPointerException")
		end
		if ref.monitor == 0 then
			ref.monitor = ref.monitor + 1
			ref.monitorOwner = self
		elseif ref.monitorOwner == self then
			ref.monitor = ref.monitor + 1
		else
			while ref.monitor ~= 0 do
				coroutine.yield()
			end
			ref.monitor = ref.monitor + 1
			ref.monitorOwner = self
		end
	elseif op == 0xc3 then -- monitorexit
		local ref = self:popOperand()[2]
		if ref.type == "null" then
			return "throwable", self:instantiateException("java/lang/NullPointerException")
		end
		if ref.monitorOwner == self then
			ref.monitor = ref.monitor - 1
			if ref.monitor == 0 then
				ref.monitorOwner = nil
			end
		else
			return "throwable", self:instantiateException("java/lang/IllegalMonitorStateException")
		end
	elseif op == 0xc5 then -- multianewarray
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local constant = class.constantPool[index]
		--print(constant.name.text)
		local dimensions = code[self.pc+3]

		local sizes = {}
		for i=1, dimensions do
			table.insert(sizes, self:popOperand()[2])
		end
		reverse(sizes)

		local function subarray(i, max, counts)
			local array = {}
			local count = counts[i]
			for j=1, count do
				if i == max then
					array[j] = types.nullReference()
				else
					array[j] = subarray(i+1, max, counts)
				end
			end
			return types.referenceForArray(array)
		end
		self:pushOperand(subarray(1, dimensions, sizes))
		self.pc = self.pc + 3
	elseif op == 0xc6 then -- ifnull
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val = self:popOperand()[2]
		if val.type == "null" then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	elseif op == 0xc7 then -- ifnonnull
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val = self:popOperand()[2]
		if val.type ~= "null" then
			self.pc = self.pc + branch - 1
		else
			self.pc = self.pc + 2
		end
	else
		error("unknown opcode: 0x" .. string.format("%x", op) .. " (pc = " ..  self.pc .. ")")
	end
	return true
end

local function defaultFields(object, class)
	for k, v in pairs(class.fields) do
		if v.descriptor == "I" then
			object[2].object[v.name] = types.new("int", 0)
		elseif v.descriptor == "Z" or v.descriptor == "B" then
			object[2].object[v.name] = types.new("byte", 0)
		elseif v.descriptor == "J" then
			object[2].object[v.name] = types.new("long", 0)
		else
			object[2].object[v.name] = types.nullReference()
		end
	end
	if class.superClass then
		defaultFields(object, class.superClass)
	end
	return object
end

function lib:instantiateClass(class, parameters, doInit, initDescriptor)
	local classReference = types.referenceForClass(class)
	local object = types.new("reference", {
		type = "object",
		object = {},
		class = classReference,
		hashCode = math.floor(math.random() * 0x7FFFFFFF),
		monitor = 0,
		monitorOwner = nil
	})
	defaultFields(object, class)
	local init = nil
	for _,v in pairs(class.methods) do
		if doInit and not initDescriptor then
			error("doInit is set to true but initDescriptor is missing")
		end
		if v.name == "<init>" and v.descriptor == initDescriptor then
			init = v
		end
	end

	if doInit and init then
		local params = {object}
		if parameters then
			for k, v in ipairs(parameters) do
				table.insert(params, v)
			end
		end
		self:executeMethod(class, init, params)
	end

	setmetatable(object, {
		__gc = function()
			mainThread:executeMethod(class, findMethod(self, class, "finalize", "()V"), {object})
		end
	})

	return object
end

function lib.new()
	nextId = nextId + 1
	return setmetatable({
		name = "Thread-" .. (nextId-1),
		pc = 1,
		lineNumber = 0,
		stack = {},
		currentFrame = nil,
		heap = {},
		stackTrace = {},
		coroutine = nil,
		id = nextId
	}, {
		__index = lib
	})
end

return lib