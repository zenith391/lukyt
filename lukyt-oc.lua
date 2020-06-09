local oldPath = package.path
local oldLoaded = package.loaded
package.path = "./jvm/?.lua"
package.loaded["thread"] = nil
package.loaded["classLoader"] = nil
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
local bcp = "./std/bin/" -- bootstrap class path
systemProperties = {
	["java.version"] = "6",
	["java.vendor"] = "Lukyt",
	["java.vendor.url"] = "https://github.com/zenith391/lukyt",
	["java.vm.specification.version"] = "6",
	["java.vm.specification.vendor"] = "Oracle?",
	["java.vm.specification.name"] = "Mustang",
	["java.vm.version"] = "6",
	["java.vm.vendor"] = "Lukyt",
	["java.vm.name"] = "Lukyt",
	["java.class.version"] = "50.0",
	["java.class.path"] = "", -- TODO
	["java.library.path"] = "/;./",
	["java.io.tmpdir"] = "/tmp",
	["java.compiler"] = "no jit",
	["os.name"] = _OSVERSION:sub(1, _OSVERSION:find(" ")),
	["os.arch"] = _VERSION,
	["os.version"] = _OSVERSION:sub(8),
	["file.separator"] = "/",
	["line.separator"] = "\n",
	["path.separator"] = ":",
	["user.name"] = os.getenv("USER") or "Unknown",
	["user.home"] = os.getenv("HOME"),
	["user.dir"] = os.getenv("PWD") or "PWD not detected"
}

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
	elseif v:sub(1,5) == "--cp=" then
		cp = v:sub(6)
		if cp:sub(#cp,#cp) ~= "/" then
			cp = cp .. "/"
		end
	elseif v:sub(1,22) == "--bootstrap-classpath=" then
		bcp = v:sub(23)
		if bcp:sub(#bcp,#bcp) ~= "/" then
			bcp = bcp .. "/"
		end
	elseif v:sub(1,2) == "-D" then
		local equalsIndex = string.find(v, "=")
		equalsIndex = equalsIndex or v:len()+1
		local name = v:sub(3,equalsIndex-1)
		local value = v:sub(equalsIndex+1)
		if value:len() == 0 then
			value = "true"
		end
		systemProperties[name] = value
	elseif not file then
		file = v .. ".class"
		printHelp = false
	else
		error("unrecognized argument: " .. v)
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
	print("  --cp=path: Short for --classpath=path")
	print("  --bootstrap-classpath=path: Set the classpath to search bootstrap classes")
	print("                               Default: ./std/bin/")
	print("  -Dname=value: Define Java system property")
	print("                ex: -Dos.name=JEternal")
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
	error("Main class not found. Did you forgot classpath?")
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
local throwable = mainThread:executeMethod(cl, mainMethod, {object, argsArray})

if throwable then
	local throwedClass = throwable[2].class[2].class
	io.stdout:write("Exception in thread \"" .. mainThread.name .. "\" ")
	mainThread:executeMethod(throwedClass, thread.findMethod(throwedClass, "printStackTrace", "()V"), {throwable})
end

package.path = oldPath
package.loaded = oldLoaded
