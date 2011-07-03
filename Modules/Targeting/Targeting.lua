local mod = StarTip:NewModule("Targeting", "AceEvent-3.0")
mod.name = "Targeting"
mod.toggled = true
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
	if UnitInRaid("player") or UnitInParty("player") and UnitExists(StarTip.unit) then
		local txt = ''
		local guid = UnitGUID(StarTip.unit)
		for i=1, GetNumRaidMembers() do
			if guid == UnitGUID("raid" .. i .. "target") then
				local c = RAID_CLASS_COLORS[select(2, UnitClass("raid" .. i))] 
				local name = UnitName("raid" .. i)
				txt = txt .. ("|cFF%02x%02x%02x%s|r "):format(c.r*255, c.g*255, c.b*255, name)
			end
			if guid == UnitGUID("raid" .. i .. "pettarget") then
				local c = RAID_CLASS_COLORS[select(2, UnitClass("raid" .. i))]
				local name = UnitName("raid"..i.."pet")
				txt = txt .. ("|cFF%02x%02x%02x%s (pet)|r "):format(c.r*255, c.g*255, c.b*255, name)
			end
		end
		if not UnitInRaid("player") then
			for i = 1, GetNumPartyMembers() do
				if UnitGUID(StarTip.unit) == UnitGUID("party" .. i .. "target") then
					local c = RAID_CLASS_COLORS[select(2, UnitClass("party" .. i))]
					local name = UnitName("party" .. i)
					txt = txt .. ("|cFF%02x%02x%02x%s|r "):format(c.r*255, c.g*255, c.b*255, name)
				end
				if UnitGUID(StarTip.unit) == UnitGUID("party" .. i .. "pettarget") then
					local c = RAID_CLASS_COLORS[select(2, UnitClass("party" .. i))]
					local name = UnitName("party" .. i .. "pettarget")
					txt = txt .. ("|cFF%02x%02x%02x%s (pet)|r "):format(c.r*255, c.g*255, c.b*255, name)
				end
			end
		end
		if txt ~= '' then
			GameTooltip:AddLine("Targeting: " .. txt, .5, .5, 1, 1)
		end
	end
end

