local mod = StarTip:NewModule("Histograms", "AceTimer-3.0")
mod.name = "Histograms"
mod.toggled = true
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

local createHistograms
local widgets = {}

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
	["Health Histogram"] = {
		type = "histogram",
		expression = [[
if not UnitExists("mouseover") then return random(100) end
return UnitHealth("mouseover")
]],
		min = "return 0",
		max = "return UnitHealthMax('mouseover')",
		color1 = [[
if not UnitExists("mouseover") or not self then return 100 end
if self.visitor and self.visitor.visitor and self.visitor.visitor.db and self.visitor.visitor.db.profile.classColors then
    return ClassColor("mouseover")
else
    local min, max = UnitHealth("mouseover"), UnitHealthMax("mouseover")
    return HPColor(min, max)
end
]],
		height = 20,
		width = 10,
		layer = 1,
		point = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT", 0, -12},
		texture1 = LSM:GetDefault("statushistogram"),
	},
	["widget_random_histogram"] = {
		type = "histogram",
		expression = [[
do return random(100) end
mem, percent, memdiff, totalMem, totaldiff = GetMemUsage("StarTip")

if mem then
    if totaldiff == 0 then totaldiff = 1 end
    return memdiff / totaldiff * 100
end
]],
		min = "return 0",
		max = "return 100",
		reversed = true,
		char = "0",
		width = 5,
		height = 50,
		point = {"TOPLEFT", "GameTooltip", "BOTTOMLEFT", 0, -12},
		layer = 1
	},
}

local defaults = {
	profile = {
		classColors = true,
	}
}

local options = {
	add = {
		name = "Add Histogram",
		desc = "Add a histogram",
		type = "input",
		set = function(info, v)
			mod.db.profile.histograms[v] = {
				type = "histogram",
				min = "return 0",
				max = "return 100",
				height = 6,
				point = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"},
				texture = LSM:GetDefault("statushistogram"),
				expression = ""
			}
			StarTip:RebuildOpts()
			createHistograms()
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
			StarTip:Print("Bug: You'll have to reload your UI to see the change in the histograms list. I'm not sure why.")
		end,
		order = 6
	},
	histograms = {
		name = "Histograms",
		type = "group",
		args = {}
	},
}

function updateHistogram(widget, hist)
	hist:SetValue(widget.val * 100)
	
	if not widget.color then return end
	
	local r, g, b = 0, 0, 1
	
	if widget.color.is_valid then
		r, g, b = widget.color2.res1, widget.color2.res2, widget.color2.res3
	end
	
	if type(r) == "number" then
		hist:SetStatusBarColor(r, g, b)
	else
		--histogram:Hide()
	end
end

local textureDict = {}

function mod:CreateHistograms()
	createHistograms()
end

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

function createHistograms()
	if type(mod.histograms) ~= "table" then mod.histograms = {} end
	for k, v in pairs(mod.histograms) do
		v[1]:Del()
		v[2]:Hide()
		del(v[2])
	end
	wipe(mod.histograms)
	local appearance = StarTip:GetModule("Appearance")	
	for k, v in pairs(self.db.profile.histograms) do
		for i = 0, v.width - 1 do
			local histogram = new()
			local widget = WidgetHistogram:New(mod.core, k, copy(v), v.row or 0, v.col or 0, 0, StarTip.db.profile.errorLevel, updateHistogram, histogram) 
			histogram:SetStatusBarTexture(LSM:Fetch("statusbar", v.texture1))
			histogram:ClearAllPoints()
			local arg1, arg2, arg3, arg4, arg5 = unpack(v.point or {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"})
			if v.width > 100 then
				arg4 = (arg4 or 0) + i * (v.width / 100)
			else
				arg4 = (arg4 or 0) + i * (v.width or 6)
			end
			arg5 = (arg5 or 0)
			histogram:SetPoint(arg1, arg2, arg3, arg4, arg5)
			if v.width then
				if (v.width > 100) then
					histogram:SetWidth(v.width / 100)
				else
					histogram:SetWidth(v.width or 6)
				end
			else
				histogram:SetPoint("TOPLEFT", GameTooltip, "TOPLEFT")
				histogram:SetPoint("BOTTOMLEFT", GameTooltip, "BOTTOMLEFT")
			end
			histogram:SetHeight(v.height)
			histogram:SetMinMaxValues(0, 100)
			histogram:SetOrientation("VERTICAL")
			histogram:Show()
			tinsert(mod.histograms, {widget, histogram})
		end
	end
	
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	
	if not self.db.profile.histograms then
		self.db.profile.histograms = {}
	end
	
	for k, v in ipairs(defaultWidgets) do
		for kk, vv in ipairs(self.db.profile.histograms) do
			if k == kk then
				for k, val in pairs(v) do
					if v[k] ~= vv[k] and not vv[k.."Dirty"] then
						vv[k] = v[k]
					end
				end
				v.tagged = true
			end
		end
	end

	for k, v in pairs(defaultWidgets) do
		if not v.tagged and not v.deleted then
			self.db.profile.histograms[k] = v
		end
	end
	
	self.core = LibCore:New(mod, StarTip.environment, "StarTip.Histograms", {["StarTip.Histograms"] = {}}, nil, StarTip.db.profile.errorLevel)		
	
	self.offset = 0	
	
	StarTip:SetOptionsDisabled(options, true)

end

function mod:OnEnable()
	if not self.histograms then self.histograms = {} end
	
	for k, histogram in pairs(self.histograms) do
		histogram[2]:Hide()
	end
	createHistograms()
	GameTooltip:SetClampRectInsets(0, 0, 10, 10)
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	for k, histogram in pairs(self.histograms) do
		histogram[1]:Del()
		histogram[2]:Hide()
	end
	GameTooltip:SetClampRectInsets(0, 0, 0, 0)
	StarTip:SetOptionsDisabled(options, true)
end

--[[function mod:RebuildOpts()
	for k, v in ipairs(self.db.profile.histograms) do
		options.histograms.args[k] = WidgetHistogram:GetOptions(v)
	end
end]]

function mod:GetOptions()
	return options
end

function mod:SetUnit()
	GameTooltipStatusBar:Hide()
	self.offset = 0
	createHistograms()
	for i, histogram in pairs(self.histograms) do
		histogram[1]:Start()
		histogram[2]:Show()
	end
end

function mod:SetItem()
	for i, histogram in pairs(self.histograms) do
		histogram[1]:Stop()
		histogram[2]:Hide()
	end
end

function mod:SetSpell()
	for i, histogram in pairs(self.histograms) do
		histogram[1]:Stop()
		histogram[2]:Hide()
	end
end

function mod:OnHide()
	if timer then
		self:CancelTimer(timer)
		timer = nil
	end
	for i, histogram in pairs(self.histograms) do
		histogram[1]:Stop()
		histogram[2]:Hide()
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
	
	for k, db in pairs(self.db.profile.histograms) do
		options.histograms.args[k:gsub(" ", "_")] = {
			name = k,
			type="group",
			order = 6,
			args={
				height = {
					name = "Histogram height",
					desc = "Enter the histogram's height",
					type = "input",
					pattern = "%d",
					get = function() return tostring(db.height or defaults.height) end,
					set = function(info, v) 
						db.height = tonumber(v); 
						db[k.."Dirty"] = true
						createHistograms();  
					end,
					order = 2
				},
				update = {
					name = "Histogram update rate",
					desc = "Enter the histogram's refresh rate",
					type = "input",
					pattern = "%d",
					get = function() return tostring(db.update or defaults.update) end,
					set = function(info, v) 
						db.update = tonumber(v); 
						db[k.."Dirty"] = true						
						createHistograms() 
					end,
					order = 3
				},
				--[[direction = {
					name = "Histogram direction",
					type = "select",
					values = WidgetHistogram.directionList,
					get = function() return db.direction or defaults.direction end,
					set = function(info, v) db.direction = v; createHistograms() end,
					order = 4
				},
				style = {
					name = "Histogram Style",
					type = "select",
					values = WidgetHistogram.styleList,
					get = function() return db.style or defaults.style end,
					set = function(info, v) db.style = v; createHistograms() end,
					order = 5
				},]]
				texture1 = {
					name = "Texture #1",
					desc = "The histogram's first texture",
					type = "select",
					values = LSM:List("statushistogram"),
					get = function()
						return StarTip:GetLSMIndexByName("statushistogram", db.texture1 or "Blizzard")
					end,
					set = function(info, v)
						db.texture1 = LSM:List("statushistogram")[v]
						db[k.."Dirty"] = true						
						createHistograms()
					end,
					order = 4
				},
				texture2 = {
					name = "Texture #2",
					desc = "The histogram's second texture",
					type = "select",
					values = LSM:List("statushistogram"),
					get = function()
						return db.texture2 or db.texture1 or "Blizzard" 
					end,
					set = function(info, v) 
						db.texture2 = LSM:List("statushistogram")[v] 
						db[k.."Dirty"] = true						
						createHistograms() end,
					order = 5
				},
				point = {
					name = "Anchor Points",
					desc = "This histogram's anchor point. These arguments are passed to histogram:SetPoint()",
					type = "input",
					get = function() return db.point end,
					set = function(info, v) 
						db.point = v; 
						db[k.."Dirty"] = true						
						createHistograms() 
					end,
					order = 6
				},
				top = {
					name = "First is Top",
					desc = "Toggle whether to place the first histogram on top",
					type = "toggle",
					get = function() return db.top end,
					set = function(info, v) 
						db.top = v; 
						db[k.."Dirty"] = true						
						createHistograms() 
					end,
					order = 7
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
						db[k.."Dirty"] = true
						createHistograms() 
					end,
					order = 8
				},
				expression2 = {
					name = "Histogram second expression",
					desc = "Enter the histogram's second expression",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.expression2 end,
					set = function(info, v) 
						db.expression2 = v ; 
						db[k.."Dirty"] = true
						createHistograms()
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
						db[k.."Dirty"] = true
						createHistograms() 
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
						db[k.."Dirty"] = true
						createHistograms() 
					end,
					order = 11
				},
				color1 = {
					name = "First histogram color script",
					desc = "Enter the histogram's first color script",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.color1 end,
					set = function(info, v) 
						db.color1 = v; 
						db[k.."Dirty"] = true
					createHistograms() end,
					order = 12
				},
				color2 = {
					name = "Second histogram color script",
					desc = "Enter the histogram's second color script",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.color2 end,
					set = function(info, v) 
						db.color2 = v; 
						db[k.."Dirty"] = true
						createHistograms() 
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