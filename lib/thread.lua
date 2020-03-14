local lib = {}
local types = require("type")
local classLoader = require("classLoader")

function lib:createFrame()
	local frame = {}
	frame.localVariables = {}
	frame.operandStack = {}
	return frame
end

function lib:operandStackDepth()
	local depth = 0
	for _, v in pairs(self.currentFrame.operandStack) do
		local t = types.type(v)
		if t == "double" or t == "long" then
			depth = depth + 2
		else
			depth = depth + 1
		end
	end
	return depth
end

function lib:pushOperand(operand)
	printDebug("push " .. self:operandStackDepth())
	table.insert(self.currentFrame.operandStack, operand)
end

function lib:popOperand()
	printDebug("pop! " .. self:operandStackDepth())
	return table.remove(self.currentFrame.operandStack)
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
			error("Missing native method: " .. method.code.nativeName)
		end
		_ENV[method.code.nativeName](class, method, parameters)
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

function lib:execute(class, code)
	local op = code[self.pc]
	printDebug("0x" .. string.format("%x", op) .. " @ 0x" .. string.format("%x", self.pc))
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
	elseif op == 0xe then -- dconst_0
		self:pushOperand(types.new("double", 0.0))
	elseif op == 0xf then -- dconst_1
		self:pushOperand(types.new("double", 1.0))
	elseif op == 0x10 then -- bipush
		self.pc = self.pc + 1
		local byte = code[self.pc]
		self:pushOperand(types.new("int", byte))
	elseif op == 0x12 then -- ldc
		self.pc = self.pc + 1
		local index = code[self.pc]
		local constant = class.constantPool[index]
		if constant.type == "string" then
			local text = constant.text.text
			printDebug("ldc \"" .. text .. "\"")
			local objectClass, err = classLoader.loadClass("java/lang/String", true)
			if not objectClass then
				error("could not import java/lang/String !!! " .. err)
			end
			local array = {}
			for i=1, #text do
				table.insert(array, types.new("char", string.byte(text:sub(i,i))))
			end
			local object = self:instantiateClass(objectClass, {types.referenceForArray(array)}, true)
			self:pushOperand(object)
		end
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
		-- iload_0 doesn't have an if here as "idx" is by default set to 0
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
	elseif op == 0x64 then -- isub
		local second = self:popOperand()[2]
		local first = self:popOperand()[2]
		self:pushOperand(types.new("int", first - second))
	elseif op == 0x84 then -- iinc
		local index = code[self.pc+1]
		local const = string.unpack("b", string.char(code[self.pc+2]))
		local var = self.currentFrame.localVariables[index+1]
		var[2] = var[2] + const
		self.pc = self.pc + 2
	elseif op == 0x8e then -- d2i
		local operand = self:popOperand()
		if types.type(operand) ~= "double" then
			error()
		end
		local int = math.floor(operand)
		self:pushOperand(types.new("int", int))
	elseif op == 0x8f then -- d2l
		local operand = self:popOperand()
		if types.type(operand) ~= "double" then
			error()
		end
		local long = math.floor(operand)
		self:pushOperand(types.new("long", long))
	elseif op == 0x9f then -- if_icmpeq
		local branch = string.unpack(">i2", string.char(code[self.pc+1]) .. string.char(code[self.pc+2]))
		local val2 = self:popOperand()
		local val1 = self:popOperand()
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
	elseif op == 0xb0 then -- areturn
		local ref = self:popOperand()
		printDebug("Reference return from method")
		return ref
	elseif op == 0xb1 then -- return
		printDebug("Void return from method")
		return false
	elseif op == 0xb2 then -- getstatic
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]
		local fieldClassPath = class.constantPool[index].class.name.text
		printDebug("getstatic " .. fieldClassPath .. " " .. nat.name.text)
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
		printDebug("putstatic " .. fieldClassPath .. " " .. nat.name.text)
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
		printDebug("getfield " .. nat.name.text .. " on " .. fieldClass.name)
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
		printDebug("putfield " .. nat.name.text)
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
		printDebug("invokevirtual " .. tostring(nat.name.text) .. tostring(nat.descriptor.text))

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
		local cl = ref[2].class[2].class
		local method, methodClass = findMethod(cl, nat.name.text, nat.descriptor.text)
		self:executeMethod(methodClass, method, args)
		self.pc = self.pc + 2
	elseif op == 0xb7 then -- invokespecial
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]
		printDebug("invokespecial " .. tostring(nat.name.text) .. tostring(nat.descriptor.text))

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
		local classPath = class.constantPool[index].class.name.text
		local cl, err = classLoader.loadClass(classPath, true)
		if not cl then
			error("could not import " .. classPath .. ": " .. err)
		end
		local method, methodClass = findMethod(cl, nat.name.text, nat.descriptor.text)
		self:executeMethod(methodClass, method, args)
		self.pc = self.pc + 2
	elseif op == 0xbb then -- new
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local classPath = class.constantPool[index].name.text
		printDebug("new " .. classPath)
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
	elseif op == 0xbe then -- arraylength
		local arr = self:popOperand()
		self:pushOperand(types.new("int", #arr[2].array))
	else
		error("unknown opcode: 0x" .. string.format("%x", op))
	end
	return true
end

function lib:instantiateClass(class, parameters, doInit)
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
		if v.name == "<init>" then
			init = v
		end
	end

	if doInit and init then
		printDebug("calling <init> on object (" .. class.name .. ")")
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