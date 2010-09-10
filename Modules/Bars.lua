local mod = StarTip:NewModule("Bars", "AceTimer-3.0")
mod.name = "Bars"
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
local WidgetBar = LibStub("StarLibWidgetBar-1.0")
local LibCore = LibStub("StarLibCore-1.0")


local createBars
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
	["Health Bar"] = {
		type = "bar",
		expression = [[
if not UnitExists("mouseover") then return end
return UnitHealth("mouseover")
]],
		min = "return 0",
		max = "return UnitHealthMax('mouseover')",
		color1 = [[
if not UnitExists("mouseover") or not self then return end
if self.visitor.visitor.db.profile.classColors then
    return ClassColor("mouseover")
else
    local min, max = UnitHealth("mouseover"), UnitHealthMax("mouseover")
    return HPColor(min, max)
end
]],
		height = 6,
		point = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"},
		texture1 = LSM:GetDefault("statusbar"),
		enabled = true
	},
	["Mana Bar"] = {
		type = "bar",
		expression = [[
if not UnitExists("mouseover") then return end
return UnitMana("mouseover")
]],
		min = "return 0",
		max = "return UnitManaMax('mouseover')",
		color1 = [[
if not UnitExists("mouseover") then return end
return PowerColor(nil, "mouseover")
]],
		height = 6,
		point = {"TOPLEFT", "GameTooltip", "BOTTOMLEFT"},
		texture1 = LSM:GetDefault("statusbar"),
		enabled = true
	},
	

}

local defaults = {
	profile = {
		classColors = true,
	}
}

local options = {
	add = {
		name = "Add Bar",
		desc = "Add a bar",
		type = "input",
		set = function(info, v)
			mod.db.profile.bars[v] = {
				type = "bar",
				min = "return 0",
				max = "return 100",
				height = 6,
				point = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"},
				texture = LSM:GetDefault("statusbar"),
				expression = ""
			}
			StarTip:RebuildOpts()
			createBars()
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
			StarTip:Print("Bug: You'll have to reload your UI to see the change in the bars list. I'm not sure why.")
		end,
		order = 6
	},
	bars = {
		name = "Bars",
		type = "group",
		args = {}
	},
}

function updateBar(widget, bar)
	bar:SetValue(widget.val1 * 100)
	
	if not widget.color1 then return end
	
	local r, g, b = 0, 0, 1
	
	if widget.bar1 then
		r, g, b = widget.color1.res1, widget.color1.res2, widget.color1.res3
	elseif widget.color2.is_valid then
		r, g, b = widget.color2.res1, widget.color2.res2, widget.color2.res3
	end
	
	if type(r) == "number" then
		bar:SetStatusBarColor(r, g, b)
	else
		--bar:Hide()
	end
end

local textureDict = {}

function mod:CreateBars()
	createBars()
end

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

function createBars()
	if type(mod.bars) ~= "table" then mod.bars = {} end
	for k, v in pairs(mod.bars) do
		v[1]:Del()
		v[2]:Hide()
		del(v[2])
	end
	wipe(mod.bars)
	local appearance = StarTip:GetModule("Appearance")	
	for k, v in pairs(self.db.profile.bars) do
		if v.enabled then
			local bar = new()
			local widget = WidgetBar:New(mod.core, k, copy(v), v.row or 0, v.col or 0, 0, StarTip.db.profile.errorLevel, updateBar, bar) 
			bar:SetStatusBarTexture(LSM:Fetch("statusbar", v.texture1))
			bar:ClearAllPoints()
			local arg1, arg2, arg3, arg4, arg5 = unpack(v.point or {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"})
			arg4 = (arg4 or 0)
			arg5 = (arg5 or 0)
			bar:SetPoint(arg1, arg2, arg3, arg4, arg5)
			if type(v.width) == "number" then
				bar:SetWidth(v.width)
			else
				bar:SetPoint("LEFT", GameTooltip, "LEFT")
				bar:SetPoint("RIGHT", GameTooltip, "RIGHT")
			end
			bar:SetHeight(v.height)
			bar:SetMinMaxValues(0, 100)
			bar:Show()
			widget.bar1 = true
			tinsert(mod.bars, {widget, bar})
			
			if v.expression2 then
				bar = new()
				widget = WidgetBar:New(mod.core, k, copy(v), v.row or 0, v.col or 0, 0, StarTip.db.profile.errorLevel, updateBar, bar)
				bar:SetStatusBarTexture(LSM:Fetch("statusbar", v.texture2 or v.texutre1 or "Blizzard"))
				bar:ClearAllPoints()
				local arg1, arg2, arg3, arg4, arg5 = unpack(v.point or {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"})
				arg4 = (arg4 or 0)
				if v.top then
					arg5 = (arg5 or 0) - (v.height or 12)
				else
					arg5 = (arg5 or 0) + (v.height or 12)
				end
				bar:SetPoint(arg1, arg2, arg3, arg4, arg5)
				if type(v.width) == "number" then
					bar:SetWidth(v.width)
				else
					bar:SetPoint("LEFT", GameTooltip, "LEFT")
					bar:SetPoint("RIGHT", GameTooltip, "RIGHT")
				end
				bar:SetHeight(v.height)
				bar:SetMinMaxValues(0, 100)
				bar:Show()
				tinsert(mod.bars, {widget, bar})
			end
		end
	end
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	
	if not self.db.profile.bars then
		self.db.profile.bars = {}
	end
	
	for k, v in pairs(defaultWidgets) do
		for kk, vv in pairs(self.db.profile.bars) do
			if v.name == vv.name then
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
			self.db.profile.bars[k] = v
		end
	end
	
	self.core = LibCore:New(mod, StarTip.environment, "StarTip.Bars", {["StarTip.Bars"] = {}}, nil, StarTip.db.profile.errorLevel)		
	
	self.offset = 0	
	
	StarTip:SetOptionsDisabled(options, true)

end

function mod:OnEnable()
	if not self.bars then self.bars = {} end
	
	for k, bar in pairs(self.bars) do
		bar[2]:Hide()
	end
	createBars()
	GameTooltip:SetClampRectInsets(0, 0, 10, 10)
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	for k, bar in pairs(self.bars) do
		bar[1]:Del()
		bar[2]:Hide()
	end
	GameTooltip:SetClampRectInsets(0, 0, 0, 0)
	StarTip:SetOptionsDisabled(options, true)
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
	self.offset = 0
	createBars()
	for i, bar in pairs(self.bars) do
		bar[1]:Start()
		bar[2]:Show()
	end
end

function mod:SetItem()
	for i, bar in pairs(self.bars) do
		bar[1]:Stop()
		bar[2]:Hide()
	end
end

function mod:SetSpell()
	for i, bar in pairs(self.bars) do
		bar[1]:Stop()
		bar[2]:Hide()
	end
end

function mod:OnHide()
	if timer then
		self:CancelTimer(timer)
		timer = nil
	end
	for i, bar in pairs(self.bars) do
		bar[1]:Stop()
		bar[2]:Hide()
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
	local defaults = WidgetBar.defaults
	
	for k, db in pairs(self.db.profile.bars) do
		options.bars.args[k:gsub(" ", "_")] = {
			name = k,
			type="group",
			order = 6,
			args={
				height = {
					name = "Bar height",
					desc = "Enter the bar's height",
					type = "input",
					pattern = "%d",
					get = function() return tostring(db.height or defaults.height) end,
					set = function(info, v) 
						db.height = tonumber(v); 
						db[k.."Dirty"] = true
						createBars();  
					end,
					order = 2
				},
				update = {
					name = "Bar update rate",
					desc = "Enter the bar's refresh rate",
					type = "input",
					pattern = "%d",
					get = function() return tostring(db.update or defaults.update) end,
					set = function(info, v) 
						db.update = tonumber(v); 
						db[k.."Dirty"] = true						
						createBars() 
					end,
					order = 3
				},
				--[[direction = {
					name = "Bar direction",
					type = "select",
					values = WidgetBar.directionList,
					get = function() return db.direction or defaults.direction end,
					set = function(info, v) db.direction = v; createBars() end,
					order = 4
				},
				style = {
					name = "Bar Style",
					type = "select",
					values = WidgetBar.styleList,
					get = function() return db.style or defaults.style end,
					set = function(info, v) db.style = v; createBars() end,
					order = 5
				},]]
				texture1 = {
					name = "Texture #1",
					desc = "The bar's first texture",
					type = "select",
					values = LSM:List("statusbar"),
					get = function()
						return StarTip:GetLSMIndexByName("statusbar", db.texture1 or "Blizzard")
					end,
					set = function(info, v)
						db.texture1 = LSM:List("statusbar")[v]
						db[k.."Dirty"] = true						
						createBars()
					end,
					order = 4
				},
				texture2 = {
					name = "Texture #2",
					desc = "The bar's second texture",
					type = "select",
					values = LSM:List("statusbar"),
					get = function()
						return db.texture2 or db.texture1 or "Blizzard" 
					end,
					set = function(info, v) 
						db.texture2 = LSM:List("statusbar")[v] 
						db[k.."Dirty"] = true						
						createBars() end,
					order = 5
				},
				point = {
					name = "Anchor Points",
					desc = "This bar's anchor point. These arguments are passed to bar:SetPoint()",
					type = "input",
					get = function() return db.point end,
					set = function(info, v) 
						db.point = v; 
						db[k.."Dirty"] = true						
						createBars() 
					end,
					order = 6
				},
				top = {
					name = "First is Top",
					desc = "Toggle whether to place the first bar on top",
					type = "toggle",
					get = function() return db.top end,
					set = function(info, v) 
						db.top = v; 
						db[k.."Dirty"] = true						
						createBars() 
					end,
					order = 7
				},
				expression = {
					name = "Bar expression",
					desc = "Enter the bar's first expression",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.expression end,
					set = function(info, v) 
						db.expression = v; 
						db[k.."Dirty"] = true
						createBars() 
					end,
					order = 8
				},
				expression2 = {
					name = "Bar second expression",
					desc = "Enter the bar's second expression",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.expression2 end,
					set = function(info, v) 
						db.expression2 = v ; 
						db[k.."Dirty"] = true
						createBars()
					end,
					order = 9
				},
				min = {
					name = "Bar min expression",
					desc = "Enter the bar's minimum expression",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.min end,
					set = function(info, v) 
						db.min = v; 
						db[k.."Dirty"] = true
						createBars() 
					end,
					order = 10
				
				},
				max = {
					name = "Bar max expression",
					desc = "Enter the bar's maximum expression",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.max end,
					set = function(info, v) 
						db.max = v; 
						db[k.."Dirty"] = true
						createBars() 
					end,
					order = 11
				},
				color1 = {
					name = "First bar color script",
					desc = "Enter the bar's first color script",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.color1 end,
					set = function(info, v) 
						db.color1 = v; 
						db[k.."Dirty"] = true
					createBars() end,
					order = 12
				},
				color2 = {
					name = "Second bar color script",
					desc = "Enter the bar's second color script",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.color2 end,
					set = function(info, v) 
						db.color2 = v; 
						db[k.."Dirty"] = true
						createBars() 
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
function mod:UpdateBar()
	local unit = "mouseover"
	if not UnitExists(unit) then return end
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	self.hpBar:SetMinMaxValues(0, max)
	self.hpBar:SetValue(min)

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
	self.hpBar:SetStatusBarColor(color.r, color.g, color.b)
	StarTip.del(color)
end
]]
-- Logic snagged from oUF 
--[[
function mod:UpdateHealth()
	local unit = "mouseover"
	if not UnitExists(unit) then return end
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	self.hpBar:SetMinMaxValues(0, max)
	self.hpBar:SetValue(min)

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
	self.hpBar:SetStatusBarColor(color.r, color.g, color.b)
	StarTip.del(color)
end

function mod:UpdateMana()
	local unit = "mouseover"
	if not UnitExists(unit) then return end
	local min, max = UnitMana(unit), UnitManaMax(unit)
	self.mpBar:SetMinMaxValues(0, max)
	self.mpBar:SetValue(min)

	local color = power[UnitPowerType(unit)]
	self.mpBar:SetStatusBarColor(color.r, color.g, color.b)
end
]]