local mod = StarTip:NewModule("Histograms", "AceTimer-3.0")
mod.name = "Histograms"
mod.toggled = true
--mod.childGroup = true
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
local timer
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetHistogram = LibStub("StarLibWidgetHistogram-1.0")
local LibCore = LibStub("StarLibCore-1.0")

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
	local newTbl = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			v = copy(v)
		end
		newTbl[k] = v
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
		point = {"TOPLEFT", "GameTooltip", "BOTTOMLEFT", 0, -12},
		color = [[
return HPColor(UnitHealth(unit), UnitHealthMax(unit))
]],
		layer = 1,
		update = 1000
	},
	[2] = {
		name = "Power",
		expression = "return UnitMana(unit)",
		min = "return 0",
		max = "return UnitManaMax(unit)",
		enabled = true,
		width = 10,
		height = 50,
		point = {"TOPRIGHT", "GameTooltip", "BOTTOMRIGHT", -100, -12},
		color = [[
return PowerColor("RAGE", unit)
]],
		layer = 1,
		update = 1000
	},
	[3] = {
		name = "Mem",
		type = "histogram",
		expression = [[
mem, percent, memdiff, totalMem, totaldiff = GetMemUsage("StarTip")

if mem then
    if totaldiff == 0 then totaldiff = 1 end
    return memdiff / totaldiff * 100
end
]],
		color = [[
local mem, percent, memdiff, totalMem, totaldiff = GetMemUsage("StarTip")
if mem then
    if totaldiff == 0 then totaldiff = 1 end
    memperc = (memdiff / totaldiff * 100)
    local num = floor(memperc + 0.5)
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
		point = {"TOPLEFT", "GameTooltip", "BOTTOMLEFT", 0, -77},
		layer = 1,
		update = 1000,
		persistent = true
	},
	[4] = {
		name = "CPU",
		type = "histogram",
		expression = [[
local cpu, percent, cpudiff, totalCPU, totaldiff = GetCPUUsage("StarTip")
if cpu then
    if totaldiff == 0 then totaldiff = .001 end
    return cpudiff / totaldiff * 100
end
]],
		color = [[
local cpu, percent, cpudiff, totalCPU, totaldiff = GetCPUUsage("StarTip")
if cpu then
    if totaldiff == 0 then totaldiff = 1 end
    cpuperc = (cpudiff / totaldiff * 100)
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
		point = {"TOPRIGHT", "GameTooltip", "BOTTOMRIGHT", -100, -77},
		layer = 1,
		update = 1000,
		persistent = true
	},
	
}

local defaults = {
	profile = {
		classColors = true,
	}
}

local options = {}
local optionsDefaults = {
	add = {
		name = "Add Histogram",
		desc = "Add a histogram",
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
				point = {"TOPLEFT", "GameTooltip", "BOTTOMLEFT", 0, -50},
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
		name = "Restore Defaults",
		desc = "Restore Defaults",
		type = "execute",
		func = function() 
			mod.db.profile.histograms = copy(defaultWidgets); 
			StarTip:RebuildOpts() 
		end,
		order = 6
	},
}

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
			bar:SetValue(0) --segment * 100)
			bar:SetStatusBarColor(0, 0, 1, 1)
		end
	end
end

local textureDict = {}

local new, del
do
	local pool = {}
	function new()
		local histogram = next(pool)
		
		if histogram then
			pool[histogram] = nil
		else
			histogram = CreateFrame("StatusBar", nil, GameTooltip)
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
	end
	obj:Del()
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
		
	for k, v in pairs(self.db.profile.histograms) do
		if v.enabled and not v.deleted then
			v.width = v.width or WidgetHistogram.defaults.width
			local widget = mod.histograms[v]
			local newWidget
			if not mod.histograms then mod.histograms = {} end
			if not widget then
				widget = WidgetHistogram:New(mod.core, v.name, v, v.row or 0, v.col or 0, 0, StarTip.db.profile.errorLevel, updateHistogram) 
				widget.persistent = v.persistent
				newWidget = true
				for i = 0, v.width - 1 do				
					local bar = new()
					bar:SetStatusBarTexture(LSM:Fetch("statusbar", v.texture))
					bar:ClearAllPoints()
					local arg1, arg2, arg3, arg4, arg5 = unpack(v.point)-- or {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"})
					if (v.width > 100) then
						arg4 = (arg4 or 0) + i * (v.width / 100)
					else
						arg4 = (arg4 or 0) + i * v.width
					end
					arg5 = (arg5 or 0)
					bar:SetPoint(arg1, arg2, arg3, arg4, arg5)
					if v.width then
						if (v.width > 100) then
							bar:SetWidth(v.width / 100)
						else
							bar:SetWidth(v.width or 6)
						end
					else
					bar:SetPoint("TOPLEFT", GameTooltip, "TOPLEFT")
						bar:SetPoint("BOTTOMLEFT", GameTooltip, "BOTTOMLEFT")
					end
					bar:SetHeight(v.height)
					bar:SetMinMaxValues(0, 100)
					bar:SetOrientation("VERTICAL")
					bar:SetValue(0)
					bar:Show()
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

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	
	if not self.db.profile.histograms then
		self.db.profile.histograms = {}
	end
				
	for k in pairs(self.db.profile.histograms) do
		if type(k) == "string" then
			wipe(self.db.profile.histograms)
			break
		end
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
			end
		end
	end

	for i, v in ipairs(defaultWidgets) do
		if not v.tagged and not v.deleted then
			tinsert(self.db.profile.histograms, copy(v))
		end
	end
	
	self.core = LibCore:New(mod, environment, "StarTip.Histograms", {["StarTip.Histograms"] = {}}, nil, StarTip.db.profile.errorLevel)		
	
	self.offset = 0	
	
	StarTip:SetOptionsDisabled(options, true)

	self.histograms = {}
end

function mod:OnEnable()
	if not self.histograms then self.histograms = {} end

	GameTooltip:SetClampRectInsets(0, 0, 10, 10)
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	for k, widget in pairs(self.histograms) do
		widget.bars:Del()
		for i = 1, #widget.bars do
			widget.bars[i]:Hide()
		end
	end
	GameTooltip:SetClampRectInsets(0, 0, 0, 0)
	StarTip:SetOptionsDisabled(options, true)
end

function mod:GetOptions()
	return options
end

function mod:SetUnit()
	GameTooltipStatusBar:Hide()
	self.offset = 0
	createHistograms()
	for k, widget in pairs(self.histograms) do
		for i = 1, widget.width or WidgetHistogram.defaults.width do
			widget.bars[i]:Show()			
		end
		widget:Start()
	end
end

function mod:SetItem()
	for k, widget in pairs(self.histograms) do
		for i = 1, widget.width or WidgetHistogram.defaults.width do
			widget.bars[i]:Hide()
		end
		if not widget.persistent then
			widget:Stop()
		end
	end
end

function mod:SetSpell()
	for k, widget in pairs(self.histograms) do
		for i = 1, widget.width or WidgetHistogram.defaults.width do
			widget.bars[i]:Hide()
		end
		if not widget.persistent then
			widget:Stop()
		end
	end
end

function mod:OnHide()
	if timer then
		self:CancelTimer(timer)
		timer = nil
	end
	for k, widget in pairs(self.histograms) do
		for i = 1, widget.width or WidgetHistogram.defaults.width do
			widget.bars[i]:Hide()
		end
		if not widget.persistent then
			widget:Stop()
		end
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
	wipe(options)
	for k, v in pairs(optionsDefaults) do
		options[k] = v
	end
	for i, db in ipairs(self.db.profile.histograms) do
		options[db.name:gsub(" ", "_")] = {
			name = db.name,
			type="group",
			order = i,
			args={
				enabled = {
					name = "Enable",
					desc = "Toggle whether this histogram is enabled or not",
					type = "toggle",
					get = function() return db.enabled end,
					set = function(info, v) 
						db.enabled = v 
						db["enabledDirty"] = true
						self:ClearHistograms()
					end,
					order = 1
				},
				height = {
					name = "Histogram height",
					desc = "Enter the histogram's height",
					type = "input",
					pattern = "%d",
					get = function() return tostring(db.height or defaults.height) end,
					set = function(info, v) 
						db.height = tonumber(v); 
						db["heightDirty"] = true
						self:ClearHistograms()  
					end,
					order = 2
				},
				width = {
					name = "Histogram width",
					desc = "Enter the histogram's width",
					type = "input",
					pattern = "%d",
					get = function() return tostring(db.width or defaults.width) end,
					set = function(info, v)
						db.width = tonumber(v)
						db["widthDirty"] = true
						self:ClearHistograms()
					end,
					order = 3
				},
				layer = {
					name = "Histogram Layer",
					desc = "Enter the histogram's layer",
					type = "input",
					pattern = "%d",
					get = function() return tostring(db.layer or 0) end,
					set = function(info, v) db.layer = tonumber(v) end,
					order = 4
				},
				update = {
					name = "Histogram update rate",
					desc = "Enter the histogram's refresh rate",
					type = "input",
					pattern = "%d",
					get = function() return tostring(db.update or defaults.update) end,
					set = function(info, v) 
						db.update = tonumber(v); 
						db["updateDirty"] = true						
						self:ClearHistograms() 
					end,
					order = 5
				},
				--[[direction = {
					name = "Histogram direction",
					type = "select",
					values = WidgetHistogram.directionList,
					get = function() return db.direction or defaults.direction end,
					set = function(info, v) db.direction = v; createHistograms()StarTip:RebuildOpts() end,
					order = 4
				},
				style = {
					name = "Histogram Style",
					type = "select",
					values = WidgetHistogram.styleList,
					get = function() return db.style or defaults.style end,
					set = function(info, v) db.style = v; createHistograms()StarTip:RebuildOpts() end,
					order = 5
				},]]
				texture = {
					name = "Texture",
					desc = "The histogram's texture",
					type = "select",
					values = LSM:List("statusbar"),
					get = function()
						return StarTip:GetLSMIndexByName("statusbar", db.texture or "Blizzard")
					end,
					set = function(info, v)
						db.texture = LSM:List("statusbar")[v]
						db["textureDirty"] = true						
						self:ClearHistograms()
					end,
					order = 6
				},
				point = {
					name = "Anchor Points",
					desc = "This histogram's anchor point. These arguments are passed to bar:SetPoint()",
					type = "group",
					args = {
						point = {
							name = "Bar anchor",
							type = "select",
							values = anchors,
							get = function() return anchorsDict[db.point[1] or 1] end,
							set = function(info, v) db.point[1] = anchors[v];self:ClearHistograms(); end,
							order = 1
						},
						relativeFrame = {
							name = "Relative Frame",
							type = "input",
							get = function() return db.point[2] end,
							set = function(info, v) db.point[2] = v; self:ClearHistograms();  end,
							order = 2
						},
						relativePoint = {
							name = "Relative Point",
							type = "select",
							values = anchors,
							get = function() return anchorsDict[db.point[3] or 1] end,
							set = function(info, v) db.point[3] = anchors[v]; self:ClearHistograms();  end,
							order = 3
						},
						xOfs = {
							name = "X Offset",
							type = "input",
							pattern = "%d",
							get = function() return tostring(db.point[4] or 0) end,
							set = function(info, v) db.point[4] = tonumber(v); self:ClearHistograms();  end,
							order = 4
						},
						yOfs = {
							name = "Y Offset",
							type = "input",
							pattern = "%d",
							get = function() return tostring(db.point[5] or 0) end,
							set = function(info, v) db.point[5] = tonumber(v); self:ClearHistograms(); end,
							order = 4						
						}
					},
					order = 7
				},
				persistent = {
					name = "Persistent",
					desc = "Whether this histogram is persistent or not, meaning it won't stop when the tooltip hides.",
					type = "toggle",
					get = function() return db.persistent end,
					set = function(info, v) db.persistent = v end,
					order = 8
				},
				expression = {
					name = "Histogram expression",
					desc = "Enter the histogram's first expression",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.expression end,
					set = function(info, v) 
						db.expression = v; 
						db["expressionDirty"] = true
						self:ClearHistograms()
						 
					end,
					order = 9
				},
				min = {
					name = "Histogram min expression",
					desc = "Enter the histogram's minimum expression",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.min end,
					set = function(info, v) 
						db.min = v; 
						db["minDirty"] = true
						self:ClearHistograms()
						 
					end,
					order = 10
				
				},
				max = {
					name = "Histogram max expression",
					desc = "Enter the histogram's maximum expression",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.max end,
					set = function(info, v) 
						db.max = v; 
						db["maxDirty"] = true
						self:ClearHistograms()
						 
					end,
					order = 11
				},
				color = {
					name = "Histogram color script",
					desc = "Enter the histogram's color script",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.color end,
					set = function(info, v) 
						db.color = v; 
						db["colorDirty"] = true
						self:ClearHistograms()
						 
					end,
					order = 12
				},
				delete = {
					name = "Delete",
					desc = "Delete this widget",
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
			}
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