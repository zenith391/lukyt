-- API for Lua <-> Java integration 
local native = {}
local classLoader = require("classLoader")
local types = require("type")

-- Transforms a Java string to a Lua string
function native.stringToLua(obj)
	local chars = obj[2].object["chars"]
	local array = chars[2].array
	local str = ""

	for k, v in ipairs(array) do
		str = str .. string.char(v[2])
	end

	return str
end

function native.luaToString(str, thread)
	local objectClass, err = classLoader.loadClass("java/lang/String", true)
	if not objectClass then
		error("could not import java/lang/String !!! " .. err)
	end
	local array = {}
	for i=1, #str do
		table.insert(array, types.new("char", string.byte(str:sub(i,i))))
	end
	local object = thread:instantiateClass(objectClass, {types.referenceForArray(array)}, true, "([C)V")
	return object
end

return native
