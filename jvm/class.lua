local lib = {}
local types = require("type")

-- big-endian stream Unsigned number operations
local function readU1(stream)
	return string.byte(stream:read(1))
end

local function readU2(stream)
	return (readU1(stream) << 8) | readU1(stream)
end

local function readU4(stream)
	return (readU2(stream) << 16) | readU2(stream)
end

-- big-endian Table Unsigned number operations
local function readU1T(str, off)
	return string.byte(str:sub(off,off))
end

local function readU2T(str, off)
	return (readU1T(str, off) << 8) | readU1T(str, off+1)
end

local function readU4T(str, off)
	return (readU2T(str, off) << 16) | readU2T(str, off+2)
end

local function readConstantPool(stream)
	local constantPools = {}
	local cpCount = readU2(stream)
	printDebug(cpCount .. " constants in the constant pool")
	local i = 1
	while i < cpCount do
		local tag = readU1(stream)
		if tag == 11 then -- CONSTANT_InterfaceMethodRef
			local classIndex = readU2(stream)
			local natIndex = readU2(stream)
			table.insert(constantPools, {
				type = "interfaceMethodRef",
				nameAndTypeIndex = natIndex,
				classIndex = classIndex
			})
		elseif tag == 10 then -- CONSTANT_Methodref
			local classIndex = readU2(stream)
			local natIndex = readU2(stream)
			table.insert(constantPools, {
				type = "methodRef",
				nameAndTypeIndex = natIndex,
				classIndex = classIndex
			})
		elseif tag == 9 then -- CONSTANT_Fieldref
			local classIndex = readU2(stream)
			local natIndex = readU2(stream)
			table.insert(constantPools, {
				type = "fieldRef",
				nameAndTypeIndex = natIndex,
				classIndex = classIndex
			})
		elseif tag == 8 then -- CONSTANT_String_info
			local stringIndex = readU2(stream)
			table.insert(constantPools, {
				type = "string",
				textIndex = stringIndex
			})
		elseif tag == 3 then -- CONSTANT_Integer
			local int = readU4(stream)
			table.insert(constantPools, {
				type = "integer",
				value = int
			})
		elseif tag == 4 then -- CONSTANT_Float
			local bytes = stream:read(4)
			table.insert(constantPools, {
				type = "float",
				value = string.unpack(">f", bytes)
			})
		elseif tag == 5 then -- CONSTANT_Long
			local highBytes = readU4(stream)
			local lowBytes = readU4(stream)
			table.insert(constantPools, {
				type = "long",
				value = (highBytes << 32) | lowBytes
			})
			table.insert(constantPools, {}) -- some padding
			i = i + 1
		elseif tag == 6 then -- CONSTANT_Double
			local highBytes = stream:read(4)
			local lowBytes = stream:read(4)
			table.insert(constantPools, {
				type = "double",
				value = string.unpack(">d", highBytes .. lowBytes) -- just hope double is 64-bit on this Lua interpreter
			})
			table.insert(constantPools, {}) -- some padding
			i = i + 1
		elseif tag == 12 then -- CONSTANT_NameAndType
			local nameIndex = readU2(stream)
			local descriptorIndex = readU2(stream)
			table.insert(constantPools, {
				type = "nameAndType",
				nameIndex = nameIndex,
				descriptorIndex = descriptorIndex
			})
		elseif tag == 1 then -- CONSTANT_Utf8
			local length = readU2(stream)
			local bytes = stream:read(length)
			table.insert(constantPools, {
				type = "utf8",
				text = bytes
			})
		elseif tag == 15 then -- CONSTANT_MethodHandle
			local referenceKind = readU1(stream)
			local referenceIndex = readU2(stream)

		elseif tag == 16 then -- CONSTANT_MethodType
			local descriptorIndex = readU2(stream)
			table.insert(constantPools, {
				type = "methodType",
				descriptorIndex = descriptorIndex
			})
		elseif tag == 18 then -- CONSTANT_InvokeDynamic
			local bootstrapMethodAttrIndex = readU2(stream)
			local natIndex = readU2(stream)
			table.insert(constantPools, {
				type = "invokeDynamic",
				bootstrapMethodAttrIndex = bootstrapMethodAttrIndex,
				nameAndTypeIndex = natIndex
			})
		elseif tag == 7 then -- CONSTANT_Class
			local nameIndex = readU2(stream)
			table.insert(constantPools, {
				type = "class",
				nameIndex = nameIndex
			})
		else
			print(i)
			error("unknown class constant type: " .. tag)
		end
		i = i + 1
	end

	for k, v in pairs(constantPools) do
		if v.classIndex then
			v.class = constantPools[v.classIndex]
		end
		if v.nameIndex then
			v.name = constantPools[v.nameIndex]
		end
		if v.descriptorIndex then
			v.descriptor = constantPools[v.descriptorIndex]
		end
		if v.textIndex then
			v.text = constantPools[v.textIndex]
		end
		if v.classIndex then
			v.class = constantPools[v.classIndex]
		end
	end

	return constantPools
end

local function readAttributes(stream, constantPools)
	local attributes = {}
	local attributesCount = readU2(stream)
	for i=1, attributesCount do
		local nameIndex = readU2(stream)
		local length = readU4(stream)
		local bytes = stream:read(length)
		attributes[constantPools[nameIndex].text] = bytes
	end
	return attributes
end

local function readFields(stream, constantPool)
	local fields = {}
	local fieldsCount = readU2(stream)
	printDebug(fieldsCount .. " fields")
	for i=1, fieldsCount do
		local accessFlags = readU2(stream)
		local nameIndex = readU2(stream)
		local descriptorIndex = readU2(stream)
		local attributes = readAttributes(stream, constantPool)
		local staticValue = types.nullReference()
		if attributes["ConstantValue"] then
			local value = getConstantValue(constantPool, attributes["ConstantValue"])
			if value.type == "float" or value.type == "integer" or value.type == "long" or value.type == "double" then
				staticValue = types.new(value.type, value)
			elseif value.type == "string" then
				staticValue = {"defer", value.text.text} -- the String will be instanced in the thread that initializes the class
			end
		end
		table.insert(fields, {
			accessFlags = accessFlags,
			name = constantPool[nameIndex].text,
			descriptor = constantPool[descriptorIndex].text,
			staticValue = staticValue,
			attributes = attributes
		})
	end
	return fields
end

local function getMethodExceptions(constantPool, method)
	local attr = method.attributes["Exceptions"]
	if not attr then
		return {}
	end
	local number = readU2T(attr, 1)
	local exceptions = {}
	for i=1, number do
		table.insert(exceptions, constantPool[readU2T(attr,1+i*2)])
	end
	return exceptions
end

local function getMethodCode(thisName, constantPool, method)
	if method.accessFlags & 0x100 == 0x100 then -- if ACC_NATIVE
		return {
			nativeName = thisName:gsub("/", "_") .. "_" .. method.name, -- the name of the native function to be called
			maxStackSize = -1,
			maxLocals = -1,
			code = {}
		}
	end
	if method.accessFlags & 0x400 == 0x400 then -- if ACC_ABSTRACT
		return {
			maxStackSize = -1,
			maxLocals = -1,
			code = {}
		}
	end
	local attr = method.attributes["Code"]
	if not attr then
		error("Invalid method. It doesn't contains any \"Code\" attribute.")
	end
	local maxStack = readU2T(attr, 1)
	local maxLocals = readU2T(attr, 3)
	local codeLength = readU4T(attr, 5)
	local code = table.pack(table.unpack(table.pack(attr:byte(1,attr:len())), 9, 8+codeLength))
	local number = readU2T(attr, 9+codeLength)
	local start = 11 + codeLength - 8 -- minus 8 because "i" starts at 1
	local exceptionHandlers = {}
	for i=1, number do
		local startPc = readU2T(attr, start+8*i) + 1
		local endPc = readU2T(attr, start+8*i+2) + 1
		local handlerPc = readU2T(attr, start+8*i+4) + 1
		local catchType = readU2T(attr, start+8*i+6)
		if catchType == 0 then
			catchType = "any"
		else
			catchType = constantPool[catchType].name.text
		end
		table.insert(exceptionHandlers, {
			startPc = startPc,
			endPc = endPc,
			handlerPc = handlerPc,
			catchClass = catchType
		})
	end
	return {
		nativeName = nil,
		maxStackSize = maxStack,
		maxLocals = maxLocals,
		code = code,
		exceptionHandlers = exceptionHandlers
	}
end

local function readMethods(stream, thisName, constantPool)
	local methods = {}
	local methodsCount = readU2(stream)
	printDebug(methodsCount .. " methods")
	for i=1, methodsCount do
		local accessFlags = readU2(stream)
		local nameIndex = readU2(stream)
		local descriptorIndex = readU2(stream)
 		local attributes = readAttributes(stream, constantPool)
 		local method = {
 			accessFlags = accessFlags,
 			name = constantPool[nameIndex].text,
 			descriptor = constantPool[descriptorIndex].text,
 			attributes = attributes
 		}
 		method.code = getMethodCode(thisName, constantPool, method)
 		method.exceptions = getMethodExceptions(constantPool, method)
 		table.insert(methods, method)
	end
	return methods
end

local function getSourceFile(constantPool, attributes)
	local attr = attributes["SourceFile"]
	if not attr then
		return nil
	end
	return constantPool[readU2T(attr, 1)].text
end

local function getConstantValue(constantPool, attribute)
	return constantPool[readU2T(attribute, 1)]
end

function lib.read(stream)
	if readU4(stream) ~= 0xCAFEBABE then
		error("invalid signature")
	end
	local minor = readU2(stream)
	local major = readU2(stream)
	printDebug("Class Version: " .. major .. "." .. minor)
	if major > 48 then
		error("unsupported class version, Lukyt supports only up to 1.4")
	end
	local constantPools = readConstantPool(stream)

	local accessFlags = readU2(stream)
	local thisName = constantPools[readU2(stream)].name.text
	printDebug("This class: " .. thisName)
	local superName = constantPools[readU2(stream)]
	if superName then
		superName = superName.name.text
		printDebug("Super class: " .. superName)
	else
		superName = nil
		printDebug("Super class: none")
	end
	printDebug("--- Details ---")
	local interfacesCount = readU2(stream)
	printDebug(interfacesCount .. " interfaces")

	local fields = readFields(stream, constantPools)
	printDebug("--- Class Methods --- ")
	local methods = readMethods(stream, thisName, constantPools)
	for _, v in pairs(methods) do
		printDebug(v.name .. ": " .. v.descriptor)
		printDebug("Code: " .. table.concat(v.code.code, ","))
		printDebug("-------")
	end
	local attributes = readAttributes(stream, constantPools)
	local class = {
		version = minor .. "." .. major,
		constantPool = constantPools,
		accessFlags = accessFlags,
		name = thisName,
		superClassName = superName,
		interfaces = {}, -- TODO
		fields = fields,
		methods = methods,
		sourceFile = getSourceFile(constantPools, attributes),
		attributes = attributes
	}
	for _, v in pairs(methods) do
		v.class = class
	end
	for _, v in pairs(fields) do
		v.class = class
	end
	if class.superClassName then
		class.superClass = require("classLoader").loadClass(class.superClassName)
	end
	return class
end

return lib
