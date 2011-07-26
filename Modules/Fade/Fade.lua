local mod = StarTip:NewModule("Fade", "AceHook-3.0")
mod.name = "Fade"
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UnitExists = _G.UnitExists
local self = mod
local L = StarTip.L

local defaults = {
	profile = {
		unitFrames = 2,
		otherFrames = 1,
		units = 2,
		objects = 2,
	}
}

local choices = {
	"Hide",
	"Fade out"
}

local get = function(info)
	return self.db.profile[info[#info]]
end

local set = function(info, v)
	self.db.profile[info[#info]] = v
end

local options = {
	units = {
		name = L["World Units"],
		desc = L["What to do with tooltips for world frames"],
		type = "select",
		values = choices,
		get = get,
		set = set,
		order = 4
	},
	unitFrames = {
		name = L["Unit Frames"],
		desc = L["What to do with tooltips for unit frames"],
		type = "select",
		values = choices,
		get = get,
		set = set,
		order = 5
	},
	otherFrames = {
		name = L["Other Frames"],
		desc = L["What to do with tooltips for other frames (spells, macros, items, etc..)"],
		type = "select",
		values = choices,
		get = get,
		set = set,
		order = 6
	},
	objects = {
		name = L["World Objects"],
		desc = L["What to do with tooltips for world objects (mailboxes, portals, etc..)"],
		type = "select",
		values = choices,
		get = get,
		set = set,
		order = 7
	}
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	self:SecureHook("GameTooltip_SetDefaultAnchor")
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
end

function mod:GetOptions()
	return options
end

function mod:GameTooltip_SetDefaultAnchor(this, owner)
	if owner ~= UIParent and mod.isUnit then -- This is terrible. Fixes a bug, but it likely introduces another bug related to passing over unit frames. Didn't seem to bother anything in a BG test.
		StarTip.tooltipMain:Hide()
	end
end

-- CowTip's solution below
local updateExistenceFrame = CreateFrame("Frame")
local updateAlphaFrame = CreateFrame("Frame")

local checkExistence = function()
	if not UnitExists(StarTip.unit) and mod.isUnit then
		updateExistenceFrame:SetScript("OnUpdate", nil)
		local kind
		if GameTooltip:GetOwner() == UIParent then
			kind = self.db.profile.units
		else
			kind = self.db.profile.unitFrames
		end
		if kind == 2 then
			GameTooltip:FadeOut()
			StarTip.tooltipMain:FadeOut()
		else
			GameTooltip:Hide()
			StarTip.tooltipMain:Hide()
		end
	end
end

local checkTooltipAlpha = function()
	if GameTooltip:GetAlpha() < 1 then
		updateAlphaFrame:SetScript("OnUpdate", nil)
		local kind
		if GameTooltip:IsOwned(UIParent) then
			kind = self.db.profile.objects
		else
			kind = self.db.profile.otherFrames
		end
		if kind == 2 then
			GameTooltip:FadeOut()
			StarTip.tooltipMain:FadeOut()
		else
			GameTooltip:Hide()
			StarTip.tooltipMain:Hide()
		end
	end
end

function mod:OnShow()
	if self.isUnit and UnitExists(StarTip.unit) then
		updateExistenceFrame:SetScript("OnUpdate", checkExistence)
	else
		updateAlphaFrame:SetScript("OnUpdate", checkTooltipAlpha)
	end
end

function mod:OnFadeOut(this, ...)
	if self.justFade then
		self.justFade = nil
		return true
	end
	local kind
	if self.isUnit then
		if GameTooltip:IsOwned(UIParent) then
			kind = self.db.profile.units
		else
			kind = self.db.profile.unitFrames
		end
	else
		if GameTooltip:IsOwned(UIParent) then
			kind = self.db.profile.objects
		else
			kind = self.db.profile.otherFrames
		end
	end
	self.isUnit = false
	if kind == 2 then
		return true
	else
		self.justHide = true
		GameTooltip:Hide()
		StarTip.tooltipMain:Hide()
	end

end

function mod:GameTooltipHide(this, ...)
	if self.justHide then
		self.justHide = nil
		return true
	end
	local kind
	if self.isUnit then
		if GameTooltip:IsOwned(UIParent) then
			kind = self.db.profile.units
		else
			kind = self.db.profile.unitFrames
		end
	else
		if GameTooltip:IsOwned(UIParent) then
			kind = self.db.profile.objects
		else
			kind = self.db.profile.otherFrames
		end
	end
	self.isUnit = false
	if kind == 2 then
		self.justFade = true
		GameTooltip:FadeOut()
		StarTip.tooltipMain:FadeOut()
	else
		return true
	end
end

function mod:SetUnit()
	self.isUnit = true
	updateExistenceFrame:SetScript("OnUpdate", checkExistence)
end

function mod:SetItem()
	self.isUnit = false
	updateExistenceFrame:SetScript("OnUpdate", nil)
end

function mod:SetSpell()
	self.isUnit = false
	updateExistenceFrame:SetScript("OnUpdate", nil)
end
