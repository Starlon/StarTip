local mod = StarTip:NewModule("Bars")
mod.name = "Bars"
mod.toggled = true
--mod.childGroup = true
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
local WidgetBar = LibStub("LibScriptableDisplayWidgetBar-1.0")
local LibCore = LibStub("LibScriptableDisplayCore-1.0")
local Utils = LibStub("LibScriptableDisplayPluginUtils-1.0")
local LibTimer = LibStub("LibScriptableDisplayTimer-1.0")

local environment = {}

local unit

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

local createBars
local widgets = {}

local function copy(tbl)
	if type(tbl) ~= "table" then return tbl end
	local newTbl = {}
	for k, v in pairs(tbl) do
		newTbl[k] = copy(v)
	end
	return newTbl
end

local defaultWidgets = {
	[1] = {
		name = "Health Bar",
		type = "bar",
		expression = [[
return UnitHealth(unit)
]],
		min = "return 0",
		max = "assert(unit); return UnitHealthMax(unit)",
		color1 = [[
if UnitIsPlayer(unit) then
    return ClassColor(unit)
else
    return UnitSelectionColor(unit)
end
]],
		height = 6,
		points = {{"BOTTOM", "GameTooltip", "TOP", 0, 0}, {"LEFT", "GameTooltip", "LEFT", 5, 0}, {"RIGHT", "GameTooltip", "RIGHT", -5, 0}},
		texture1 = LSM:GetDefault("statusbar"),
		enabled = true,
		layer = 1, 
		level = 100
	},
	[2] = {
		name = "Mana Bar",
		type = "bar",
		expression = [[
if not UnitExists(unit) then return end
return UnitMana(unit)
]],
		min = "return 0",
		max = "return UnitManaMax('mouseover')",
		color1 = [[
return PowerColor(nil, unit)
]],
		height = 6,
		points = {{"TOP", "GameTooltip", "BOTTOM", 0, 0}, {"LEFT", "GameTooltip", "LEFT", 5, 0}, {"RIGHT", "GameTooltip", "RIGHT", -5, 0}},
		texture1 = LSM:GetDefault("statusbar"),
		enabled = true,
		layer = 1,
		level = 100
	},


}

local defaults = {
	profile = {
		classColors = true,
		bars = {}
	}
}

local options = {}
local optionsDefaults = {
	add = {
		name = "Add Bar",
		desc = "Add a bar",
		type = "input",
		set = function(info, v)
			local widget = {
				name = v,
				type = "bar",
				min = "return 0",
				max = "return 100",
				height = 6,
				points = {{"BOTTOMLEFT", "GameTooltip", "TOPLEFT", 0, 0}},
				level = 100,
				strata = 1,
				texture = LSM:GetDefault("statusbar"),
				expression = "",
				custom = true
			}
			tinsert(mod.db.profile.bars, widget)
			StarTip:RebuildOpts()
			mod:ClearBars()
		end,
		order = 5
	},
	defaults = {
		name = "Restore Defaults",
		desc = "Restore Defaults",
		type = "execute",
		func = function()
			mod.db.profile.bars = copy(defaultWidgets);
			StarTip:RebuildOpts()
		end,
		order = 6
	},
}

local intersectTimer
local intersectUpdate = function()
	WidgetBar.IntersectUpdate(mod.bars or {})
end


function updateBar(widget, bar)
	bar:SetValue(widget.val1 * 100)

	local r, g, b = 0, 0, 1

	if widget.color1 and widget.bar1 then
		r, g, b = widget.color1.res1, widget.color1.res2, widget.color1.res3
	elseif widget.color2 and widget.color2.is_valid then
		r, g, b = widget.color2.res1, widget.color2.res2, widget.color2.res3
	end

	if type(r) == "number" then
		bar:SetStatusBarColor(r, g, b)
	else
		--bar:Hide()
	end
	
end

local textureDict = {}

local new, del
do
	local pool = {}
	function new()
		local bar = next(pool)

		if bar then
			pool[bar] = nil
		else
			bar = CreateFrame("StatusBar", nil, GameTooltip)
		end

		return bar
	end
	function del(bar)
		pool[bar] = true
	end
end

local defaultPoint = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"}

local strataNameList = {
	"TOOLTIP", "FULLSCREEN_DIALOG", "FULLSCREEN", "DIALOG", "HIGH", "MEDIUM", "LOW", "BACKGROUND"
}

local strataLocaleList = {
	"Tooltip", "Fullscreen Dialog", "Fullscreen", "Dialog", "High", "Medium", "Low", "Background"
}

local function clearBar(obj)
	obj = mod.bars and mod.bars[obj]
	if not obj then return end
	obj.bar:ClearAllPoints()
	obj.bar:Hide()
	del(obj.bar)
	obj:Del()
	if obj.secondBar then
		obj.secondBar.bar:Hide()
		del(obj.secondBar.bar)
		obj.secondBar:Del()
	end
end

function mod:ClearBars()
	for k, v in pairs(mod.bars or {}) do
		clearBar(v)
	end
	wipe(mod.bars or {})
end

local function createBars()
	if type(mod.bars) ~= "table" then mod.bars = {} end

	for k, v in pairs(self.db.profile.bars) do
		if v.enabled and not v.deleted then

			local widget = mod.bars[v]
			if not widget then
				local bar = new()
				widget = WidgetBar:New(mod.core, v.name, v, v.row or 0, v.col or 0, v.layer or 0, StarTip.db.profile.errorLevel, updateBar, bar)
				bar:SetStatusBarTexture(LSM:Fetch("statusbar", v.texture1))
				bar:ClearAllPoints()
				for j, point in ipairs(v.points) do
					local arg1, arg2, arg3, arg4, arg5 = unpack(point)
					arg4 = (arg4 or 0)
					arg5 = (arg5 or 0)
					bar:SetPoint(arg1, arg2, arg3, arg4, arg5)
				end
				if type(v.width) == "number" then
					bar:SetWidth(v.width)
				end
				bar:SetHeight(v.height)
				bar:SetMinMaxValues(0, 100)
				bar:Show()
				bar:SetFrameStrata(strataNameList[v.layer])
				bar:SetFrameLevel(v.level)
				widget.bar1 = true
				widget.bar = bar
				mod.bars[v] = widget
				v.bar = bar

				if v.expression2 then
					bar = new()
					widget = WidgetBar:New(mod.core, v.name, v, v.row or 0, v.col or 0, v.layer or 0, StarTip.db.profile.errorLevel, updateBar, bar)
					bar:SetStatusBarTexture(LSM:Fetch("statusbar", v.texture2 or v.texutre1 or "Blizzard"))
					bar:ClearAllPoints()
					for i, point in ipairs(v.points) do
						local arg1, arg2, arg3, arg4, arg5 = unpack(point)
						arg4 = (arg4 or 0)
						if v.top then
							arg5 = (arg5 or 0) - (v.height or 12)
						else
							arg5 = (arg5 or 0) + (v.height or 12)
						end
						bar:SetPoint(arg1, arg2, arg3, arg4, arg5)
					end
					bar:SetWidth(v.width or 10)
					bar:SetHeight(v.height)
					bar:SetMinMaxValues(0, 100)
					bar:Show()
					bar:SetFrameStrata(strataNameList[widget.layer])
					bar:SetFrameLevel(v.level)
					mod.bars[v].secondBar = widget
				end
			end
			widget.config.unit = StarTip.unit
		end
	end
end

function mod:CreateBars()
	createBars()
end

function mod:ReInit()
	if not self.db.profile.bars then
		self.db.profile.bars = {}
	end

	for k in pairs(self.db.profile.bars) do
		if type(k) == "string" then
			wipe(self.db.profile.bars)
			break
		end
	end

	for k, v in pairs(defaultWidgets) do
		for j, vv in ipairs(self.db.profile.bars) do
			if v.name == vv.name and not vv.custom then
				for k, val in pairs(v) do
					if v[k] ~= vv[k] and not vv[k.."Dirty"] then
						vv[k] = v[k]
					end
				end
				v.tagged = true
				v.deleted = vv.deleted
			end
		end
	end

	for k, v in pairs(defaultWidgets) do
		if not v.tagged and not v.deleted then
			self.db.profile.bars[k] = copy(v)
		end
	end	
	
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)

	self:ReInit()
	
	self.core = LibCore:New(mod, environment, "StarTip.Bars", {["StarTip.Bars"] = {}}, nil, StarTip.db.profile.errorLevel)

	StarTip:SetOptionsDisabled(options, true)

	self.bars = {}
end

function mod:OnEnable()
	GameTooltip:SetClampRectInsets(0, 0, 10, 10)
	StarTip:SetOptionsDisabled(options, false)
	intersectTimer = intersectTimer or LibTimer:New("Texts.intersectTimer", 100, true, intersectUpdate)
	self:ClearBars()
	for k, bar in pairs(self.bars) do
		if bar.config.alwaysShown then
			bar:Start()
			bar.bar:Show()
			if bar.secondBar then
				bar.secondBar:Start()
				bar.secondBar:Show()
			end
		end
	end
end

function mod:OnDisable()
	self:ClearBars()
	GameTooltip:SetClampRectInsets(0, 0, 0, 0)
	StarTip:SetOptionsDisabled(options, true)
	if type(intersectTimer) == "table" then intersectTimer:Stop() end
end

--[[function mod:RebuildOpts()
	for k, v in ipairs(self.db.profile.bars) do
		options.bars.args[k] = WidgetBar:GetOptions(v)
	end
end]]

function mod:GetOptions()
	return options
end

function mod:SetUnit()
	unit = GameTooltip:GetUnit()
	GameTooltipStatusBar:Hide()
	createBars()
	for i, bar in pairs(self.bars or {}) do
		bar:Start()
		bar.bar:Show()
		if bar.secondBar then
			bar.secondBar:Start()
			bar.secondBar.bar:Show()
		end
	end
	intersectTimer:Start()
end

function mod:SetItem()
	for i, bar in pairs(self.bars or {}) do
		if not bar.config.alwaysShown then
			bar:Stop()
			bar.bar:Hide()
			if bar.secondBar then
				bar.secondBar:Stop()
				bar.secondBar.bar:Hide()
			end
		end
	end
	intersectTimer:Start()
end

function mod:SetSpell()
	for i, bar in pairs(self.bars or {}) do
		if not bar.config.alwaysShown then
			bar:Stop()
			bar.bar:Hide()
			if bar.secondBar then
				bar.secondBar:Stop()
				bar.secondBar.bar:Hide()
			end
		end
	end
	intersectTimer:Start()
end

function mod:OnHide()
	for i, bar in pairs(self.bars or {}) do
		if not bar.config.alwaysShown then
			bar:Stop()
			bar.bar:Hide()
			if bar.secondBar then
				bar.secondBar:Stop()
				bar.secondBar.bar:Hide()
			end
		end
	end
	intersectTimer:Stop()
end

local function colorGradient(perc)
    if perc <= 0.5 then
        return 1, perc*2, 0
    else
        return 2 - perc*2, 1, 0
    end
end

function mod:RebuildOpts()
	local defaults = WidgetBar.defaults
	self:ClearBars()
	wipe(options)
	for k, v in pairs(optionsDefaults) do
		options[k] = v
	end

	for i, db in ipairs(self.db.profile.bars) do
		options[db.name:gsub(" ", "_")] = {
			name = db.name,
			type="group",
			order = i,
			args = WidgetBar:GetOptions(db, StarTip.RebuildOpts, StarTip),
		}
		options[db.name:gsub(" ", "_")].args.delete = {
			name = "Delete",
			type = "execute",
			func = function()
				local delete = true
				for i, v in ipairs(defaultWidgets) do
					if db.name == v.name then
						db.deleted = true
						delete = false
					end
				end
				if delete then
					tremove(self.db.profile.bars, i)
				end
				self:ClearTexts()
				StarTip:RebuildOpts()
			end,
			order = 100
		}
		options[db.name:gsub(" ", "_")].args.enabled = {
			name = "Enabled",
			desc = "Whether the histogram's enabled or not",
			type = "toggle",
			get = function() return db.enabled end,
			set = function(info, v) 
				db.enabled = v; 
				db["enabledDirty"] = true 
				self:ClearBars()
			end,
			order = 1
		}
		options[db.name:gsub(" ", "_")].args.direction = nil
		options[db.name:gsub(" ", "_")].args.style = nil
	end
end

