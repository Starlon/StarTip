
local MAJOR = "LibProperty-1.0" 
local MINOR = 1
assert(LibStub, MAJOR.." requires LibStub") 
local LibProperty = LibStub:NewLibrary(MAJOR, MINOR)
local Evaluator = LibStub("LibEvaluator-1.0"):New()

if not LibProperty or not Evaluator then return end

if not LibProperty.pool then
	LibProperty.pool = setmetatable({},{__mode='k'})
	LibProperty.__index = LibProperty
end

function LibProperty:New(v, expression, name, defval)
	if not v or not line or not name then return end
	self.visitor = v
	self.is_valid = false
	self.expression = expression
	
	if self.expression ~= nil and type(expression) == "string" then
		self.result = Evaluator.ExecuteCode(v, self.expression, defval)
		if self.result == nil then
			StarTip:Print(("Property: %s in \"%s\""):format(self.result, self.expression))
		end
	elseif self.expression ~= nil then
		StarTip:Print(("Property: <%s> has no expression."):format(name))
	end
	
	if not frame then
		error("No frame specified")
	end

	local obj = next(self.pool)

	if obj then
		self.pool[obj] = nil
	else
		obj = {}
	end

	setmetatable(obj, self)
	
	return obj	
end

function LibProperty:Del(prop)
	LibProperty.pool[prop] = true
end

function LibProperty:Eval()
	if not self.is_valid then return -1 end
	
	local update = 1
	
	local old = self.result
	
	self.result = strlen(Evaluator.ExecuteCode(self.visitor, self.expression)) and 1
	
	if old == result then
		update = 0
	end
	
	return update
end

function LibProperty:P2N()
	if type(self.result) == "number" then
		return self.result
	else
		return tonumber(self.result)
	end
end

function LibProperty:P2S()
	if type(self.result) ~= "number" and type(self.result) ~= "string" then
		return ""
	end
	return ("%s%d"):format(self.result, self.result)
end
