
local MAJOR = "StarLibTimer-1.0" 
local MINOR = 1
assert(LibStub, MAJOR.." requires LibStub") 
local LibTimer = LibStub:NewLibrary(MAJOR, MINOR)
if not LibTimer then return end

local objects = {}
local update
local frame = CreateFrame("Frame")

if not LibTimer.__index then
	LibTimer.__index = LibTimer
	LibTimer.pool = setmetatable({}, {__mode = "k"})
end

function LibTimer:New(duration, repeating, callback, data)
	self.duration = duration
	self.repeating = repeating
	self.callback = callback
	self.data = data
	
	local obj = next(self.pool)

	if obj then
		self.pool[obj] = nil
	else
		obj = {}
	end

	setmetatable(obj, self)
	
	return obj	
	
end

function LibTimer:Del(timer)
	
	if timer and type(timer) == "table" then
		pool[timer] = true
	else
		pool[self] = true
	end
end

function LibTimer:Start()
	self.active = true
	self.starTime = GetTime()	
	LibTimer:StarTimers()
end

function LibTimer:Stop()
	self.active = false
	LibTimer:StopTimers()
end

function LibTimer:TimeRemaining()
	if type(self.startTime) ~= "number" then return 0 end
	
	local time = GetTime()
	local diff = time - self.startTime
	
	return time - diff
end

function LibTimer:StopTimers()
	local stop = true
	for i, v in ipairs(objects) do
		if v.active then
			stop = false
		end
	end
	
	if stop then
		frame:SetScript("OnUpdate", nil)
	end
end

function LibTimer:StartTimers()
	local start = false
	for i, v in ipairs(objects) do
		if v.active then
			start = true
		end
	end
	
	if start then
		frame:SetScript("OnUpdate", update)
	end
end

local function timerUpdate(self)

	if self.timer < 0.1 then
		return
	end
	
	local elapsed = self.timer / self.dur

	if self.timer > self.dur then
		self:Stop()
		if self.callback then self.callback(self.data) end
	end
end

update = function(self, elapsed)

	if #LibFlash.objects == 0 then
		LibFlash:StopTimer()
		return
	end
	
	for i, o in ipairs(LibFlash.objects) do
		if o.active then
			o.timer = (o.timer or 0) + elapsed
			timerUpdate(o)	
		end
	end
end

