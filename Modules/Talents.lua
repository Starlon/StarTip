--do return end

local mod = StarTip:NewModule("Talents", "AceTimer-3.0", "AceEvent-3.0")
local text = StarTip:GetModule("Text")
mod.name = "Talents"
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local self = mod
local GameTooltip = _G.GameTooltip
local UnitIsUnit = _G.UnitIsUnit
local GetNumTalentTabs = _G.GetNumTalentTabs
local GetTalentTabInfo = _G.GetTalentTabInfo
local UnitExists = _G.UnitExists
local UnitIsPlayer = _G.UnitIsPlayer
local unitLocation
local unitName
local unitGuild
local expired
local expireTimer
local EXPIRE_TIME = 1
local linesToAdd = {}
local linesToAddR = {}
local linesToAddG = {}
local linesToAddB = {}
local linesToAddRight = {}
local linesToAddRightR = {}
local linesToAddRightG = {}
local linesToAddRightB = {}
local TalentQuery = LibStub:GetLibrary("LibTalentQuery-1.0", true)
local spec = setmetatable({}, {__mode='v'})
local timer, talentTimer

local talentTrees = {
	["Druid"] = {"Balance", "Feral Combat", "Restoration"},
	["Hunter"] = {"Beast Mastery", "Marksmanship", "Survival"},
	["Mage"] = {"Arcane", "Fire", "Frost"},
	["Paladin"] = {"Holy", "Protection", "Retribution"},
	["Priest"] = {"Discipline", "Holy", "Shadow"},
	["Rogue"] = {"Assassination", "Combat", "Subtlety"},
	["Shaman"] = {"Elemental", "Enhancement", "Restoration"},
	["Warlock"] = {"Affliction", "Demonology", "Destruction"},
	["Warrior"] = {"Arms", "Fury", "Protection"},
}

local indexOf = function(t, val)
	for i=1, #t do
		if t[i] == val then
			return i
		end
	end
end

local indicesOf = function(t, val)
	local a = {}
	for i=1, #t do
		if t[i] == val then
			tinsert(a, i)
		end
	end
	return unpack(a)
end

function mod:TalentQuery_Ready(e, name, realm)
	if not TalentQuery then return end
	local nameRealm = name .. (realm or '')
	local isnotplayer = (name ~= UnitName("player"))
	if not spec[nameRealm] then		
		spec[nameRealm] = {[4]=NONE}
		local highPoints = {}
		local specNames = {}
		local group = GetActiveTalentGroup(true)
		for tab = 1, GetNumTalentTabs(isnotplayer) do
			local treename, _, pointsspent = GetTalentTabInfo(tab, isnotplayer, nil, group)
			highPoints[tab] = pointsspent
			spec[nameRealm][tab] = pointsspent
			specNames[tab] = treename
		end
		if highPoints[1] == nil or highPoints[2] == nil or highPoints[3] == nil then spec[nameRealm] = nil return end
		table.sort(highPoints, function(a,b) return a>b end)
		local first, second = select(1, indicesOf(spec[nameRealm], highPoints[1])), select(2, indicesOf(spec[nameRealm], highPoints[1]))
		if highPoints[1] > 0 and highPoints[2] > 0 and highPoints[1] - highPoints[2] <= 5 and highPoints[1] ~= highPoints[2] then
			spec[nameRealm][4] = specNames[indexOf(spec[nameRealm], highPoints[1])] .. "/" .. specNames[indexOf(spec[nameRealm], highPoints[2])]
		elseif highPoints[1] > 0 and first and second then
			spec[nameRealm][4] = specNames[first] .. "/" .. specNames[second] 
		elseif highPoints[1] > 0 then
			spec[nameRealm][4] = specNames[indexOf(spec[nameRealm], highPoints[1])]
		end
	end
end

function expireQuery()
	expired = true
	self:CancelTimer(expireTimer)
	expireTimer = nil
end

local updateTalents = function()
	if not UnitExists("mouseover") or not UnitIsPlayer("mouseover") then 
		self:CancelTimer(talentTimer)
		self:CancelTimer(expireTimer)
		expireTimer = nil
		talentTimer = nil
		return 
	end
	if expired then
		TalentQuery:NotifyInspect("player")
		TalentQuery.frame:Hide()
		TalentQuery:Query("mouseover")
		expireTimer = self:ScheduleTimer(expireQuery, EXPIRE_TIME)	
		expired = nil
		return
	end	
	local nameRealm = select(1, UnitName("mouseover")) .. (select(2, UnitName("mouseover")) or '')
	if spec[nameRealm] and spec[nameRealm][4] and spec[nameRealm][1] and spec[nameRealm][2] and spec[nameRealm][3] then
		local specText = ('%s (%d/%d/%d)'):format(spec[nameRealm][4], spec[nameRealm][1], spec[nameRealm][2], spec[nameRealm][3])
		local lineNum
		if text.NUM_LINES < GameTooltip:NumLines() then
			lineNum = text.NUM_LINES + 1
			local j = 0
			for i = lineNum, GameTooltip:NumLines() do
				local left = mod.leftLines[i]
				j = j + 1
				linesToAdd[j] = left:GetText()
				local r, g, b = left:GetTextColor()
				linesToAddR[j] = r
				linesToAddG[j] = g
				linesToAddB[j] = b
				local right = mod.rightLines[i]
				if right:IsShown() then
					linesToAddRight[j] = right:GetText()
					local r, g, b = right:GetTextColor()
					linesToAddRightR[j] = r
					linesToAddRightG[j] = g
					linesToAddRightB[j] = b 
				end
			end
		else
			lineNum = GameTooltip:NumLines() + 1
		end
		GameTooltip:AddDoubleLine(' ', ' ')
		local left = mod.leftLines[lineNum]
		local right = mod.rightLines[lineNum]
		left:SetText("Talents:")
		right:SetText(specText)
		if not right:IsShown() then
			right:Show()
		end
		left:SetTextColor(1, 1, 1)
		right:SetTextColor(1, 1, 1)
		
		for i=1, #linesToAdd do
			local left = mod.leftLines[i + lineNum]
			left:SetText(linesToAdd[i])
			left:SetTextColor(linesToAddR[i], linesToAddG[i], linesToAddB[i])
			if linesToAddRight[i] then
				local right = mod.rightLines[i + lineNum]
				right:SetText(linesToAddRight[i])
				right:SetTextColor(linesToAddRightR[i], linesToAddRightG[i], linesToAddRightB[i])
			end
			linesToAdd[i] = nil
			linesToAddR[i] = nil
			linesToAddG[i] = nil
			linesToAddB[i] = nil
			linesToAddRight[i] = nil
			linesToAddRightR[i] = nil
			linesToAddRightG[i] = nil
			linesToAddRightB[i] = nil
		end

		self:CancelTimer(talentTimer)
		talentTimer =  nil
		if expireTimer then
			mod:CancelTimer(expireTimer)
			expireTimer = nil
		end
		if spec[nameRealm][1] == 0 and spec[nameRealm][2] == 0 and spec[nameRealm][3] == 0 then
			spec[nameRealm] = nil
		end
		GameTooltip:Hide()
		GameTooltip:Show()
	elseif spec[nameRealm] then
		spec[nameRealm] = nil
	end
end

function mod:OnInitialize()	
	self.leftLines = StarTip.leftLines
	self.rightLines = StarTip.rightLines
end

function mod:OnEnable()
	if TalentQuery then TalentQuery.RegisterCallback(self, "TalentQuery_Ready") end
end

function mod:OnDisable()
	if TalentQuery then TalentQuery.UnregisterCallback(self, "TalentQuery_Ready") end
end

local getName = function()
	if self.db.profile.titles then
		local name = self.leftLines[1]:GetText()
		if UnitIsPlayer("mouseover") and name:find(" %- ") then
			name = name:sub(1, name:find(" %- "))
		end
		return name
	else
		return UnitName("mouseover")
	end
end

-- Taken from LibDogTag-Unit-3.0
local LEVEL_start = "^" .. (type(LEVEL) == "string" and LEVEL or "Level")
local getLocation = function()
	if UnitIsVisible("mouseover") or not UnitIsConnected("mouseover") then
		return nil
	end
	
	local left_2 = self.leftLines[2]:GetText()
	local left_3 = self.leftLines[3]:GetText()
	if not left_2 or not left_3 then
		return nil
	end
	local hasGuild = not left_2:find(LEVEL_start)
	local factionText = not hasGuild and left_3 or self.leftLines[4]:GetText()
	if factionText == PVP then
		factionText = nil
	end
	local hasFaction = factionText and not UnitPlayerControlled("mouseover") and not UnitIsPlayer("mouseover") and (UnitFactionGroup("mouseover") or factionList[factionText])
	if hasGuild and hasFaction then
		return self.leftLines[5]:GetText()
	elseif hasGuild or hasFaction then
		return self.leftLines[4]:GetText()
	else
		return left_3
	end
end

local getGuild = function()
	local left_2 = self.leftLines[2]:GetText()
	if left_2:find(LEVEL_start) then return nil end
	return "<" .. left_2 .. ">"
end

function mod:SetUnit()
	if not TalentQuery or not UnitIsPlayer("mouseover") then return end
	if UnitIsUnit("mouseover", "player") then
		self:TalentQuery_Ready(_, UnitName("player"))
	else
		TalentQuery:NotifyInspect("mouseover")
		TalentQuery:Query("mouseover")
		talentTimer = talentTimer or self:ScheduleRepeatingTimer(updateTalents, 0)
		if expireTimer then
			self:CancelTimer(expireTimer)
			expireTimer = nil
		end
		expireTimer = self:ScheduleTimer(expireQuery, EXPIRE_TIME)
	end
end

function mod:OnHide()
	if talentTimer then
		self:CancelTimer(talentTimer)
		talentTimer = nil
	end
	if expireTimer then
		self:CancelTimer(expireTimer)
		expireTimer = nil
	end
end

