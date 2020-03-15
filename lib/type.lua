local lib = {}
local typeMapping = {
	byte = "B",
	int = "I",
	short = "S",
	long = "L",
	char = "C",
	double = "D",
	float = "F",
	object = "O",
	reference = "R",
	returnAddress = "A"
}

function lib.nullReference()
	return lib.new("reference", {
		type = "null" -- null reference type
	})
end

function lib.referenceForArray(array)
	return lib.new("reference", {
		type = "array",
		array = array
	})
end

function lib.referenceForClass(class)
	return lib.new("reference", {
		type = "class",
		class = class
	})
end

function lib.readFieldDescriptor(descriptor)
	local t = descriptor:sub(1,1)
	if t == "I" then
		return {
			type = "int"
		}, 2
	elseif t == "B" then
		return {
			type = "byte"
		}, 2
	elseif t == "C" then
		return {
			type = "char"
		}, 2
	elseif t == "D" then
		return {
			type = "double"
		}, 2
	elseif t == "F" then
		return {
			type = "float"
		}, 2
	elseif t == "J" then
		return {
			type = "long"
		}, 2
	elseif t == "S" then
		return {
			type = "short"
		}, 2
	elseif t == "Z" then
		return {
			type = "boolean"
		}, 2
	elseif t == "L" then
		local classNameEnd = descriptor:find(";") - 1
		local className = descriptor:sub(2, classNameEnd)
		return {
			type = "object",
			className = className
		}, 3+classNameEnd
	elseif t == "[" then
		local component, cpSubIndex = lib.readFieldDescriptor(descriptor:sub(2))
		return {
			type = "array",
			component = component
		}, 1 + cpSubIndex
	end
	error("unknown type: '" .. t .. "'")
end

function lib.readMethodDescriptor(descriptor)
	local parameters = {}
	local endParam = descriptor:find(")")
	local paramDesc = descriptor:sub(2, endParam-1)
	if paramDesc:len() > 0 then
		while true do
			local param, subIndex = lib.readFieldDescriptor(paramDesc)
			table.insert(parameters, param)
			paramDesc = paramDesc:sub(subIndex)
			if paramDesc:len() == 0 then
				break
			end
		end
	end
	return {
		params = parameters
	}
end

function lib.new(v, t)
	return {typeMapping[v], t}
end

function lib.type(obj)
	for k, v in pairs(typeMapping) do
		if v == obj[1] then
			return k
		end
	end
end

return lib