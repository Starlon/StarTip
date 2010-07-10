local mod = StarTip:NewModule("PvP", "AceEvent-3.0")
mod.name = "PvP"
local _G = _G
local GameTooltip = _G.GameTooltip
local UnitFactionGroup = _G.UnitFactionGroup
local self = mod

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	local frame = _G.CreateFrame("Frame", nil, GameTooltip)
	local pvp = frame:CreateTexture(nil, "OVERLAY")
	pvp:SetHeight(30)
	pvp:SetWidth(30)
	pvp:SetPoint("TOPRIGHT", GameTooltip, 20, 10)
	pvp:Hide()
	self.PvP = pvp
end

function mod:OnEnable()
	self:RegisterEvent("UNIT_FACTION")
end

function mod:OnDisable()
	self:UnregisterEvent("UNIT_FACTION")
end

function mod:UNIT_FACTION(event, unit)
	if unit ~= "mouseover" then return end

	local factionGroup = UnitFactionGroup(unit)
	if(UnitIsPVPFreeForAll(unit)) then
		self.PvP:SetTexture[[Interface\TargetingFrame\UI-PVP-FFA]]
		self.PvP:Show()
	elseif(factionGroup and UnitIsPVP(unit)) then
		self.PvP:SetTexture([[Interface\TargetingFrame\UI-PVP-]]..factionGroup)
		self.PvP:Show()
	else
		self.PvP:Hide()
	end
end

function mod:SetUnit()
	self:UNIT_FACTION(nil, "mouseover")
end

function mod:OnHide()
	self.PvP:Hide()
end
