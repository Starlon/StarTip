local mod = StarTip:NewModule("Gestures")
mod.name = "Gestures"
mod.toggled = true
local WidgetGestures = LibStub("LibScriptableDisplayWidgetGestures-1.0")
local LibCore = LibStub("LibScriptableDisplayCore-1.0")
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local gestures = {}
local environment = {}

local defaults = {
	profile = {
		gestures = {
			[1] = {
				name = "Hide Tooltip",
				enabled = true,
				gestures = {{type="line", pattern="right"}, {type="line", pattern="left"}, {type="line", pattern="right"}, {type="line", pattern="left"}},
				expression = [[
--_G.GameTooltip:Hide()
]]
			}
		}
	}
}


local options = {
}

local function copy(tbl)
	if type(tbl) ~= "table" then return tbl end
	local newTbl = {}
	for k, v in pairs(tbl) do
		newTbl[k] = copy(v)
	end
	return newTbl
end


function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	
	self.core = LibCore:New(mod, environment, "StarTip.Gestures", {["StarTip.Gestures"] = {}}, nil, StarTip.db.profile.errorLevel)
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
	for i, gesture in ipairs(self.db.profile.gestures) do
		local widget = WidgetGestures:New(self.core, gesture.name, copy(gesture), StarTip.db.profile.errorLevel, timer) 
		if gesture.enabled then
			widget:Start()
		end
		tinsert(gestures, widget)
	end
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
	for i, widget in ipairs(gestures) do
		widget:Del()
	end
	wipe(gestures)
end

function mod:GetOptions()
	return options
end

