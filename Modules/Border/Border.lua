local mod = StarTip:NewModule("Border")
mod.name = "Border"
mod.toggled = true
mod.defaultOff = true
local L = StarTip.L
local WidgetBorder = LibStub("LibScriptableDisplayWidgetColor-1.0")
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local environment = {}

local defaults = {
	profile = {
		borders = {
			[1] = {
				name = "Border",
				enabled = true,
				expression = [[
return 1, 1, 0
]]
			}
		}
	}
}

local options = {}
local optionsDefaults = {
	add = {
		name = "Add Gesture",
		desc = "Add a border",
		type = "input",
		set = function(info, v)
			local widget = {
				name = v,
				type = "border",
				enabled = true,
				expression = "return random(100)",
			}
			tinsert(mod.db.profile.borders, widget)
			StarTip:RebuildOpts()

		end,
		order = 5
	},
	defaults = {
		name = "Restore Defaults",
		desc = "Restore Defaults",
		type = "execute",
		func = function()
			mod.db.profile.borders = copy(defaultWidgets);
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

function mod:CreateBorders()
	for i, border in ipairs(self.db.profile.borders) do
		local widget = WidgetColor:New(self.core, border.name, copy(border), StarTip.db.profile.errorLevel) 
		if border.enabled then
			widget:Start()
		end
		tinsert(borders, widget)
	end
end

function mod:WipeBorders()
	for i, border in ipairs(borders) do
		border:Del()
	end
	wipe(borders)
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	self.core = StarTip.core --LibCore:New(mod, environment, "StarTip.Border", {["StarTip.Border"] = {}}, nil, StarTip.db.profile.errorLevel)
end

function mod:OnEnable()
	
	StarTip:SetOptionsDisabled(options, false)
	self:CreateBorders()
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
	self:WipeBorders()
end

function mod:GetOptions()
	return options
end

function mod:RebuildOpts()
	local defaults = WidgetBorder.defaults
	self:WipeBorders()
	self:CreateBorders()
	wipe(options)
	for k, v in pairs(optionsDefaults) do
		options[k] = v
	end
	for i, db in ipairs(self.db.profile.borders) do
		options[db.name:gsub(" ", "_")] = {
			name = db.name,
			type="group",
			order = i,
			args=WidgetBorder:GetOptions(db, StarTip.RebuildOpts, StarTip)
		}
		options[db.name:gsub(" ", "_")].args.delete = {
			name = "Delete",
			desc = "Delete this widget",
			type = "execute",
			func = function()
				self.db.profile.borders[i] = nil
				StarTip:RebuildOpts()
			end,
			order = 100
		}
	end
end

