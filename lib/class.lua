local lib = {}
local types = require("type")

local function readU1(stream)
	return string.byte(stream:read(1))
end

local function readU2(stream)
	return (readU1(stream) << 8) | readU1(stream)
end

local function readU4(stream)
	return (readU2(stream) << 16) | readU2(stream)
end

local function readU1T(str, off)
	return string.byte(str:sub(off,off))
end

local function readU2T(str, off)
	return (readU1T(str, off) << 8) | readU1T(str, off+1)
end

local function readU4T(str, off)
	return (readU2T(str, off) << 16) | readU2T(str, off+2)
end

local function readConstantPools(stream)
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
		--print("name: " .. constantPools[nameIndex].text .. ", bytes: " .. bytes)
		attributes[constantPools[nameIndex].text] = bytes
	end
	return attributes
end

local function readFields(stream, constantPools)
	local fields = {}
	local fieldsCount = readU2(stream)
	printDebug(fieldsCount .. " fields")
	for i=1, fieldsCount do
		local accessFlags = readU2(stream)
		local nameIndex = readU2(stream)
		local descriptorIndex = readU2(stream)
		local attributes = readAttributes(stream, constantPools)
		local staticValue = types.nullReference()
		if attributes["ConstantValue"] then
			local index = (staticValue[1] << 8) | staticValue[2]
			print(constantPools[nameIndex].text)
		end
		table.insert(fields, {
			accessFlags = accessFlags,
			name = constantPools[nameIndex].text,
			descriptor = constantPools[descriptorIndex].text,
			staticValue = staticValue,
			attributes = attributes
		})
	end
	return fields
end

local function getMethodCode(thisName, method)
	if method.accessFlags & 0x100 == 0x100 then -- if ACC_NATIVE
		return {
			nativeName = thisName:gsub("/", "_") .. "_" .. method.name,
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
	-- TODO: exceptions, attribute's attributes
	return {
		nativeName = nil,
		maxStackSize = maxStack,
		maxLocals = maxLocals,
		code = code
	}
end

local function readMethods(stream, thisName, constantPools)
	local methods = {}
	local methodsCount = readU2(stream)
	printDebug(methodsCount .. " methods")
	for i=1, methodsCount do
		local accessFlags = readU2(stream)
		local nameIndex = readU2(stream)
		local descriptorIndex = readU2(stream)
 		local attributes = readAttributes(stream, constantPools)
 		local method = {
 			accessFlags = accessFlags,
 			name = constantPools[nameIndex].text,
 			descriptor = constantPools[descriptorIndex].text,
 			attributes = attributes
 		}
 		method.code = getMethodCode(thisName, method)
 		table.insert(methods, method)
	end
	return methods
end

local function getConstantValue(attribute)
	return readU2T(attribute, 1)
end

function lib.read(stream)
	if readU4(stream) ~= 0xCAFEBABE then
		error("invalid signature")
	end
	local minor = readU2(stream)
	local major = readU2(stream)
	printDebug("Class Version: " .. major .. "." .. minor)
	if major > 46 then
		error("unsupported Java version, support only up to 1.2")
	end
	local constantPools = readConstantPools(stream)

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
		attributes = attributes
	}
	if class.superClassName then
		class.superClass = require("classLoader").loadClass(class.superClassName)
	end
	return class
end

return lib
