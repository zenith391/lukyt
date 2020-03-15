-- "Freqs" Lua JIT engine 
local freqs = {}

function freqs.compile(method)

end

function freqs.onExecute(method)
	if not method.code.jit then -- **ALWAYS** compile (that's harsh)
		freqs.compile(method)
	end
end

return freqs
