local classLoader = {}
local classCache = {}
local class = require("class")
local types = require("type")

function classLoader.loadClass(path, init)
	local cl = classLoader.loadExternalClass("std/" .. path .. ".class")
	if init then
		local clInit
		for _,v in pairs(cl.methods) do
			if v.name == "<clinit>" then
				clInit = v
			end
		end
		local classReference = types.referenceForClass(cl)
		if clInit then
			mainThread:executeMethod(cl, clInit, {classReference})
		end
	end
	return cl
end

function classLoader.loadExternalClass(path)
	if classCache[path] then
		return classCache[path]
	else
		local stream = io.open(path, "rb")
		if not stream then
			return nil, "not found"
		end
		local cl = class.read(stream)
		classCache[path] = cl
		stream:close()
		return cl
	end
end

return classLoader
