--@debug@
local mod = StarTip:NewModule("Debug", "AceEvent-3.0")
mod.name = "Debug"
mod.toggled = true
mod.defaultOff = true
local LibTimer = LibStub("LibScriptableDisplayTimer-1.0")
local LibBuffer = LibStub("LibScriptableDisplayBuffer-1.0")
local WidgetText = LibStub("LibScriptableDisplayWidgetText-1.0")
local LibProperty = LibStub("LibScriptableDisplayProperty-1.0")
local LibCore = LibStub("LibScriptableDisplayCore-1.0")
local PluginUnitTooltipStats = LibStub("LibScriptableDisplayPluginUnitTooltipStats-1.0")

local environment = {}

local core = LibCore:New(mod, environment, "StarTip.Debug", {["StarTip.Debug"] = {}})		
local objects = {}
local defaults = {profile={debug=false}}
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
		cols = 500,
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

local function new2()
	return WidgetText:New(core, "Debug text", cfg, 0, 0, 0, StarTip.db.profile.errorLevel, updateText) 
end

local function new3()
	return LibProperty:New(nil, core,	"debug property", "", "")
end

function mod:OnEnable()
end

function mod:OnDisable()
	timer:Stop()
end

local function getAllChildren(window)
	local tbl = {}
	for i = 1, select("#", window:GetChildren()) do
		local child = select(i, window:GetChildren())
		tinsert(tbl, child)
		if child.GetChildren then
			getAllChildren(child)
		end
	end
	
	return tbl
end

function mod:SetUnit()
	local children = getAllChildren(SkadaBarWindowSkada)
	StarTip:Print("children", #children)
	for i, child in ipairs(children) do
		if child.GetValue then
			StarTip:Print(child:GetValue())
		end
	end
end

function mod:OnHide()
end
--@end-debug