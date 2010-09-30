local mod = StarTip:NewModule("RaidIcon", "AceEvent-3.0")
mod.name = "RaidIcon"
mod.toggled = true
local _G = _G
local GameTooltip = _G.GameTooltip
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local SetRaidTargetIconTexture = _G.SetRaidTargetIconTexture
local self = mod

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	local frame = CreateFrame("Frame", nil, GameTooltip)
	local icon = frame:CreateTexture(nil, "OVERLAY")
	icon:SetHeight(16)
    icon:SetWidth(16)
    icon:SetPoint("TOP", GameTooltip, 0, 4)
    icon:SetTexture"Interface\\TargetingFrame\\UI-RaidTargetingIcons"
	icon:Hide()
	self.icon = icon
end

function mod:OnEnable()
	self:RegisterEvent("RAID_TARGET_UPDATE")
end

function mod:OnDisable()
	self:UnregisterEvent("RAID_TARGET_UPDATE")
end

function mod:SetUnit()
	self:RAID_TARGET_UPDATE()
end

function mod:OnHide()
	if self.icon:IsShown() then self.icon:Hide() end
end

function mod:RAID_TARGET_UPDATE(event)
	local index = _G.GetRaidTargetIndex("mouseover")

	if(index) then
		_G.SetRaidTargetIconTexture(self.icon, index)
		self.icon:Show()
	else
		self.icon:Hide()
	end
end

