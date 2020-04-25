-- "Freqs" Lua JIT engine 
local freqs = {}
local types = require("type")

function freqs.compile(method)
	local class = method.class
	local out = ""
	out = out .. [[
	local types = require("type")
	local classLoader = require("classLoader")
	local class, method, thread, params = ...
	local frame = thread:pushNewFrame()
	local findMethod = require("thread").findMethod

	local function reverse(arr)
		local i, j = 1, #arr
		while i < j do
			arr[i], arr[j] = arr[j], arr[i]
			i = i + 1
			j = j - 1
		end
		return arr
	end

	thread:pushOperand(types.new("returnAddress", thread.pc))
	thread.pc = 1
	for k, v in ipairs(params) do
		frame.localVariables[k] = v
	end
	local ret = nil
	]]
	local code = method.code.code
	local jumps = {}
	local pc = 1

	pc = 1
	while pc < #code do
		local op = code[pc]
		for k, v in pairs(jumps) do
			if v == pc then
				out = out .. "\n::_" .. tostring(pc) .. "_::"
			end
		end
		if op == 0x0 then -- nop
		elseif op == 0x1 then -- aconst_null
			out = out .. "\nthread:pushOperand(types.nullReference())"
		elseif op==0x2 or op==0x3 or op==0x4 or op==0x5 or op==0x6 or op==0x7 or op==0x8 then -- iconst_<i>
			local val = 0
			if op == 0x2 then
				val = -1
			end
			if op == 0x4 then
				val = 1
			end
			if op == 0x5 then
				val = 2
			end
			if op == 0x6 then
				val = 3
			end
			if op == 0x7 then
				val = 4
			end
			if op == 0x8 then
				val = 5
			end
			out = out .. "\nthread:pushOperand(types.new('int',"..val..")"
		elseif op == 0x9 or op == 0xa then -- lconst_<l>
			error("todo")
			if op == 0x9 then
				thread:pushOperand(types.new("long", 0))
			elseif op == 0xa then
				thread:pushOperand(types.new("long", 1))
			end
		elseif op == 0xe then -- dconst_0
			out = out .. [[

			thread:pushOperand(types.new("double", 0.0))]]
		elseif op == 0xf then -- dconst_1
			out = out .. [[

			thread:pushOperand(types.new("double", 1.0))]]
		elseif op == 0x10 then -- bipush
			local byte = code[pc+1]
			out = out .. [[

			thread:pushOperand(types.new("int", ]].. byte ..[[))]]
			pc = pc + 1
		elseif op == 0x11 then -- sipush
			local byte = (code[thread.pc+1] << 8) | code[pc+2]
			out = out .. [[

			thread:pushOperand(types.new("int", ]].. byte ..[[))]]
			pc = pc + 2
		elseif op == 0x12 then -- ldc
			error("todo")
			self.pc = self.pc + 1
			local index = code[self.pc]
			local constant = class.constantPool[index]
			ldc(self, constant)
		elseif op == 0x13 or op == 0x14 then -- ldc_w and ldc2_w
			error("todo")
			local index = (code[self.pc+1] << 8) | code[self.pc+2]
			local constant = class.constantPool[index]
			ldc(self, constant)
			pc = pc + 2
		elseif op == 0x15 or op == 0x1a or op == 0x1b or op == 0x1c or op == 0x1d then -- iload and iload_<n>
			local idx = 0
			if op == 0x15 then
				pc = pc + 1
				idx = code[pc]
			elseif op == 0x1b then -- iload_1
				idx = 1
			elseif op == 0x1c then -- iload_2
				idx = 2
			elseif op == 0x1d then -- iload_3
				idx = 3
			end
			-- iload_0 doesn't have an if here as "idx" is by default set to 0
			out = out .. "\nthread:pushOperand(self.currentFrame.localVariables[".. idx+1 .."])"
		elseif op == 0x16 or op == 0x1e or op == 0x1f or op == 0x20 or op == 0x21 then -- lload and lload_<n>
			local idx = 0
			if op == 0x16 then
				pc = pc + 1
				idx = code[pc]
			elseif op == 0x1f then -- lload_1
				idx = 1
			elseif op == 0x20 then -- lload_2
				idx = 2
			elseif op == 0x21 then -- lload_3
				idx = 3
			end
			-- iload_0 doesn't have an if here as "idx" is by default set to 0
			out = out .. "\nthread:pushOperand(thread.currentFrame.localVariables[".. idx+1 .."])"
		elseif op == 0x19 or op == 0x2a or op == 0x2b or op == 0x2c or op == 0x2d then -- aload and aload_<n>
			local idx = 0
			if op == 0x19 then
				pc = pc + 1
				idx = code[pc]
			elseif op == 0x2b then -- aload_1
				idx = 1
			elseif op == 0x2c then -- aload_2
				idx = 2
			elseif op == 0x2d then -- aload_3
				idx = 3
			end
			-- aload_0 doesn't have an if here as "idx" is by default set to 0
			out = out .. "\nthread:pushOperand(thread.currentFrame.localVariables[".. idx+1 .."])"
		elseif op == 0x32 then -- aaload
			out = out .. [[

			local idx = thread:popOperand()[2]
			local array = thread:popOperand()
			thread:pushOperand(array[2].array[idx+1])]]
		elseif op == 0x34 then -- caload
			out = out .. [[

			local idx = thread:popOperand()[2]
			local array = thread:popOperand()
			thread:pushOperand(array[2].array[idx+1])]]
		elseif op == 0x36 or op == 0x3b or op == 0x3c or op == 0x3d or op == 0x3e then -- istore and istore_<n>
			local idx = 0
			if op == 0x36 then
				pc = pc + 1
				idx = code[pc]
			elseif op == 0x3c then -- istore_1
				idx = 1
			elseif op == 0x3d then -- istore_2
				idx = 2
			elseif op == 0x3e then -- istore_3
				idx = 3
			end
			-- istore_0 doesn't have an if here as "idx" is by default set to 0
			out = out .. "\nthread.currentFrame.localVariables[".. idx+1 .. "] = thread:popOperand()"
		elseif op == 0x37 or op == 0x3f or op == 0x40 or op == 0x41 or op == 0x42 then -- lstore and lstore_<n>
			local idx = 0
			if op == 0x37 then
				pc = pc + 1
				idx = code[pc]
			elseif op == 0x40 then -- lstore_1
				idx = 1
			elseif op == 0x41 then -- lstore_1
				idx = 2
			elseif op == 0x42 then -- lstore_3
				idx = 3
			end
			-- lstore_0 doesn't have an if here as "idx" is by default set to 0
			out = out .. "\nthread.currentFrame.localVariables[".. idx+1 .. "] = thread:popOperand()"
		elseif op == 0x3a or op == 0x4b or op == 0x4c or op == 0x4d or op == 0x4e then -- astore and astore_<n>
			local idx = 0
			if op == 0x3a then
				pc = pc + 1
				idx = code[pc]
			elseif op == 0x4c then -- astore_1
				idx = 1
			elseif op == 0x4d then -- astore_2
				idx = 2
			elseif op == 0x4e then -- astore_3
				idx = 3
			end
			-- astore_0 doesn't have an if here as "idx" is by default set to 0
			out = out .. "\nthread.currentFrame.localVariables[".. idx+1 .. "] = thread:popOperand()"
		elseif op == 0x53 then -- aastore
			out = out .. [[

			local val = thread:popOperand()
			local idx = thread:popOperand()[2]
			local array = thread:popOperand()
			array[2].array[idx+1] = val]]
		elseif op == 0x55 then -- castore
			out = out .. [[

			local val = thread:popOperand()
			local idx = thread:popOperand()[2]
			local array = thread:popOperand()
			array[2].array[idx+1] = val]]
		elseif op == 0x57 then -- pop
			out = out .. [[

			self:popOperand()]]
		elseif op == 0x59 then -- dup
			out = out .. [[

			local operand = thread:popOperand()
			thread:pushOperand(operand)
			thread:pushOperand(operand)]]
		elseif op == 0x60 then -- iadd
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("int", first + second))]]
		elseif op == 0x61 then -- ladd
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("long", first + second))]]
		elseif op == 0x64 then -- isub
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("int", first - second))]]
		elseif op == 0x65 then -- lsub
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("long", first - second))]]
		elseif op == 0x68 then -- imul
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("int", first * second))]]
		elseif op == 0x6b then -- dmul
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("double", first * second))]]
		elseif op == 0x6c then -- idiv
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("int", math.floor(first / second)))]]
		elseif op == 0x6d then -- ldiv
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("long", math.floor(first / second)))]]
		elseif op == 0x70 then -- irem
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("int", first - math.floor(first/second) * second))]]
		elseif op == 0x74 then -- ineg
			out = out .. [[

			local value = thread:popOperand()[2]
			thread:pushOperand(types.new("int", value * -1))]]
		elseif op == 0x75 then -- ishl
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("int", first << (second & 0x1F)))]]
		elseif op == 0x7a then -- ishr
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("int", first >> (second & 0x1F)))]]
		elseif op == 0x7e then -- iand
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("int", first & second))]]
		elseif op == 0x80 then -- ior
			out = out .. [[

			local second = thread:popOperand()[2]
			local first = thread:popOperand()[2]
			thread:pushOperand(types.new("int", first | second))]]
		elseif op == 0x84 then -- iinc
			local index = code[pc+1]
			local const = string.unpack("b", string.char(code[pc+2]))
			out = out .. [[

			local var = thread.currentFrame.localVariables[]].. index+1 ..[[]
			var[2] = var[2] + ]].. const ..[[]]
			pc = pc + 2
		elseif op == 0x85 then -- i2l
			out = out .. [[

			thread:pushOperand(types.new("long", thread:popOperand()[2]))]]
		elseif op == 0x8e then -- d2i
			out = out .. [[

			local operand = thread:popOperand()
			if types.type(operand) ~= "double" then
				error(types.type(operand) .. " is not a double")
			end
			local int = math.floor(operand[2])
			thread:pushOperand(types.new("int", int))]]
		elseif op == 0x8f then -- d2l
			out = out .. [[

			local operand = thread:popOperand()
			local long = math.floor(operand[2])
			thread:pushOperand(types.new("long", long))]]
		elseif op == 0x99 then -- ifeq
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val1 = thread:popOperand()
			if val1 == 0 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0x9a then -- ifne
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val1 = thread:popOperand()
			if val1 ~= 0 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0x9b then -- iflt
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val1 = thread:popOperand()
			if val1 < 0 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0x9c then -- ifge
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val1 = thread:popOperand()
			if val1 >= 0 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0x9d then -- ifgt
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val1 = thread:popOperand()
			if val1 > 0 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0x9e then -- ifle
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val1 = thread:popOperand()
			if val1 <= 0 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0x9f then -- if_icmpeq
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val2 = thread:popOperand()
			local val1 = thread:popOperand()
			if val1 == val2 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0xa0 then -- if_icmpne
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val2 = thread:popOperand()
			local val1 = thread:popOperand()
			if val1 ~= val2 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0xa1 then -- if_icmplt
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val2 = thread:popOperand()
			local val1 = thread:popOperand()
			if val1 < val2 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0xa2 then -- if_icmpge
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val2 = thread:popOperand()
			local val1 = thread:popOperand()
			if val1 >= val2 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0xa3 then -- if_icmpgt
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val2 = thread:popOperand()
			local val1 = thread:popOperand()
			if val1 > val2 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0xa4 then -- if_icmple
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			local val2 = thread:popOperand()
			local val1 = thread:popOperand()
			if val1 <= val2 then
				goto _]] .. tostring(pc+branch-1) .. [[_
			end]]
			pc = pc + 2
		elseif op == 0xa7 then -- goto
			local branch = string.unpack(">i2", string.char(code[pc+1]) .. string.char(code[pc+2]))
			out = out .. [[

			goto _]] .. tostring(pc+branch-1) .. "_"
			pc = pc + 2
		elseif op == 0xac or op == 0xad or op == 0xb0 then -- ireturn and lreturn and areturn
			out = out .. [[

			local ref = thread:popOperand()
			ret = ref
			break]]
		elseif op == 0xb1 then -- return
			out = out .. "\nbreak"
		elseif op == 0xb2 then -- getstatic
			local index = (code[pc+1] << 8) | code[pc+2]
			local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
			local nat = class.constantPool[nameAndTypeIndex]
			local fieldClassPath = class.constantPool[index].class.name.text
			out = out .. [[

			local fieldClass, err = classLoader.loadClass(fieldClassPath, true)
			local field = nil
			for k, v in pairs(fieldClass.fields) do
				if v.name == "]] .. nat.name.text [[" then
					field = v
					break
				end
			end
			thread:pushOperand(field.staticValue)]]
			pc = pc + 2
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
			local index = (code[pc+1] << 8) | code[pc+2]
			local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
			local nat = class.constantPool[nameAndTypeIndex]
			out = out .. [[

			local objectRef = thread:popOperand()
			local fieldClass = objectRef[2].class[2].class
			local field = nil
			for k, v in pairs(fieldClass.fields) do
				if v.name == "]] .. nat.name.text .. [[" then
					field = v
					break
				end
			end
			thread:pushOperand(objectRef[2].object[field.name])]]
			pc = pc + 2
		elseif op == 0xb5 then -- putfield
			local index = (code[pc+1] << 8) | code[pc+2]
			local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
			local nat = class.constantPool[nameAndTypeIndex]
			out = out .. [[

			local value = thread:popOperand()
			local objectRef = thread:popOperand()
			local fieldClass = objectRef[2].class[2].class
			local field = nil
			for k, v in pairs(fieldClass.fields) do
				if v.name == "]] .. nat.name.text .. [[" then
					field = v
					break
				end
			end
			objectRef[2].object[field.name] = value]]
			pc = pc + 2
		elseif op == 0xb6 then -- invokevirtual
			local index = (code[pc+1] << 8) | code[pc+2]
			local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
			local nat = class.constantPool[nameAndTypeIndex]

			-- temporary / TODO use descriptors
			local desc = types.readMethodDescriptor(nat.descriptor.text)
			local argsCount = #desc.params
			out = out .. [[

			local args = {}
			for i=1, ]] .. argsCount .. [[ do
				table.insert(args, thread:popOperand())
			end
			local ref = thread:popOperand()
			table.insert(args, ref)
			reverse(args)
			local cl = ref[2].class[2].class
			local method, methodClass = findMethod(cl, "]] .. nat.name.text .. "\", \"" .. nat.descriptor.text .. [[")
			thread:executeMethod(methodClass, method, args)]]
			pc = pc + 2
		elseif op == 0xb7 then -- invokespecial
			local index = (code[pc+1] << 8) | code[pc+2]
			local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
			local nat = class.constantPool[nameAndTypeIndex]

			-- temporary / TODO use descriptors
			local desc = types.readMethodDescriptor(nat.descriptor.text)
			local argsCount = #desc.params
			local classPath = class.constantPool[index].class.name.text
			out = out .. [[

			local args = {}
			for i=1, ]] .. argsCount .. [[ do
				table.insert(args, thread:popOperand())
			end
			local ref = thread:popOperand()
			table.insert(args, ref)
			reverse(args)
			local cl, err = classLoader.loadClass("]] .. classPath .. [[", true)
			local method, methodClass = findMethod(cl, nat.name.text, nat.descriptor.text)
			self:executeMethod(methodClass, method, args)]]
			pc = pc + 2
		elseif op == 0xb8 then -- invokestatic
			local index = (code[pc+1] << 8) | code[pc+2]
			local nameAndTypeIndex = class.constantPool[index].nameAndTypeIndex
			local nat = class.constantPool[nameAndTypeIndex]
			local desc = types.readMethodDescriptor(nat.descriptor.text)
			local argsCount = #desc.params
			out = out .. [[

			local args = {}
			for i=1, ]] .. argsCount .. [[ do
				table.insert(args, self:popOperand())
			end
			reverse(args)
			local objectClass, err = classLoader.loadClass(class.constantPool[index].class.name.text, true)
			if not objectClass then
				error("could not import " .. class.constantPool[index].class.name.text .. ": " .. tostring(err))
			end
			local method, methodClass = findMethod(objectClass, nat.name.text, nat.descriptor.text)
			local throwable = self:executeMethod(methodClass, method, args)
			if throwable then
				return "throwable", throwable
			end]]
			pc = pc + 2
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
			local atype = code[pc + 1]
			out = out .. [[

			local count = thread:popOperand()[2]
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
			thread:pushOperand(types.referenceForArray(arr))]]
			pc = pc + 1
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
			out = out .. [[

			local arr = thread:popOperand()
			thread:pushOperand(types.new("int", #arr[2].array))]]
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
		pc = pc + 1
	end
	out = out .. [[

	if thread:operandStackDepth() ~= 1 then
		error("operand stack was not cleaned before returning!")
	end
	thread.pc = thread:popOperand()[2]
	thread:popFrame()
	if ret and thread.currentFrame then
		thread:pushOperand(ret)
	end]]
	print(out)
	return out
end

function freqs.onExecute(method)
	if not method.code.jit then
		if not method.metrics then
			method.metrics = 0 -- number of times the method got called
			method.metricsNext = os.clock()+0.001 -- when to check for metrics
		end
		method.metrics = method.metrics + 1
		if os.clock() > method.metricsNext then -- 1 second
			print(method.class.name .. " " .. method.name .. method.descriptor .. ": " .. method.metrics)
			if method.metrics > 3 then
				method.code.jit = load(freqs.compile(method), "JIT of " .. method.class.name .. "." .. method.name .. method.descriptor)
			end
			method.metrics = 0
			method.metricsNext = os.clock()+0.001
		end
	end
end

return freqs
