local mod = StarTip:NewModule("Nameplates", "AceTimer-3.0")
mod.name = "Hide Nameplates"
mod.toggled = true
mod.desc = "Toggle this module on to cause the tooltip to hide when mousing over nameplates and the control key is down."
mod.defaultOff = true
local _G = _G
local StarTip = _G.StarTip
local GameTooltip = _G.GameTooltip
local GameTooltipStatusBar = _G.GameTooltipStatusBar
local UnitIsPlayer = _G.UnitIsPlayer
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitSelectionColor = _G.UnitSelectionColor
local UnitClass = _G.UnitClass
local self = mod
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetHistogram = LibStub("LibScriptableWidgetHistogram-1.0")
local LibCore = LibStub("LibScriptableLCDCore-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0")
local PluginUtils = LibStub("LibScriptablePluginUtils-1.0")

local unit
local environment = {}

local createNameplates
local widgets = {}

local anchors = {
	"TOP",
	"TOPRIGHT",
	"TOPLEFT",
	"BOTTOM",
	"BOTTOMRIGHT",
	"BOTTOMLEFT",
	"RIGHT",
	"LEFT",
	"CENTER"
}

local anchorsDict = {}

for i, v in ipairs(anchors) do
	anchorsDict[v] = i
end

local function copy(tbl)
	if type(tbl) ~= "table" then return tbl end
	local newTbl = {}
	for k, v in pairs(tbl) do
		newTbl[k] = copy(v)
	end
	return newTbl
end


local defaults = {
	profile = {
	}
}

local options = {}
local optionsDefaults = {
}

local update
function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)

	self.timer = LibTimer:New("Nameplates", 300, true, update)
end

function mod:OnEnable()	
	StarTip:SetOptionsDisabled(options, false)
	
	self.timer:Start()
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
	
	self.timer:Stop()
end

function mod:GetOptions()
	return options
end

local function isNameplate(frame)
	local region = frame:GetRegions()
	return region and region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash" 
end

local anchor = CreateFrame("Frame", "StarTipNameplateAnchor")
local size = 50
anchor:SetWidth(size)
anchor:SetHeight(size)
anchor:Show()
local frames = {}
function update()
	for i = 1, select("#", WorldFrame:GetChildren()) do
		frame = select(i, WorldFrame:GetChildren())
		if isNameplate(frame) then
			if UnitExists("mouseover") then
				local x, y = GetCursorPosition()
				anchor:ClearAllPoints()
				anchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x - size / 2, y - size / 2)
				if PluginUtils.Intersect(anchor, frame) and IsControlKeyDown() then
					GameTooltip:Hide()
					break
				end
			end
		end
	end
end

function mod:OnHide()
	self.timer:Stop()
end

function mod:SetUnit()
	self.timer:Start()
end
