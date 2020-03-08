package.path = package.path .. ";./lib/?.lua"

local doDebug = true
function printDebug(...)
	if doDebug then
		print(...)
	end
end

local class = require("class")
local classLoader = require("classLoader")
local thread = require("thread")
local types = require("type")

local cl = classLoader.loadExternalClass("test/HelloWorld.class")

mainThread = thread.new()
mainThread:instantiateClass(cl)

local mainMethod = nil

for k,v in pairs(cl.methods) do
	if v.name == "main" then
		mainMethod = v
	end
end

local argsArray = types.new("reference", {})
print("Calling main(String[])")
mainThread:executeMethod(cl, mainMethod, {argsArray})
