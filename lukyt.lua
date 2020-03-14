package.path = package.path .. ";./lib/?.lua"

local doDebug = false
function printDebug(...)
	if doDebug then
		print(...)
	end
end

local file = "HelloWorld.class"
local args = table.pack(...)

for k, v in ipairs(args) do
	if v == "-debug" then
		doDebug = true
	else
		file = v .. ".class"
	end
end

local class = require("class")
local classLoader = require("classLoader")
local thread = require("thread")
local types = require("type")
require("nativeDefault") -- default native functions

table.insert(classLoader.classpath, "test/") -- debug
local cl = classLoader.loadClass(file:sub(1,file:len()-6), true)
if not cl then
	error("class not found: " .. file)
end

mainThread = thread.new()
local object = mainThread:instantiateClass(cl)

local mainMethod = nil

for k,v in pairs(cl.methods) do
	if v.name == "main" then
		mainMethod = v
	end
end

local argsArray = types.referenceForArray({})
printDebug("Calling main(String[])")
mainThread:executeMethod(cl, mainMethod, {object, argsArray})
