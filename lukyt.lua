package.path = package.path .. ";./lib/?.lua"

local doDebug = false
function printDebug(...)
	if doDebug then
		print(...)
	end
end

local file = "test/HelloWorld.class"
for k, v in ipairs(arg) do
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

local cl = classLoader.loadExternalClass(file, true)

mainThread = thread.new()
local object = mainThread:instantiateClass(cl)

local mainMethod = nil

for k,v in pairs(cl.methods) do
	if v.name == "main" then
		mainMethod = v
	end
end

local argsArray = types.new("reference", {})
printDebug("Calling main(String[])")
mainThread:executeMethod(cl, mainMethod, {object, argsArray})
