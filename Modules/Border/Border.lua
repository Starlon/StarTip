local mod = StarTip:NewModule("Border")
mod.name = "Border"
mod.toggled = true
mod.defaultOff = false
local L = StarTip.L
local WidgetColor = LibStub("LibScriptableWidgetColor-1.0")
local LibCore = LibStub("LibScriptableLCDCore-1.0")
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local environment = {}
local borders = {}

local defaults = {
	profile = {
		borders = {
			[1] = {
				name = "Border",
				enabled = true,
				expression = [[
if not UnitExists(unit) then return self.oldr, self.oldg, self.oldb end
if UnitIsPlayer(unit) then
	self.oldr, self.oldg, self.oldb = ClassColor(unit)
    return ClassColor(unit)
else
	self.oldr, self.oldg, self.oldb = UnitSelectionColor(unit)
    return UnitSelectionColor(unit)
end
]],
				update = 300
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

local function draw(widget)
	GameTooltip:SetBackdropBorderColor(widget.r, widget.g, widget.b, widget.a)
end

function mod:CreateBorders()
	for i, border in ipairs(self.db.profile.borders) do
		local widget = WidgetColor:New(self.core, border.name, copy(border), StarTip.db.profile.errorLevel, draw)
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
	self.core = LibCore:New(mod, environment, "StarTip.Border", {["StarTip.Border"] = {}}, nil, StarTip.db.profile.errorLevel)
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

function mod:SetUnit()
	for k, v in pairs(borders) do
		v:Start()
	end
end

function mod:OnHide()
	for k, v in pairs(borders) do
		v:Stop()
	end
end

function mod:RebuildOpts()
	local defaults = WidgetColor.defaults
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
			args=WidgetColor:GetOptions(db, StarTip.RebuildOpts, StarTip)
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

