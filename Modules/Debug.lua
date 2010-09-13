--@debug@
local mod = StarTip:NewModule("Debug", "AceEvent-3.0")
mod.name = "Debug"
mod.toggled = true
mod.defaultOff = true
local LibTimer = LibStub("StarLibTimer-1.0")
local LibBuffer = LibStub("StarLibBuffer-1.0")
local WidgetText = LibStub("StarLibWidgetText-1.0")
local LibProperty = LibStub("StarLibProperty-1.0")
local LibCore = LibStub("StarLibCore-1.0")

local environment = {}

local core = LibCore:New(mod, environment, "StarTip.Debug", {["StarTip.Debug"] = {}})		
local objects = {}
local timer
local cfg = {
		enabled = true,
		value = [[
if not UnitExists(unit) then return end
return '--' .. select(1, UnitName(unit)) .. '--'
]],
		color = [[
if not UnitExists(unit) then return end
return ClassColor(unit)
]],
		cols = 50,
		align = WidgetText.ALIGN_PINGPONG,
		update = 1000,
		speed = 100,
		direction = SCROLL_LEFT,
		dontRtrim = true,
		point = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT", 0, 12},
		parent = "GameTooltip",
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
end

local function new1()
	return LibBuffer:New("Debug buffer", 0, " ")
end

local function updateText(widget)

end

local function new2()
	return WidgetText:New(core, "Debug text", cfg, 0, 0, 0, StarTip.db.profile.errorLevel, updateText) 
end

local function new3()
	return LibProperty:New(nil, core,	"debug property", "", "")
end


local function update()
	for i, v in ipairs(objects) do
		v:Del()
	end
	wipe(objects)
	for j = 1, random(10) do
		local object = new2()
		tinsert(objects, object)
	end
	StarTip:Print(#objects)
end

function mod:OnEnable()
	timer = timer or LibTimer:New("Debug timer", 100, true, update)
	timer:Start()
end

function mod:OnDisable()
	timer:Stop()
end

function mod:SetUnit()
end

function mod:OnHide()
end
--@end-debug