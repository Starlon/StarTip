local mod = StarTip:NewModule("Targeting", "AceEvent-3.0")
mod.name = "Targeting"
local _G = _G
local GameTooltip = _G.GameTooltip
local UnitFactionGroup = _G.UnitFactionGroup
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local StarTip = _G.StarTip
local self = mod

function mod:OnInitialize()
end

function mod:OnEnable()
end

function mod:OnDisable()
end

function mod:SetUnit()
	if UnitInRaid("player") then
		local txt = ''
		for i=1, GetNumRaidMembers() do
			if UnitExists("mouseover") and UnitGUID("mouseover") == UnitGUID("raid" .. i .. "target") then
				local c = RAID_CLASS_COLORS[select(2, UnitClass("raid" .. i))] 
				local name = UnitName("raid" .. i)
				txt = txt .. ("|cFF%02x%02x%02x%s|r "):format(c.r*255, c.g*255, c.b*255, name)
			end
		end
		if txt ~= '' then
			GameTooltip:AddLine("Targeting: " .. txt, .5, .5, 1, 1)
		end
	end
end

