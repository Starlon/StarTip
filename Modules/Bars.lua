local mod = StarTip:NewModule("Bars", "AceTimer-3.0")
mod.name = "Bars"
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
local LSM = _G.LibStub("LibSharedMedia-3.0")

local defaults = {
	profile = {
		showHP = true,
		showMP = true,
		hpTexture = StarTip:GetLSMIndexByName("statusbar", LSM:GetDefault("statusbar")),
		mpTexture = StarTip:GetLSMIndexByName("statusbar", LSM:GetDefault("statusbar")),
		useGradient = false,
	}
}

local options = {
	hpBar = {
		name = "HP Bar",
		type = "group",
		args = {
			show = {
				name = "Show",
				desc = "Toggle showing the HP bar",
				type = "toggle",
				get = function() return self.db.profile.showHP end,
				set = function(info, v) self.db.profile.showHP = v end,
				order = 1
			},
			useGradient = {
				name = "Use Gradient",
				desc = "Set whether to use a gradient based on unit health",
				type = "toggle",
				get = function() return self.db.profile.useGradient end,
				set = function(info, v) self.db.profile.useGradient = v end,
				order = 3
			},
			texture = {
				name = "Texture",
				desc = "Change the status bar's texture",
				type = "select",
				values = LSM:List("statusbar"),
				get = function() return self.db.profile.hpTexture end,
				set = function(info, v) 
					self.db.profile.hpTexture = v 
					self.hpBar:SetStatusBarTexture(LSM:Fetch("statusbar", LSM:List("statusbar")[v]))
				end,
				order = 2
			},
		}
	},
	mpBar = {
		name = "MP Bar",
		type = "group",
		args = {
			show = {
				name = "Show",
				desc = "Toggle showing the MP bar",
			type = "toggle",
				get = function() return self.db.profile.showMP end,
				set = function(info, v) self.db.profile.showMP = v end,
				order = 1
			},
			texture = {
				name = "Texture",
				desc = "Change the status bar's texture",
				type = "select",
				values = LSM:List("statusbar"),
				get = function() return self.db.profile.mpTexture end,
				set = function(info, v) 
					self.db.profile.mpTexture = v 
					self.mpBar:SetStatusBarTexture(LSM:Fetch("statusbar", LSM:List("statusbar")[v]))
				end,
				order = 2
			}
		}
	}
}


function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	
	local hpBar = CreateFrame("StatusBar", nil, GameTooltip)
	hpBar:SetStatusBarTexture(LSM:Fetch("statusbar", LSM:List("statusbar")[self.db.profile.hpTexture]))
	hpBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT")
	hpBar:SetPoint("LEFT", GameTooltip, "LEFT")
	hpBar:SetPoint("RIGHT", GameTooltip, "RIGHT")
	hpBar:SetHeight(5)
	hpBar:Hide()
	self.hpBar = hpBar
	
	local mpBar = CreateFrame("StatusBar", nil, GameTooltip)
	mpBar:SetStatusBarTexture(LSM:Fetch("statusbar", LSM:List("statusbar")[self.db.profile.mpTexture]))
	mpBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT")
	mpBar:SetPoint("LEFT")
	mpBar:SetPoint("RIGHT")	
	mpBar:SetHeight(5)
	mpBar:Hide()
	self.mpBar = mpBar
	
	StarTip:SetOptionsDisabled(options, true)
end

function mod:OnEnable()
	local top, bottom = 0, 0
	if self.db.profile.showHP then
		top = 5
	end
	if self.db.profile.showMP then
		bottom = -5
	end
	GameTooltip:SetClampRectInsets(0, 0, top, bottom)
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	GameTooltip:SetClampRectInsets(0, 0, 0, 0)
	StarTip:SetOptionsDisabled(options, true)
end

function mod:GetOptions()
	return options
end

local function updateBars()
	if self.db.profile.showHP then self:UpdateHealth() end
	if self.db.profile.showMP then self:UpdateMana() end
end

function mod:SetUnit()
	GameTooltipStatusBar:Hide()
	updateBars()
	if self.db.profile.showHP then self.hpBar:Show() end
	if self.db.profile.showMP then self.mpBar:Show() end
	timer = timer or self:ScheduleRepeatingTimer(updateBars, .5)
end

function mod:SetItem()
	self.hpBar:Hide()
	self.mpBar:Hide()
end

function mod:SetSpell()
	self.hpBar:Hide()
	self.mpBar:Hide()
end

function mod:OnHide()
	if timer then
		self:CancelTimer(timer)
		timer = nil
	end
	self.hpBar:Hide()
	self.mpBar:Hide()
end

local function colorGradient(perc)
    if perc <= 0.5 then
        return 1, perc*2, 0
    else
        return 2 - perc*2, 1, 0
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

-- Logic snagged from oUF 
function mod:UpdateHealth()
	local unit = "mouseover"
	if not UnitExists(unit) then return end
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	self.hpBar:SetMinMaxValues(0, max)
	self.hpBar:SetValue(min)

	local color
	if self.db.profile.useGradient then
		color = {}
		color.r, color.g, color.b = colorGradient(min/max)
	elseif(UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit)) then
		color = health[1]
	elseif UnitIsPlayer(unit) then 
		color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
	else
		color = {}
		color.r, color.g, color.b = UnitSelectionColor(unit)
	end
	if not color then color = health[0] end
	self.hpBar:SetStatusBarColor(color.r, color.g, color.b)
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
