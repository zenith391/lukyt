local oldPath = package.path
package.path = package.path .. ";./jvm/?.lua"

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
	["os.name"] = osName,
	["os.arch"] = "x86", -- some default
	["os.version"] = "1.0", -- some default
	["file.separator"] = fileSeparator,
	["line.separator"] = lineSeparator,
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

local argsArray = {}
printDebug("Calling main(String[])")

mainThread.coroutine = coroutine.create(thread.executeMethod)
mainThread.coroutineStarted = true

mainThread.name = "main"

mainThread._cl = cl
mainThread._method = mainMethod
mainThread._args = argsArray

runningThreads = {mainThread}

while #runningThreads > 0 do
	for k, th in pairs(runningThreads) do
		local resume, throwable
		if th.coroutineStarted then
			resume, throwable = coroutine.resume(th.coroutine, th, th._cl, th._method, th._args)
			th.coroutineStarted = false
		else
			resume, throwable = coroutine.resume(th.coroutine)
		end
		if not resume then
			io.stderr:write("Lua error in thread \"" .. th.name .. "\": " .. throwable .. "\n")
			print("Java stack trace:")
			for k, v in pairs(th.stackTrace) do
				print("\tat " .. v.method.class.name .. " " .. v.method.name .. ":" .. v.lineNumber)
			end
			runningThreads[k] = nil
		else
			if coroutine.status(th.coroutine) == "dead" then
				if throwable then
					local throwedClass = throwable[2].class[2].class
					io.stderr:write("Exception in thread \"" .. th.name .. "\" ")
					mainThread:executeMethod(throwedClass, thread.findMethod(throwedClass, "printStackTrace", "()V"), {throwable})
				end
				runningThreads[k] = nil
			end
		end
		--print(#runningThreads)
	end
end

package.path = oldPath
