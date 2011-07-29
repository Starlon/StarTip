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
local WidgetBar = LibStub("LibScriptableWidgetBar-1.0")
local Utils = LibStub("LibScriptablePluginUtils-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0")
local L = StarTip.L

local environment = {}

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
if not UnitExists(unit) then return self.lastHealthBar end
self.lastHealthBar = UnitHealth(unit)
return self.lastHealthBar
]],
		min = "return 0",
		max = [[
if not UnitExists(unit) then return self.lastHealthBarMax end
self.lastHealthBarMax = UnitHealthMax(unit)
return self.lastHealthBarMax
]],
		color1 = [[
if not UnitExists(unit) then return self.lastR, self.lastG, self.lastB end
local r, g, b
if UnitIsPlayer(unit) then
    r, g, b = ClassColor(unit)
else
    if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
        r, g, b = .5, .5, .5
	else
        r, g, b = UnitSelectionColor(unit)
	end
end
self.lastR, self.lastG, self.lastB = r, g, b
return r, g, b
]],
		height = 6,
		length = 0,
		points = {{"BOTTOM", "StarTipQTipMain", "TOP", 0, 0}, {"LEFT", "StarTipQTipMain", "LEFT", 5, 0}, {"RIGHT", "StarTipQTipMain", "RIGHT", -5, 0}},
		texture1 = LSM:GetDefault("statusbar"),
		enabled = true,
		layer = 1, 
		level = 100,
		parent = "StarTipQTipMain"
	},
	[2] = {
		name = "Mana Bar",
		type = "bar",
		expression = [[
if not UnitExists(unit) then return self.lastManaBar end
self.lastManaBar = UnitPower(unit)
return self.lastManaBar
]],
		min = "return 0",
		max = [[
if not UnitExists(unit) then return self.lastManaMax end
self.lastManaMax = UnitManaMax('mouseover')
return self.lastManaMax
]],
		color1 = [[
if not UnitExists(unit) then return self.lastR, self.lastG, self.lastB end
self.lastR, self.lastG, self.lastB = PowerColor(nil, unit)
return self.lastR, self.lastG, self.lastB
]],
		height = 6,
		length = 0,
		points = {{"TOP", "StarTipQTipMain", "BOTTOM", 0, 0}, {"LEFT", "StarTipQTipMain", "LEFT", 5, 0}, {"RIGHT", "StarTipQTipMain", "RIGHT", -5, 0}},
		texture1 = LSM:GetDefault("statusbar"),
		enabled = true,
		layer = 1,
		level = 100,
		parent = "StarTipQTipMain"
	},
	[3] = {
		name = "Threat Bar",
		type = "bar",
		expression = [[
if not UnitExists(unit) then return self.lastthreatpct end
local _,_,threatpct = UnitDetailedThreatSituation(unit, "target")
self.lastthreatpct = threatpct or 0
return self.lastthreatpct
]],
		color1 = [[
if not UnitExists(unit) then return self.lastStatus end
local _, status = UnitDetailedThreatSituation(unit, "target")
self.lastStatus = status 
return status
]],
		length = 6,
		height = 0,
		points = {{"LEFT", "StarTipQTipMain", "RIGHT", 0, 0}, {"TOP", "StarTipQTipMain", "TOP", 0, -5}, {"BOTTOM", "StarTipQTipMain", "BOTTOM", 0, 5}},
		texture = LSM:GetDefault("statusbar"),
		min = "return 0",
		max = "return 100",
		enabled = true,
		layer = 1,
		level = 100,
		parent = "StarTipQTipMain",
		orientation = WidgetBar.ORIENTATION_VERTICAL
	}

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
		name = L["Add Bar"],
		desc = L["Add a bar"],
		type = "input",
		set = function(info, v)
			local widget = {
				name = v,
				type = "bar",
				min = "return 0",
				max = "return 100",
				length = 12,
				height = 0,
				points = {{"RIGHT", "StarTipQTipMain", "LEFT", 0, 0}, {"TOP", "StarTipQTipMain", "TOP", 0, -5}, {"BOTTOM", "StarTipQTipMain", "BOTTOM", 0, 5}},
				level = 100,
				layer = 1,
				texture = LSM:GetDefault("statusbar"),
				expression = "return random() * 100",
				color1 = "return .5, 1, .8",
				orientation = WidgetBar.ORIENTATION_VERTICAL,
				custom = true,
				enabled = true,
				parent = "StarTipQTipMain"
			}
			tinsert(mod.db.profile.bars, widget)
			StarTip:RebuildOpts()
			mod:ClearBars()
		end,
		order = 5
	},
	defaults = {
		name = L["Restore Defaults"],
		desc = L["Restore Defaults"],
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
	for i, w in ipairs(widgets) do
		assert(type(w.IntersectUpdate) == "function", "widget.IntersectUpdate should be a function.")
		w:IntersectUpdate()
	end
end


function updateBar(widget, bar)
	assert(widget and bar)
	
	bar:SetValue(widget.val1 * 100)

	local r, g, b = 0, 0, 1

	if widget.color1 and widget.bar1 then
		r, g, b = widget.color1.ret1, widget.color1.ret2, widget.color1.ret3
	elseif widget.color2 and widget.color2.is_valid then
		r, g, b = widget.color2.ret1, widget.color2.ret2, widget.color2.ret3
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
	function new(parent)
		local bar = next(pool)
		if type(parent) == "string" then
			parent = _G[parent]
		end
		if type(parent) ~= "table" then
			parent = _G["StarTipQTipMain"]
		end
		if bar then
			pool[bar] = nil
			bar:SetParent(parent)
		else
			bar = CreateFrame("StatusBar", nil, parent)
		end

		return bar
	end
	function del(bar)
		pool[bar] = true
	end
end

local defaultPoint = {"BOTTOMLEFT", "StarTipQTipMain", "TOPLEFT"}

local strataNameList = {
	"TOOLTIP", "FULLSCREEN_DIALOG", "FULLSCREEN", "DIALOG", "HIGH", "MEDIUM", "LOW", "BACKGROUND"
}

local strataLocaleList = {
	"Tooltip", "Fullscreen Dialog", "Fullscreen", "Dialog", "High", "Medium", "Low", "Background"
}

local function clearBar(obj)
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
				local bar = new(v.parent)
				widget = WidgetBar:New(StarTip.core, v.name, copy(v), v.row or 0, v.col or 0, v.layer or 1, StarTip.db.profile.errorLevel, updateBar, bar)
				tinsert(widgets, widget)
				bar:SetStatusBarTexture(LSM:Fetch("statusbar", v.texture1))
				bar:ClearAllPoints()
				if widget.orientation == WidgetBar.ORIENTATION_VERTICAL then
					bar:SetOrientation("VERTICAL")
				else
					bar:SetOrientation("HORIZONTAL")
				end
				for j, point in ipairs(v.points) do
					local arg1, arg2, arg3, arg4, arg5 = unpack(point)
					arg4 = (arg4 or 0)
					arg5 = (arg5 or 0)
					bar:SetPoint(arg1, arg2, arg3, arg4, arg5)
				end
				bar:SetWidth(v.length or 10)
				bar:SetHeight(v.height or 10)
				bar:SetMinMaxValues(0, 100)
				bar:Show()
				bar:SetFrameStrata(strataNameList[v.layer or 1])
				bar:SetFrameLevel(v.level)
				widget.bar1 = true
				widget.bar = bar
				mod.bars[v] = widget
				v.bar = bar

				if v.expression2 then
					bar = new(v.parent)
					widget = WidgetBar:New(StarTip.core, v.name, v, v.row or 0, v.col or 0, v.layer or 0, StarTip.db.profile.errorLevel, updateBar, bar)
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
					bar:SetWidth(v.length or 10)
					bar:SetHeight(v.height)
					bar:SetMinMaxValues(0, 100)
					bar:Show()
					bar:SetFrameStrata(strataNameList[widget.layer or 1])
					bar:SetFrameLevel(v.level)
					mod.bars[v].secondBar = widget
				end
			end
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
	
	StarTip:SetOptionsDisabled(options, true)

	self.bars = {}
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
	intersectTimer = intersectTimer or LibTimer:New("Bars.intersectTimer", 100, true, intersectUpdate)
	self:ClearBars()
	for k, bar in pairs(self.bars or {}) do
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
			name = L["Delete"],
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
				self:ClearBars()
				StarTip:RebuildOpts()
			end,
			order = 100
		}
		options[db.name:gsub(" ", "_")].args.enabled = {
			name = L["Enabled"],
			desc = L["Whether the bar is enabled or not"],
			type = "toggle",
			get = function() return db.enabled end,
			set = function(info, v) 
				db.enabled = v; 
				db["enabledDirty"] = true 
				self:ClearBars()
			end,
			order = 1
		}
		options[db.name:gsub(" ", "_")].args.texture1 = {
			name = L["Texture #1"],
			desc = L["This bar's texture"],
			type = "select",
			values = LSM:List("statusbar"),
			get = function() return StarTip:GetLSMIndexByName("statusbar", db.texture1 or LSM:GetDefault("statusbar"))  end,
			set = function(info, v)
				db.texture1 = LSM:List("statusbar")[v]
				db.texture1Dirty = true
				self:ClearBars()
			end,
			order = 5,
		}
		options[db.name:gsub(" ", "_")].args.texture2 = {
			name = L["Texture #2"],
			desc = L["This bar's texture"],
			type = "select",
			values = LSM:List("statusbar"),
			get = function() return StarTip:GetLSMIndexByName("statusbar", db.texture2 or db.texture1 or LSM:GetDefault("statusbar"))  end,
			set = function(info, v)
				db.texture2 = LSM:List("statusbar")[v]
				db.texture2Dirty = true
				self:ClearBars()
			end,
			order = 6,
		}
		options[db.name:gsub(" ", "_")].args.direction = nil
		options[db.name:gsub(" ", "_")].args.style = nil
	end
end

