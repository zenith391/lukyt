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

local osName = "Unknown"
if package.cpath then
	local binPath = package.cpath:match("%p[\\|/]?%p(%a+)")
	if binPath == "dll" then
		osName = "Windows"
	elseif binPath == "so" then
		osName = "Unix"
	elseif binPath == "dylib" then
		osName = "Mac OS X"
	end
	local fileSeparator, lineSeparator = "/", "\n"
	if osName == "Windows" then
		fileSeparator = "\\"
		lineSeparator = "\r\n"
	end
end
systemProperties = {
	["java.version"] = "0.1",
	["java.vendor"] = "Lukyt",
	["java.vendor.url"] = "https://github.com/zenith391/lukyt",
	["java.vm.specification.version"] = "2",
	["java.vm.specification.vendor"] = "Oracle?",
	["java.vm.specification.name"] = "Playground",
	["java.vm.version"] = "0.1",
	["java.vm.vendor"] = "Lukyt",
	["java.vm.name"] = "Acapella",
	["java.class.version"] = "46.0",
	["java.class.path"] = "", -- TODO
	["java.library.path"] = "/;./",
	["java.io.tmpdir"] = "",
	["java.compiler"] = "no jit",
	["os.name"] = osName,
	["os.arch"] = "unknown",
	["os.version"] = "unknown",
	["file.separator"] = fileSeparator,
	["line.separator"] = lineSeparator,
	["path.separator"] = ":",
	["user.name"] = "Unknown",
	["user.home"] = os.getenv("HOME"),
	["user.dir"] = "?"
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
mainThread:executeMethod(cl, mainMethod, {object, argsArray})
