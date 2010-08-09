

local MAJOR = "LibEvaluator-1.0" 
local MINOR = 1
assert(LibStub, MAJOR.." requires LibStub") 
local Evaluator = LibStub:NewLibrary(MAJOR, MINOR)
if not Evaluator then return end

if not Evaluator.__index then
	Evaluator.__index = Evaluator
	Evaluator.pool = setmetatable({}, {__mode = "k"})
end

Evaluator.__call = function(...)
	self.ExecuteCode(...)
end

function Evaluator:New() 

	local obj = next(self.pool)

	if obj then
		self.pool[obj] = nil
	else
		obj = {}
	end

	setmetatable(obj, self)
	
	return obj	
end

do 
	local pool = setmetatable({},{__mode='v'})
	Evaluator.ExecuteCode = function(self, tag, code, dontSandbox, defval)
		if not defval and not dontDefault then defval = "" end
		
		if not self or not tag or not code then return end

		local runnable = pool[code]
		local err
				
		if not runnable then
			runnable, err = loadstring(code, tag)
			pool[code] = runnable
		end
	
		if not runnable then 
			StarTip:Print(err)
			return nil, err, 0
		end
		
		
		if not dontSandbox then
			local table = StarTip.new()
			table.self = self
			table._G = _G
			table.StarTip = StarTip
			table.select = select
			table.format = format
		
			setfenv(runnable, table)
		
			StarTip.del(table)
		end
		
		local ret1, ret2, ret3 = runnable(xpcall, errorhandler)
		
		defval = loadstring('return ' .. (defval or ""), "defval") or function() StarTip:Print("Error at defval"); return "" end
				
		if not ret1 then 
			ret1 = defval
		end
		
		if type(ret1) == "function" then
			ret1 = ret1()
		end
		
		return ret1, ret2
	end
end