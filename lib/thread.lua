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

function lib.nullReference()
	return types.new("reference", {
		type = 4, -- null reference type
	})
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
	local frame = self:pushNewFrame()
	self:pushOperand(types.new("int", self.pc))
	self.pc = 0
	local code = method.code.code
	for k, v in ipairs(parameters) do
		frame.localVariables[k] = v
	end
	while self:execute(class, code) do
		self.pc = self.pc + 1
	end
	self.pc = self:popOperand()[2]
	self:popFrame()
end

function lib:execute(class, code)
	local op = code[self.pc]
	print(op)
	if op == 0x1 then -- aconst_null
		self:pushOperand(lib.nullReference())
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
	if op == 0x10 then -- bipush
		self.pc = self.pc + 1
		local byte = code[self.pc]
		self:pushOperand(types.new("int", byte))
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
	if op == 0xb7 then -- invokespecial
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		printDebug("invokespecial " .. tostring(class.constantPool[nameAndTypeIndex].name.text))
		-- Todo act like "super()"
		self.pc = self.pc + 2
	end
	if op == 0xb6 then -- invokevirtual
		local index = (code[self.pc+1] << 8) | code[self.pc+2]
		local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
		printDebug("invokevirtual " .. tostring(class.constantPool[nameAndTypeIndex].name.text))
		self.pc = self.pc + 2
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
		printDebug("--- return to method ---")
		self.pc = self.pc + 2
	end
	if op == 0x12 then -- ldc
		self.pc = self.pc + 1
		local index = code[self.pc]
		local constant = class.constantPool[index]
		if constant.type == "string" then
			printDebug("ldc \"" .. constant.text.text .. "\"")
		end
	end
	return true
end

function lib:instantiateClass(class)
	local clinit, init = nil, nil
	for _,v in pairs(class.methods) do
		if v.name == "<init>" then
			init = v
		elseif v.name == "<clinit>" then
			clinit = v
		end
	end

	local classReference = types.referenceForClass(class)
	if clinit then
		printDebug("calling <clinit> on class")
		self:executeMethod(class, clinit, {classReference})
	end

	if init then
		printDebug("calling <init> on class")
		self:executeMethod(class, init, {classReference})
	end
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