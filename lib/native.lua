-- API for Lua <-> Java integration 
local native = {}

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

return native
