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

function lib.new(v, t)
	return {typeMapping[v], t}
end

function lib.type(obj)
	for k, v in pairs(typeMapping) do
		if v == obj[0] then
			return k
		end
	end
end

return lib