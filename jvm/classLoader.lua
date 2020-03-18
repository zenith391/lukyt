local classLoader = {}
local classCache = {}
local initedClasses = {}
classLoader.classReferences = {}
classLoader.classpath = {}
local class = require("class")
local types = require("type")

function classLoader.getReferencedClass(ref)
	return classLoader.classReferences[ref];
end

function classLoader.classObject(class, thread)
	local ref = -1
	for k, v in pairs(classLoader.classReferences) do
		if v == class then
			ref = k
		end
	end
	local classClass = classLoader.loadClass("java/lang/Class", true)
	return thread:instantiateClass(classClass, {types.new("long", ref)}, true, "(J)V")
end

function classLoader.loadClass(path, init)
	local cl, err
	for _, v in pairs(classLoader.classpath) do
		cl, err = classLoader.loadExternalClass(v .. path .. ".class")
		if not cl and err ~= "not found" then error(err) end
		if cl then
			break
		end
	end
	if cl then
		local contains = false
		for k, v in pairs(classLoader.classReferences) do
			if v == cl then
				contains = true
			end
		end
		if not contains then
			table.insert(classLoader.classReferences, cl)
		end
	end
	if cl and init and not initedClasses[path] then
		initedClasses[path] = true
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
	return cl, err
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
