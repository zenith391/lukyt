package.path = package.path .. ";./lib/?.lua"

local doDebug = false
function printDebug(...)
	if doDebug then
		print(...)
	end
end

local file = nil
local args = table.pack(...)
local printHelp = true
local cp = "./"
local bcp = "./std/" -- bootstrap class path

for k, v in ipairs(args) do
	if v == "--debug" then
		doDebug = true
	elseif v == "--help" then
		break
	elseif v:sub(1,6) == "--jit=" then
		local jitName = v:sub(7)
		if jitName == "none" then
			_G.jitEngine = nil
		else
			_G.jitEngine = require("jit_" .. jitName)
		end
	elseif v:sub(1,12) == "--classpath=" then
		cp = v:sub(13)
		if cp:sub(#cp,#cp) ~= "/" then
			cp = cp .. "/"
		end
	elseif v:sub(1,22) == "--bootstrap-classpath=" then
		bcp = v:sub(23)
		if bcp:sub(#bcp,#bcp) ~= "/" then
			bcp = bcp .. "/"
		end
	else
		file = v .. ".class"
		printHelp = false
	end
end

if printHelp then
	print("lukyt <class>")
	print("  --debug: Enable debug logging")
	print("  --jit=engine: Set the JIT engine.")
	print("               Default: none")
	print("               Available: freqs, none")
	print("  --classpath=path: Set the classpath to search non-bootstrap classes")
	print("                    Default: ./")
	print("  --bootstrap-classpath=path: Set the classpath to search bootstrap classes")
	print("                               Default: ./std/")
	return
end

local class = require("class")
local classLoader = require("classLoader")
local thread = require("thread")
local types = require("type")
require("nativeDefault") -- default native functions

table.insert(classLoader.classpath, bcp)
table.insert(classLoader.classpath, cp)

mainThread = thread.new()
local cl = classLoader.loadClass(file:sub(1,file:len()-6), true)
if not cl then
	error("class not found: " .. file)
end

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
