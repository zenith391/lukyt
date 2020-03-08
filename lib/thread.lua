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
	table.insert(self.currentFrame.operandStack, operand)
end

function lib:popOperand()
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
		while self:execute(class, code) do
			self.pc = self.pc + 1
		end
		if self:operandStackDepth() ~= 1 then
			error("operand stack was not cleaned before returning!")
		end
		self.pc = self:popOperand()[2]
		self:popFrame()
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

function lib:execute(class, code)
	local op = code[self.pc]
	printDebug("0x" .. string.format("%x", op) .. " @ 0x" .. string.format("%x", self.pc))
	if op == 0x1 then -- aconst_null
		self:pushOperand(types.nullReference())
	end
	if op==0x2 or op==0x3 or op==0x4 or op==0x5 or op==0x6 or op==0x7 or op==0x8 then -- iconst_<i>
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
	end
	if op == 0x10 then -- bipush
		self.pc = self.pc + 1
		local byte = code[self.pc]
		self:pushOperand(types.new("int", byte))
	end
	if op == 0x12 then -- ldc
		self.pc = self.pc + 1
		local index = code[self.pc]
		local constant = class.constantPool[index]
		if constant.type == "string" then
			local text = constant.text.text
			printDebug("ldc \"" .. text .. "\"")
			local objectClass, err = classLoader.loadClass("java/lang/String", true)
			if not objectClass then
				error("could not import " .. classPath .. ": " .. err)
			end
			local array = {}
			for i=1, #text do
				table.insert(array, types.new("char", string.byte(text:sub(i,i))))
			end
			local object = self:instantiateClass(objectClass, {types.referenceForArray(array)})
			self:pushOperand(object)
		end
	end
	if op == 0x19 or op == 0x2a or op == 0x2b or op == 0x2c or op == 0x2d then -- aload and aload_<n>
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
	end
	if op == 0x59 then -- dup
		local operand = self:popOperand()
		self:pushOperand(operand)
		self:pushOperand(operand)
	end
	if op == 0x8e then -- d2i
		local operand = self:popOperand()
		if types.type(operand) ~= "double" then
			error()
		end
		local int = math.floor(operand)
		self:pushOperand(types.new("int", int))
	end
	if op == 0x8f then -- d2l
		local operand = self:popOperand()
		if types.type(operand) ~= "double" then
			error()
		end
		local long = math.floor(operand)
		self:pushOperand(types.new("long", long))
	end
	if op == 0xb1 then -- return
		printDebug("return from method! exit!")
		return false
	end
	if op == 0xb2 then -- getstatic
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
	end
	if op == 0xb3 then -- putstatic
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
	end
	if op == 0xb5 then -- putfield
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
	end
	if op == 0xb6 then -- invokevirtual
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		local nat = class.constantPool[nameAndTypeIndex]
		printDebug("invokevirtual " .. tostring(nat.name.text))

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
		local method = nil
		for k, v in pairs(cl.methods) do
			if v.name == nat.name.text and v.descriptor == nat.descriptor.text then
				method = v
				break
			end
		end
		self:executeMethod(cl, method, args)
		self.pc = self.pc + 2
	end
	if op == 0xb7 then -- invokespecial
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		printDebug("invokespecial " .. tostring(class.constantPool[nameAndTypeIndex].name.text))
		local objectRef = self:popOperand()
		-- TODO
		self.pc = self.pc + 2
	end
	if op == 0xbb then -- new
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local classPath = class.constantPool[index].name.text
		printDebug("new " .. classPath)
		local objectClass, err = classLoader.loadClass(classPath, true)
		if not objectClass then
			error("could not import " .. classPath .. ": " .. err)
		end
		local object = self:instantiateClass(objectClass)
		self:pushOperand(object)
		self.pc = self.pc + 2
	end
	return true
end

function lib:instantiateClass(class, parameters)
	local classReference = types.referenceForClass(class)
	local object = types.new("reference", {
		type = "object",
		object = {}, -- TODO init fields
		class = classReference
	})
	local init = nil
	for _,v in pairs(class.methods) do
		if v.name == "<init>" then
			init = v
		end
	end

	if init then
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