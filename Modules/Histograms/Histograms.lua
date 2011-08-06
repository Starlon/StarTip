local mod = StarTip:NewModule("Histograms", "AceTimer-3.0")
mod.name = "Histograms"
mod.toggled = true
--mod.childGroup = true
mod.defaultOff = true
local _G = _G
local StarTip = _G.StarTip
local GameTooltip = _G.GameTooltip
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetHistogram = LibStub("LibScriptableWidgetHistogram-1.0")
local LibCore = LibStub("LibScriptableLCDCore-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0")
local L = StarTip.L

local unit
local environment = {}

local createHistograms
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

local defaultWidgets = {
	[1] = {
		name = "Health",
		expression = "return UnitHealth(unit)",
		min = "return 0",
		max = "return UnitHealthMax(unit)",
		enabled = true,
		width = 10,
		height = 50,
		points = {{"TOPLEFT", "StarTipTooltipMain", "BOTTOMLEFT", 0, -12}},
		color = [[
return HPColor(UnitHealth(unit), UnitHealthMax(unit))
]],
		layer = 1,
		update = 1000,
		parent = "StarTipTooltipMain"
	},
	[2] = {
		name = "Power",
		expression = "return UnitMana(unit)",
		min = "return 0",
		max = "return UnitManaMax(unit)",
		enabled = true,
		width = 10,
		height = 50,
		points = {{"TOPRIGHT", "StarTipTooltipMain", "BOTTOMRIGHT", -100, -12}},
		color = [[
return PowerColor("MANA", unit)
]],
		layer = 1,
		update = 1000,
		parent = "StarTipTooltipMain"
	},
	[3] = {
		name = "Mem",
		type = "histogram",
		expression = [[
local mem, percent, memdiff, totalMem, totaldiff, memperc = GetMemUsage("StarTip")
if mem then
    return memperc
end
]],
		color = [[
local mem, percent, memdiff, totalMem, totaldiff, memperc = GetMemUsage("StarTip")
if mem then
    local num = floor(memperc)
    if num < 1 then num = 1 end
    if num > 100 then num = 100 end
    local r, g, b = gradient[num][1], gradient[num][2], gradient[num][3]
    return r, g, b
end

]],
		min = "return 0",
		max = "return 100",
		enabled = false,
		reversed = true,
		char = "0",
		width = 10,
		height = 50,
		points = {{"TOPLEFT", "StarTipTooltipMain", "BOTTOMLEFT", 0, -77}},
		layer = 1,
		update = 1000,
		persistent = true,
		intersect = true,
		intersectPad = 1000,
		parent = "StarTipTooltipMain"
	},
	[4] = {
		name = "CPU",
		type = "histogram",
		expression = [[
if not scriptProfile then return 0 end
local cpu, percent, cpudiff, totalCPU, totaldiff, cpuperc = GetCPUUsage("StarTip")
return cpuperc
]],
		color = [[
if not scriptProfile then return 0, 1, 0 end
local cpu, percent, cpudiff, totalCPU, totaldiff, cpuperc = GetCPUUsage("StarTip")
if cpu then
    local num = floor(cpuperc)
    if num < 1 then num = 1 end
    if num > 100 then num = 100 end
    local r, g, b = gradient[num][1], gradient[num][2], gradient[num][3]
    return r, g, b
end

]],
		min = "return 0",
		max = "return 100",
		enabled = false,
		reversed = true,
		char = "0",
		width = 10,
		height = 50,
		points = {{"TOPRIGHT", "StarTipTooltipMain", "BOTTOMRIGHT", -100, -77}},
		layer = 1,
		update = 1000,
		persistent = true,
		intersect = true,
		intersectPad = 100
	},

}

local defaults = {
	profile = {
		classColors = true,
		histograms = {},
		intersect = true,
		intersectRate = 500
	}
}
mod.defaults = defaults

local options = {}
local optionsDefaults = {
	add = {
		name = L["Add Histogram"],
		desc = L["Add a histogram"],
		type = "input",
		set = function(info, v)
			local widget = {
				name = v,
				type = "histogram",
				min = "return 0",
				max = "return 100",
				height = WidgetHistogram.defaults.height,
				width = WidgetHistogram.defaults.width,
				enabled = true,
				points = {{"TOPLEFT", "StarTipTooltipMain", "BOTTOMLEFT", 0, -50}},
				texture = LSM:GetDefault("statusbar"),
				expression = "return random(100)",
				color = "return 0, 0, 1",
				custom = true
			}
			tinsert(mod.db.profile.histograms, widget)
			StarTip:RebuildOpts()

		end,
		order = 5
	},
	defaults = {
		name = L["Restore Defaults"],
		desc = L["Restore Defaults"],
		type = "execute",
		func = function()
			mod.db.profile.histograms = copy(defaultWidgets);
			StarTip:RebuildOpts()
		end,
		order = 6
	},
}

local intersectUpdate = function()
	for i, w in ipairs(widgets) do
		--w:IntersectUpdate()
	end
end

function updateHistogram(widget)
	for i = 1, #widget.history do
		local bar = widget.bars[i]
		local segment = widget.history[i]
		if not segment then break end
		if type(segment) == "table" then
			bar:SetValue((segment[1] or 0) * 100)
			local r, g, b, a = widget.history[i][2], widget.history[i][3], widget.history[i][4]
			bar:SetStatusBarColor(r, g, b, a)
		elseif type(segment) == "number" then
			bar:SetValue(segment * 100)
			bar:SetStatusBarColor(.5, .1, .8, 1)
		end
		if not UnitExists(StarTip.unit) and not widget.config.alwaysShown then bar:Hide() end
	end
end

local textureDict = {}

local new, del
do
	local pool = {}
	function new(parent)
		if type(parent) == "string" then
			parent = _G[parent]
		end
		if type(parent) ~= "table" then
			parent = _G["StarTipTooltipMain"]
		end
		local histogram = next(pool)

		if histogram then
			pool[histogram] = nil
		else
			histogram = CreateFrame("StatusBar", nil, parent)
		end

		return histogram
	end
	function del(histogram)
		pool[histogram] = true
	end
end

local function clearHistogram(obj)
	obj = mod.histograms and mod.histograms[obj]
	if not obj then return end
	for k, v in pairs(obj.bars) do
		del(v)
		v:Hide()
	end
	--obj:Del()
end

function mod:ClearHistograms()
	for k, v in pairs(mod.histograms) do
		clearHistogram(v)
	end
	wipe(mod.histograms)
end

local function createHistograms()
	if type(mod.histograms) ~= "table" then mod.histograms = {} end
	--[[for k, widget in pairs(mod.histograms) do
		for i = 1, widget.width or WidgetHistogram.defaults.width do
			widget.bars[i]:Hide()
			if widget.bars[i] then
				del(widget.bars[i])
			end
		end
		wipe(widget.bars)
	end]]

	environment.unit = "mouseover"
	if UnitInRaid("player") then
		for i=1, GetNumRaidMembers() do
			if UnitGUID("mouseover") == UnitGUID("raid" .. i) then
				environment.unit = "raid" .. i
			end
		end
	end

	for k, v in pairs(mod.db.profile.histograms) do
		if v.enabled and not v.deleted then
			v.width = v.width or WidgetHistogram.defaults.width
			local widget = mod.histograms[v]
			local newWidget
			if not mod.histograms then mod.histograms = {} end
			if not widget then
				widget = WidgetHistogram:New(StarTip.core, v.name, v, v.row or 0, v.col or 0, 0, StarTip.db.profile.errorLevel, updateHistogram)
				tinsert(widgets, widget)
				widget.persistent = v.persistent
				newWidget = true
				for i = 0, v.width - 1 do
					local bar = new()
					bar:SetStatusBarTexture(LSM:Fetch("statusbar", v.texture))
					bar:ClearAllPoints()
					for _, point in ipairs(v.points) do
						local arg1, arg2, arg3, arg4, arg5 = unpack(point)
						if (v.width > 100) then
							arg4 = (arg4 or 0) + i * (v.width / 100)
						else
							arg4 = (arg4 or 0) + i * v.width
						end
						arg5 = (arg5 or 0)
						bar:SetPoint(arg1, arg2, arg3, arg4, arg5)
					end
					if v.width then
						if (v.width > 100) then
							bar:SetWidth(v.width / 100)
						else
							bar:SetWidth(v.width or 6)
						end
					else
					bar:SetPoint("TOPLEFT", v.parent or _G["StarTipTooltipMain"], "TOPLEFT")
						bar:SetPoint("BOTTOMLEFT", v.parent or _G["StarTipTooltipMain"], "BOTTOMLEFT")
					end
					bar:SetHeight(v.height)
					bar:SetMinMaxValues(0, 100)
					bar:SetOrientation("VERTICAL")
					bar:SetValue(0)
					widget.frame = bar
					bar.widget = widget
					if not widget.bars then widget.bars = {} end
					tinsert(widget.bars, bar)
				end
			end
			widget.config.unit = StarTip.unit
			mod.histograms[v] = widget
		end
	end
end

function mod:CreateHistograms()
	createHistograms()
end

function mod:ReInit()
	if not self.db.profile.histograms then
		self.db.profile.histograms = {}
	end
	
	for i, v in ipairs(defaultWidgets) do
		for j, vv in ipairs(self.db.profile.histograms) do
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

	for i, v in ipairs(defaultWidgets) do
		if not v.tagged and not v.deleted then
			tinsert(self.db.profile.histograms, copy(v))
		end
	end
	
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)

	self:ReInit()
	
	self.offset = 0

	StarTip:SetOptionsDisabled(options, true)

	self.histograms = {}
end

function mod:OnEnable()	
	StarTip:SetOptionsDisabled(options, false)
	if StarTip.db.profile.intersectRate > 0 then
		self.intersectTimer = self.intersectTimer or LibTimer:New("Texts.intersectTimer", self.db.profile.intersectRate or 500, true, intersectUpdate)
	end
	self:ClearHistograms()
	self:CreateHistograms()
	for k, histogram in pairs(self.histograms) do
		if histogram.config.alwaysShown then
			histogram:Start()
			for _, bar in pairs(histogram.bars) do
				bar:Show()
			end
		end
	end
end

function mod:OnDisable()
	self:ClearHistograms()
	StarTip:SetOptionsDisabled(options, true)
	if self.intersectTimer then self.intersectTimer:Stop() end
end

function mod:GetOptions()
	return options
end

local plugin = LibStub("LibScriptablePluginString-1.0")
function mod:SetUnit()

	GameTooltipStatusBar:Hide()
	self.offset = 0
	for k, widget in pairs(self.histograms) do
		for i = 1, widget.width or WidgetHistogram.defaults.width do
			widget.bars[i]:Show()
		end
		widget:Start()
	end
	if self.intersectTimer then
		self.intersectTimer:Start()
	end
	
end

function mod:SetItem()
	for k, widget in pairs(self.histograms) do
		if not widget.config.alwaysShown then
			for i, bar in pairs(widget.bars) do
				bar:Hide()
			end
			if not widget.persistent then
				widget:Stop()
			end
		end
	end
	if self.intersectTimer then
		self.intersectTimer:Start()
	end
end

function mod:SetSpell()
	for k, widget in pairs(self.histograms) do
		if not widget.config.alwaysShown then
			for i, bar in pairs(widget.bars) do
				bar:Hide()
			end
			if not widget.persistent then
				widget:Stop()
			end
		end
	end
	if self.intersectTimer then
		self.intersectTimer:Start()
	end
end

function mod:OnHide()
	for k, widget in pairs(self.histograms) do
		if not widget.config.alwaysShown then
			for i, bar in pairs(widget.bars) do
				bar:Hide()
			end
			if not widget.persistent then
				widget:Stop()
			end
		end
	end
	if self.intersectTimer then
		self.intersectTimer:Stop()
	end
end

local function colorGradient(perc)
    if perc <= 0.5 then
        return 1, perc*2, 0
    else
        return 2 - perc*2, 1, 0
    end
end

function mod:RebuildOpts()
	local defaults = WidgetHistogram.defaults
	self:ClearHistograms()
	self:CreateHistograms()
	wipe(options)
	for k, v in pairs(optionsDefaults) do
		options[k] = v
	end
	for i, db in ipairs(self.db.profile.histograms) do
		options[db.name:gsub(" ", "_")] = {
			name = db.name,
			type="group",
			order = i,
			args=WidgetHistogram:GetOptions(db, StarTip.RebuildOpts, StarTip)
		}
		options[db.name:gsub(" ", "_")].args.delete = {
			name = L["Delete"],
			desc = L["Delete this widget"],
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
					self.db.profile.histograms[i] = nil
				end
				self:ClearHistograms()
				StarTip:RebuildOpts()
			end,
			order = 13
		}
		options[db.name:gsub(" ", "_")].args.enabled = {
			name = L["Enable"],
			desc = L["Toggle whether this histogram is enabled or not."],
			type = "toggle",
			get = function() return db.enabled end,
			set = function(info, v)
				db.enabled = v
				db["enabledDirty"] = true
				self:ClearHistograms()
			end,
			order = 1
		}
	end
end

-- Colors, snagged from oUF
local power = {
	[0] = { r = 48/255, g = 113/255, b = 191/255}, -- Mana
	[1] = { r = 226/255, g = 45/255, b = 75/255}, -- Rage
	[2] = { r = 255/255, g = 178/255, b = 0}, -- Focus
	[3] = { r = 1, g = 1, b = 34/255}, -- Energy
	[4] = { r = 0, g = 1, b = 1}, -- Happiness
	[5] = {}, --Unknown
	[6] = { r = 0.23, g = 0.12, b = 0.77 } -- Runic Power
}
local health = {
	[0] = {r = 49/255, g = 207/255, b = 37/255}, -- Health
	[1] = {r = .6, g = .6, b = .6} -- Tapped targets
}
local happiness = {
	[1] = {r = 1, g = 0, b = 0}, -- need.... | unhappy
	[2] = {r = 1 ,g = 1, b = 0}, -- new..... | content
	[3] = {r = 0, g = 1, b = 0}, -- colors.. | happy
}

--[[
function mod:UpdateHistogram()
	local unit = "mouseover"
	if not UnitExists(unit) then return end
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	self.hpHistogram:SetMinMaxValues(0, max)
	self.hpHistogram:SetValue(min)

	local color
	if self.db.profile.useGradient then
		color = StarTip.new()
		color.r, color.g, color.b = colorGradient(min/max)
	elseif(UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit)) then
		color = health[1]
	elseif UnitIsPlayer(unit) then
		color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
	else
		color = StarTip.new()
		color.r, color.g, color.b = UnitSelectionColor(unit)
	end
	if not color then color = health[0] end
	self.hpHistogram:SetStatusBarColor(color.r, color.g, color.b)
	StarTip.del(color)
end
]]
-- Logic snagged from oUF
--[[
function mod:UpdateHealth()
	local unit = "mouseover"
	if not UnitExists(unit) then return end
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	self.hpHistogram:SetMinMaxValues(0, max)
	self.hpHistogram:SetValue(min)

	local color
	if self.db.profile.useGradient then
		color = StarTip.new()
		color.r, color.g, color.b = colorGradient(min/max)
	elseif(UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit)) then
		color = health[1]
	elseif UnitIsPlayer(unit) then
		color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
	else
		color = StarTip.new()
		color.r, color.g, color.b = UnitSelectionColor(unit)
	end
	if not color then color = health[0] end
	self.hpHistogram:SetStatusBarColor(color.r, color.g, color.b)
	StarTip.del(color)
end

function mod:UpdateMana()
	local unit = "mouseover"
	if not UnitExists(unit) then return end
	local min, max = UnitMana(unit), UnitManaMax(unit)
	self.mpHistogram:SetMinMaxValues(0, max)
	self.mpHistogram:SetValue(min)

	local color = power[UnitPowerType(unit)]
	self.mpHistogram:SetStatusBarColor(color.r, color.g, color.b)
end
]]
