local lib = {}
local types = require("type")
local classLoader = require("classLoader")

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
		local t = types.type(self.currentFrame.operandStack[i]);
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
	return operand
end

function lib:pushNewFrame()
	local frame = self:createFrame()
	table.insert(self.stack, frame)
	self.currentFrame = frame
	return frame
end

function lib:popFrame()
	local lastFrame = table.remove(self.stack)
	self.currentFrame = self.stack[#self.stack]
	return lastFrame
end

function lib:executeMethod(class, method, parameters)
	if method.code.nativeName then -- native method
		if not _ENV[method.code.nativeName] then
			error("Unbound native method: " .. method.class.name .. "." .. method.name)
		end
		local ret = _ENV[method.code.nativeName](class, method, self, parameters)
		if self.currentFrame then
			self:pushOperand(ret)
		end
	elseif method.code.jit then -- if the method has been transpiled by jit
		method.code.jit(method, class, self, parameters)
	else
		local frame = self:pushNewFrame()
		self:pushOperand(types.new("returnAddress", self.pc))
		self.pc = 1
		local code = method.code.code
		for k, v in ipairs(parameters) do
			frame.localVariables[k] = v
		end
		local ret = true
		while ret == true do
			ret = self:execute(class, code)
			self.pc = self.pc + 1
		end
		if self:operandStackDepth() ~= 1 then
			error("operand stack was not cleaned before returning!")
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

local function findMethod(class, name, desc)
	for k, v in pairs(class.methods) do
		if v.name == name and v.descriptor == desc then
			return v, class
		end
	end
	if class.superClass then
		local method = findMethod(class.superClass, name, desc)
		return method, class.superClass
	else
		error("could not find: " .. name .. " with descriptor " .. desc)
	end
end

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
		local object = self:instantiateClass(objectClass, {types.referenceForArray(array)}, true, "([C)V")
		self:pushOperand(object)
	elseif constant.type == "long" or constant.type == "int" then
		self:pushOperand(types.new(constant.type, constant.value))
	elseif constant.type == "float" or constant.type == "double" then
		self:pushOperand(types.new(constant.type, constant.value))
	end
end

function lib:execute(class, code)
	local op = code[self.pc]
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
		self:pushOperand(self.currentFrame.localVariables[idx+1])
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
		-- iload_0 doesn't have an if here as "idx" is by default set to 0
		self:pushOperand(self.currentFrame.localVariables[idx+1])
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
		self:pushOperand(self.currentFrame.localVariables[idx+1])
	elseif op == 0x32 then -- aaload
		local idx = self:popOperand()[2]
		local array = self:popOperand()
		if idx < 0 then
			error("negativearrayindex: trying to set array with index " .. idx)
		end
		self:pushOperand(array[2].array[idx+1])
	elseif op == 0x34 then -- caload
		local idx = self:popOperand()[2]
		local array = self:popOperand()
		if idx < 0 then
			error("negativearrayindex: trying to set array with index " .. idx)
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
		self.currentFrame.localVariables[idx+1] = self:popOperand()
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
		self.currentFrame.localVariables[idx+1] = self:popOperand()
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
		self.currentFrame.localVariables[idx+1] = self:popOperand()
	elseif op == 0x53 then -- aastore
		local val = self:popOperand()
		local idx = self:popOperand()[2]
		local array = self:popOperand()
		array[2].array[idx+1] = val
	elseif op == 0x55 then -- castore
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
	elseif op == 0x60 then -- iadd
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first + second))
	elseif op == 0x61 then -- ladd
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("long", first + second))
	elseif op == 0x64 then -- isub
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first - second))
	elseif op == 0x65 then -- lsub
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("long", first - second))
	elseif op == 0x68 then -- imul
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first * second))
	elseif op == 0x6b then -- dmul
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("double", first * second))
	elseif op == 0x6c then -- idiv
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", math.floor(first / second)))
	elseif op == 0x6d then -- ldiv
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("long", math.floor(first / second)))
	elseif op == 0x70 then -- irem
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first - math.floor(first/second) * second))
	elseif op == 0x74 then -- ineg
		local value = self:popOperand()[2]
		self:pushOperand(types.new("int", value * -1))
	elseif op == 0x75 then -- ishl
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first << (second & 0x1F)))
	elseif op == 0x7a then -- ishr
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first >> (second & 0x1F)))
	elseif op == 0x7e then -- iand
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first & second))
	elseif op == 0x80 then -- ior
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first | second))
	elseif op == 0x84 then -- iinc
		local index = code[self.pc+1]
		local const = string.unpack("b", string.char(code[self.pc+2]))
		local var = self.currentFrame.localVariables[index+1]
		var[2] = var[2] + const
		self.pc = self.pc + 2
	elseif op == 0x85 then -- i2l
		self:pushOperand(types.new("long", self:popOperand()[2]))
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
	elseif op == 0x92 then -- i2c
		self:pushOperand(types.new("char", self:popOperand()[2]))
	elseif op == 0x99 then -- ifeq
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val1 = self:popOperand()
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
	elseif op == 0xa7 then -- goto
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		self.pc = self.pc + branch - 1
	elseif op == 0xac or op == 0xad or op == 0xb0 then -- ireturn and lreturn and areturn
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
			error("could not import " .. fieldClassPath .. ": " .. err)
		end
		local field = nil
		for k, v in pairs(fieldClass.fields) do
			if v.name == nat.name.text then
				field = v
				break
			end
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
			error("could not import " .. fieldClassPath .. ": " .. err)
		end
		local field = nil
		for k, v in pairs(fieldClass.fields) do
			if v.name == nat.name.text then
				field = v
				break
			end
		end
		field.staticValue = self:popOperand()
		self.pc = self.pc + 2
	elseif op == 0xb4 then -- getfield
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local objectRef = self:popOperand()
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]
		local fieldClass = objectRef[2].class[2].class
		local field = nil
		for k, v in pairs(fieldClass.fields) do
			if v.name == nat.name.text then
				field = v
				break
			end
		end
		self:pushOperand(objectRef[2].object[field.name])
		self.pc = self.pc + 2
	elseif op == 0xb5 then -- putfield
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local value = self:popOperand()
		local objectRef = self:popOperand()
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]
		local fieldClass = objectRef[2].class[2].class
		local field = nil
		for k, v in pairs(fieldClass.fields) do
			if v.name == nat.name.text then
				field = v
				break
			end
		end
		objectRef[2].object[field.name] = value
		self.pc = self.pc + 2
	elseif op == 0xb6 then -- invokevirtual
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]

		-- temporary / TODO use descriptors
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
			error("NullReferenceException!") -- TODO: throw
		end
		local cl = ref[2].class[2].class
		local method, methodClass = findMethod(cl, nat.name.text, nat.descriptor.text)
		self:executeMethod(methodClass, method, args)
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
			error("could not import " .. classPath .. ": " .. err)
		end
		local method, methodClass = findMethod(cl, nat.name.text, nat.descriptor.text)
		self:executeMethod(methodClass, method, args)
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
		local objectClass, err = classLoader.loadClass(class.constantPool[index].class.name.text, true)
		if not objectClass then
			error("could not import " .. class.constantPool[index].class.name.text .. ": " .. tostring(err))
		end
		local method, methodClass = findMethod(objectClass, nat.name.text, nat.descriptor.text)
		self:executeMethod(methodClass, method, args)
		self.pc = self.pc + 2
	elseif op == 0xbb then -- new
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local classPath = class.constantPool[index].name.text
		local objectClass, err = classLoader.loadClass(classPath, true)
		if not objectClass then
			error("could not import " .. classPath .. ": " .. tostring(err))
		end
		local object = self:instantiateClass(objectClass, {}, false)
		self:pushOperand(object)
		self.pc = self.pc + 2
	elseif op == 0xbc then -- newarray
		local atype = code[self.pc + 1]
		local count = self:popOperand()[2]
		local arr = {}
		-- TODO: support other types
		if atype == 5 then -- T_CHAR
			for i=1,count do
				table.insert(arr, types.new("char", 0))
			end
		elseif atype == 10 then -- T_INT
			for i=1,count do
				table.insert(arr, types.new("int", 0))
			end
		elseif atype == 9 then -- T_SHORT
			for i=1,count do
				table.insert(arr, types.new("short", 0))
			end
		elseif atype == 10 then -- T_FLOAT
			for i=1,count do
				table.insert(arr, types.new("float", 0.0))
			end
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
	elseif op == 0xc6 then -- ifnull
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val = self:popOperand()
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
		error("unknown opcode: 0x" .. string.format("%x", op))
	end
	return true
end

function lib:instantiateClass(class, parameters, doInit, initDescriptor)
	local classReference = types.referenceForClass(class)
	local object = types.new("reference", {
		type = "object",
		object = {},
		class = classReference
	})
	for k, v in pairs(class.fields) do
		object[2].object[v.name] = types.nullReference()
	end
	local init = nil
	for _,v in pairs(class.methods) do
		if doInit and not initDescriptor then
			error()
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

	return object
end

function lib.new()
	return setmetatable({
		name = "Thread",
		pc = 1,
		stack = {},
		currentFrame = nil,
		heap = {}
	}, {
		__index = lib
	})
end

return lib