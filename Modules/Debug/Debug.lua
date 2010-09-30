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

local function new1()
	return LibBuffer:New("Debug buffer", random(1000), " ")
end

local function updateText(widget)

end

local function new2()
	return WidgetText:New(core, "Debug text", cfg, 0, 0, 0, StarTip.db.profile.errorLevel, updateText) 
end

local function new3()
	return LibProperty:New(nil, core,	"debug property", "", "")
end

local plugin = {}
LibStub("StarLibPluginUtils-1.0"):New(plugin)

local function update()
	mod.frame1:ClearAllPoints()
	mod.frame2:ClearAllPoints()
	local width = UIParent:GetWidth()
	local height = UIParent:GetHeight()
	mod.frame2:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 550 / 0.5 / 0.2, 550 / 0.5 / 0.2)
	mod.frame3:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 550, 550)
	if plugin.Intersect(mod.frame2, mod.frame3) then
		StarTip:Print("---------------intersection-----------------")
	end
end

function mod:OnEnable()
	timer = timer or LibTimer:New("Debug timer", 1000, true, update)
	if false then
		timer:Start()
	end
	do return end
			local frame = CreateFrame("Frame")
			frame:SetParent(UIParent)
			frame:SetParent(UIParent)
				frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
					tile = true,
					tileSize = 4,
					edgeSize=4, 
					insets = { left = 0, right = 0, top = 0, bottom = 0}})
			frame:ClearAllPoints()
			frame:SetAlpha(1)
			frame:SetBackdropColor(1, 1, 0)
			frame:SetHeight(250)
			frame:SetWidth(250)
			frame:Show()
			frame:SetScale(0.2)
			self.frame0 = frame
			
			local frame = CreateFrame("Frame")
			frame:SetParent(self.frame0)
				frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
					tile = true,
					tileSize = 4,
					edgeSize=4, 
					insets = { left = 0, right = 0, top = 0, bottom = 0}})
			frame:ClearAllPoints()
			frame:SetAlpha(1)
			frame:SetBackdropColor(1, 1, 0)
			frame:SetHeight(250)
			frame:SetWidth(250)
			frame:Show()
			frame:SetScale(0.5)
			self.frame1 = frame
			
			local frame = CreateFrame("Frame")
			frame:SetParent(self.frame1)
				frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
					tile = true,
					tileSize = 4,
					edgeSize=4, 
					insets = { left = 0, right = 0, top = 0, bottom = 0}})
			frame:ClearAllPoints()
			frame:SetAlpha(1)
			frame:SetBackdropColor(1, 1, 0)
			frame:SetHeight(250)
			frame:SetWidth(250)
			frame:Show()
			self.frame2 = frame

			local frame = CreateFrame("Frame")
			frame:SetParent(UIParent)
				frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
					tile = true,
					tileSize = 4,
					edgeSize=4, 
					insets = { left = 0, right = 0, top = 0, bottom = 0}})
			frame:ClearAllPoints()
			frame:SetAlpha(1)
			frame:SetBackdropColor(1, 1, 0)
			frame:SetHeight(250)
			frame:SetWidth(250)
			frame:Show()
			self.frame3 = frame
end

function mod:OnDisable()
	timer:Stop()
end

function mod:SetUnit()
end

function mod:OnHide()
end
--@end-debug