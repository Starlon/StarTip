local mod = StarTip:NewModule("Gestures")
mod.name = "Gestures"
mod.toggled = true
mod.defaultOff = true
local L = StarTip.L
local WidgetGestures = LibStub("LibScriptableDisplayWidgetGestures-1.0")
local LibCore = LibStub("LibScriptableDisplayCore-1.0")
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local gestures = {}
local environment = {}

-- LeftButtonDown
local buttonsList = {L["Left Button"], L["Right Button"], L["Center Button"]}
local buttons = {"LeftButton", "RightButton", "CenterButton"}
local directionsList = {L["Up"], L["Down"]}
local directions = {"Up", "Down"}

local defaults = {
	profile = {
		gestures = {
			[1] = {
				name = "Hide Tooltip",
				enabled = true,
				gestures = {{type="line", pattern="right"}, {type="line", pattern="left"}, {type="line", pattern="right"}, {type="line", pattern="left"}},
				expression = [[
if not _G.StarTip.tooltipHidden then
    _G.StarTip:HideTooltip()
else
    _G.StarTip:ShowTooltip()
end
]]
			}
		}
	}
}

local options = {}
local optionsDefaults = {
	add = {
		name = "Add Gesture",
		desc = "Add a gesture",
		type = "input",
		set = function(info, v)
			local widget = {
				name = v,
				type = "gesture",
				enabled = true,
				points = {{"TOPLEFT", "GameTooltip", "BOTTOMLEFT", 0, -50}},
				frame = "UIParent",
				expression = "return random(100)",
				custom = true
			}
			tinsert(mod.db.profile.gestures, widget)
			StarTip:RebuildOpts()

		end,
		order = 5
	},
	defaults = {
		name = "Restore Defaults",
		desc = "Restore Defaults",
		type = "execute",
		func = function()
			mod.db.profile.gestures = copy(defaultWidgets);
			StarTip:RebuildOpts()
		end,
		order = 6
	},
}

local function copy(tbl)
	if type(tbl) ~= "table" then return tbl end
	local newTbl = {}
	for k, v in pairs(tbl) do
		newTbl[k] = copy(v)
	end
	return newTbl
end

function mod:CreateGestures()
	for i, gesture in ipairs(self.db.profile.gestures) do
		local widget = WidgetGestures:New(self.core, gesture.name, copy(gesture), StarTip.db.profile.errorLevel, timer) 
		if gesture.enabled then
			widget:Start()
		end
		tinsert(gestures, widget)
	end
end

function mod:WipeGestures()
	for i, gesture in ipairs(gestures) do
		gesture:Del()
	end
	wipe(gestures)
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	self.core = StarTip.core --LibCore:New(mod, environment, "StarTip.Gestures", {["StarTip.Gestures"] = {}}, nil, StarTip.db.profile.errorLevel)
end

function mod:OnEnable()
	
	StarTip:SetOptionsDisabled(options, false)
	self:CreateGestures()
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
	self:WipeGestures()
end

function mod:GetOptions()
	return options
end

function mod:RebuildOpts()
	local defaults = WidgetGestures.defaults
	self:WipeGestures()
	self:CreateGestures()
	wipe(options)
	for k, v in pairs(optionsDefaults) do
		options[k] = v
	end
	for i, db in ipairs(self.db.profile.gestures) do
		options[db.name:gsub(" ", "_")] = {
			name = db.name,
			type="group",
			order = i,
			args=WidgetGestures:GetOptions(db, StarTip.RebuildOpts, StarTip)
		}
		options[db.name:gsub(" ", "_")].args.delete = {
			name = "Delete",
			desc = "Delete this widget",
			type = "execute",
			func = function()
				self.db.profile.gestures[i] = nil
				StarTip:RebuildOpts()
			end,
			order = 100
		}
	end
end

