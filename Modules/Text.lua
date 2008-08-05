local mod = StarTip:NewModule("Text", "AceTimer-3.0", "AceEvent-3.0")
mod.name = "Text"
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local self = mod
local GameTooltip = _G.GameTooltip
local tinsert = _G.tinsert
local unpack = _G.unpack
local select = _G.select
local format = _G.format
local floor = _G.floor
local tostring = _G.tostring
local UnitExists = _G.UnitExists
local UnitIsPlayer = _G.UnitIsPlayer
local UnitBuff = _G.UnitBuff
local GetSpellInfo = _G.GetSpellInfo
local UnitIsConnected = _G.UnitIsConnected
local UnitIsFeignDeath = _G.UnitIsFeignDeath
local UnitIsGhost = _G.UnitIsGhost
local UnitIsDead = _G.UnitIsDead
local UnitLevel = _G.UnitLevel
local UnitClassification = _G.UnitClassification
local UnitReaction = _G.UnitReaction
local UnitReactionColor = _G.UnitReactionColor
local UnitRace = _G.UnitRace
local GetNumTalentTabs = _G.GetNumTalentTabs
local GetTalentTabInfo = _G.GetTalentTabInfo
local GetGuildInfo = _G.GetGuildInfo
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local UnitMana = _G.UnitMana
local UnitManaMax = _G.UnitManaMax
local UnitFactionGroup = _G.UnitFactionGroup
local UnitCreatureFamily = _G.UnitCreatureFamily
local UnitCreatureType = _G.UnitCreatureType
local UnitIsUnit = _G.UnitIsUnit
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local timer, talentTimer
local TalentQuery = LibStub:GetLibrary("LibTalentQuery-1.0", true)
local TalentGuess = LibStub:GetLibrary("TalentGuess-1.0", true) and LibStub:GetLibrary("TalentGuess-1.0"):Register()
local LibMobHealth = LibStub:GetLibrary("LibMobHealth-4.0")
local spec = setmetatable({}, {__mode='v'})
local factionList = {}
local linesToAdd = {}
local linesToAddR = {}
local linesToAddG = {}
local linesToAddB = {}
local linesToAddRight = {}
local linesToAddRightR = {}
local linesToAddRightG = {}
local linesToAddRightB = {}
local unitLocation
local unitName
local unitGuild
local NUM_LINES

-- Thanks to ckknight for this
local short = function(value)
	if value >= 10000000 or value <= -10000000 then
		value = ("%.1fm"):format(value / 1000000)
	elseif value >= 1000000 or value <= -1000000 then
		value = ("%.2fm"):format(value / 1000000)
	elseif value >= 100000 or value <= -100000 then
		value = ("%.0fk"):format(value / 1000)
	elseif value >= 10000 or value <= -10000 then
		value = ("%.1fk"):format(value / 1000)
	else
		value = tostring(floor(value+0.5))
	end
	return value
end

local classifications = {
	worldboss = "Boss",
	rareelite = "+ Rare",
	elite = "+",
	rare = "Rare"
}

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

local powers = {
	["WARRIOR"] = "Rage:",
	["ROGUE"] = "Energy:",
}

powers = setmetatable(powers, {__index=function(self,key)
	if type(key) == nil then return nil end
	if rawget(self,key) then
		return self[key]
	else
		return "Mana:"
	end
end})

local updateTalents = function()
	if not UnitExists("mouseover") then 
		self:CancelTimer(talentTimer)
		talentTimer = nil
		return 
	end
	local nameRealm = select(1, UnitName("mouseover")) .. (select(2, UnitName("mouseover")) or '')
	if spec[nameRealm] and spec[nameRealm][4] and spec[nameRealm][1] and spec[nameRealm][2] and spec[nameRealm][3] then
		local specText = ('%s (%d/%d/%d)'):format(spec[nameRealm][4], spec[nameRealm][1], spec[nameRealm][2], spec[nameRealm][3])
		local lineNum
		if NUM_LINES < GameTooltip:NumLines() then
			lineNum = NUM_LINES + 1
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
		local replaced
		for i = 1, GameTooltip:NumLines() do
			if mod.leftLines[i]:GetText() == "Talents Guessed:" then
				lineNum = i
				replaced = true
			end
		end
		if not replaced then
			GameTooltip:AddDoubleLine(' ', ' ')
		end
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
		GameTooltip:Show()
	elseif spec[nameRealm] then
		for k in pairs(spec[nameRealm]) do
			spec[nameRealm][k] = nil
		end
		spec[nameRealm] = nil
	end
end

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
		for tab = 1, GetNumTalentTabs(isnotplayer) do
			local treename, _, pointsspent = GetTalentTabInfo(tab, isnotplayer)
			highPoints[tab] = pointsspent
			spec[nameRealm][tab] = pointsspent
			specNames[tab] = treename
		end
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

local unitHasAura = function(aura)
	local i = 1
	while true do
		local buff = UnitBuff("mouseover", i, true)
		if not buff then return end
		if buff == aura then return true end
		i = i + 1
	end
end

local options = {
	titles = {
		name = "Titles",
		desc = "Toggle whether to show titles or not",
		type = "toggle",
		set = function(info, v) self.db.profile.titles = v end,
		get = function() return self.db.profile.titles end,
		order = 5	
	},
}

local lines = setmetatable({
	[1] = {
		db = "Name:",
		name = "UnitName",
		left = function()
			local c = UnitIsPlayer("mouseover") and RAID_CLASS_COLORS[select(2, UnitClass("mouseover"))] or UnitReactionColor[UnitReaction("mouseover", "player")]
			return unitName, c
		end,
		right = nil,
		updating = false
	},
	[2] = {
		db = "Target:",
		name = "Target",
		left = function() return "Target:" end,
		right = function()
			if UnitExists("mouseovertarget") then
				local c = UnitIsPlayer("mouseovertarget") and RAID_CLASS_COLORS[select(2, UnitClass("mouseovertarget"))] or UnitReactionColor[UnitReaction("mouseovertarget", "player")]
				local name = UnitName("mouseovertarget")
				return name, c
			else
				return "None", {r=1, g=1, b=1}
			end
		end,
		updating = true
	},
	[3] = {
		db = "Guild:",
		name = "Guild",
		left = function() return "Guild:" end,
		right = function()
			local guild = GetGuildInfo("mouseover")
			if guild then return guild else return unitGuild end
		end,
		updating = false
	},
	[4] = {
		db = "Rank:",
		name = "Rank",
		left = function() return "Rank:" end,
		right =  function()
			return select(2, GetGuildInfo("mouseover"))
		end,	
		updating = false
	},
	[5] = {
		db = "Realm:",
		name = "Realm",
		left = function() return "Realm:" end,
		right = function()
			return select(2, UnitName("mouseover"))
		end,
		updating = false
	},
	[6] = {
		db = "Level:",
		name = "Level",
		left = function() return "Level:" end,
		right = function()
			local lvl = UnitLevel("mouseover")
			local class = UnitClassification("mouseover")
    
			if lvl <= 0 then 
				lvl = ''
			end

			if classifications[class] then
				lvl = lvl .. classifications[class]
			end

			return lvl
		end,
		updating = false
	},
	[7] = {
		db = "Race:",
		name = "Race",
		left = function() return "Race:" end,
		right = function()
			local race
			if UnitIsPlayer("mouseover") then
				race = UnitRace("mouseover");
			else
				race = UnitCreatureFamily("mouseover") or UnitCreatureType("mouseover")
			end
			return race		
		end,
		updating = false
	},
	[8] = {
		db = "Class:",
		name = "Class",
		left = function() return "Class:" end,
		right = function()
			local class = UnitClass("mouseover")
			if class == UnitName("mouseover") then return end
			local c = UnitIsPlayer("mouseover") and RAID_CLASS_COLORS[select(2, UnitClass("mouseover"))]
			return class, c
		end,
		updating = false
	},
	[9] = {
		db = "Faction:",
		name = "Faction",
		left = function() return "Faction:" end,
		right = function()
			return UnitFactionGroup("mouseover")
		end,
		updating = false
	},
	[10] = {
		db = "Status:",
		name = "Status",
		left = function() return "Status:" end,
		right = function()
			if not UnitIsConnected("mouseover") then
				return "Offline"
			elseif unitHasAura(GetSpellInfo(19752)) then
				return "Divine Intervention"
			elseif UnitIsFeignDeath("mouseover") then
				return "Feigned Death"
			elseif UnitIsGhost("mouseover") then
				return "Ghost"
			elseif UnitIsDead("mouseover") and  unitHasAura(GetSpellInfo(20707)) then
				return "Soulstoned"
			elseif UnitIsDead("mouseover") then
				return "Dead"
			end
		end,
		updating = true
	},
	[11] = {
		db = "Health:",
		name = "Health",
		left = function() return "Health:" end,
		right = function()
			local health, maxHealth = LibMobHealth:GetUnitHealth("mouseover")	
			local value
			if maxHealth == 100 then 
				value = health .. "%"
			elseif maxHealth ~= 0 then
				value = format("%s/%s (%d%%)", short(health), short(maxHealth), health/maxHealth*100)
			end
			return value
		end,
		updating = true
	},
	[12] = {
		db = "Mana:",
		name = "Mana",
		left = function()
			local class = select(2, UnitClass("mouseover"))
			return powers[class]
		end,
		right = function()
			local mana = UnitMana("mouseover")
			local maxMana = UnitManaMax("mouseover")
			local value
			if maxMana == 100 then
				value = mana
			elseif maxMana ~= 0 then
				value = format("%s/%s (%d%%)", short(mana), short(maxMana), mana/maxMana*100)
			end
			return value		
		end,
		updating = true
	},
	[13] = {
		db = "Location:",
		name = "Location",
		left = function() return "Location:" end,
		right = function()
			return unitLocation
		end,
		updating = true
	},
	[14] = {
		db = "Talents:",
		name = "Talents",
		left = function() return "Talents:" end,
		right = function()
			local name = UnitName("mouseover")
			if TalentQuery and UnitIsUnit("mouseover", "player") then
				mod:TalentQuery_Ready(_, name)
			elseif TalentQuery and UnitExists("mouseover") and UnitIsPlayer("mouseover") then
				TalentQuery:Query("mouseover")
				talentTimer = talentTimer or self:ScheduleRepeatingTimer(updateTalents, 0)
			end
		end,
		updating = false
	},
	[15] = {
		db = "TalentsGuessed:",
		name = "Talents Guesssed",
		left = function() return "Talents Guessed:" end,
		right = function()
			local name, realm = UnitName("mouseover")
			local nameRealm
			if realm then
				nameRealm = name .. '-' .. realm
			else
				nameRealm = name
			end
			local specText
			if nameRealm and TalentGuess and TalentGuess:GetTalents(nameRealm) then
				local talents = {}
				local high = 1
				talents[1], talents[2], talents[3] = TalentGuess:GetTalents(nameRealm)
				for i = 2, 3 do
					if talents[i] > talents[high] then
						high = i
					end
				end
				local class = UnitClass("mouseover")
				specText = ("%s (%d/%d/%d)"):format(talentTrees[class][high], talents[1], talents[2], talents[3])
			end
			return specText
		end,
		updating = true
	}
}, {__call=function(this)
	local lineNum = 0
	for i, v in ipairs(this) do
		if self.db.profile[v.db] then
			local left, right, c
			if v.right then 
				right, c = v.right() 
				left = v.left()
			else 
				right = ''
				left, c = v.left()
			end
			if left and right then 
				lineNum = lineNum + 1
				if v.right then
					GameTooltip:AddDoubleLine(' ', ' ', 1, 1, 1, 1, 1, 1)
					mod.leftLines[lineNum]:SetText(left)
					mod.rightLines[lineNum]:SetText(right)
					if type(c) == "table" and c.r then
						mod.rightLines[lineNum]:SetVertexColor(c.r, c.g, c.b)
					end
				else
					GameTooltip:AddLine(' ', 1, 1, 1)
					mod.leftLines[lineNum]:SetText(left)
					if type(c) == "table" and c.r then
						mod.leftLines[lineNum]:SetVertexColor(c.r, c.g, c.b)
					end
				end
			end
		end
	end
	NUM_LINES = lineNum
end})

local function updateLines()
	if not UnitExists("mouseover") then
		mod:CancelTimer(timer)
		timer = nil
		return
	end
	for _, v in ipairs(lines) do
		if v.updating and v.right and self.db.profile[v.db] then
			local left = v.left()
			local right, c = v.right()
			if left and right then
				for i = 1, NUM_LINES do
					if mod.leftLines[i]:GetText() == left then
						mod.rightLines[i]:SetText(right)
						if type(c) == "table" and c.r then
							mod.rightLines[i]:SetVertexColor(c.r, c.g, c.b)
						end
					end
				end
			end
		end
	end
end

local defaults = {profile={titles=true}}

do
	local lnum = 1
	for i, v in ipairs(lines) do
		options[v.db] = {
			name = v.name,
			desc = "Toggle showing this line",
			type = "toggle",
			set = function(info, val) self.db.profile[v.db] = val end,
			get = function() return self.db.profile[v.db] end,
			order = 5 + lnum
		}
		lnum = lnum + 1
		defaults.profile[v.db] = true
	end
end

function mod:OnInitialize()	
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	self.leftLines = StarTip.leftLines
	self.rightLines = StarTip.rightLines
	self:RegisterEvent("UPDATE_FACTION")
	StarTip:SetOptionsDisabled(options, true)
end

function mod:OnEnable()
	local i = 1
	while true do
		if not self.db.profile[i] then break end
		lines[i] = self.db.profile[i]
		i = i + 1
	end
	if TalentQuery then TalentQuery.RegisterCallback(self, "TalentQuery_Ready") end
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	if TalentQuery then TalentQuery.UnregisterCallback(self, "TalentQuery_Ready") end
	StarTip:SetOptionsDisabled(options, true)
end

function mod:GetOptions()
	return options
end

function mod:UPDATE_FACTION()
	for i = 1, GetNumFactions() do
		local name = GetFactionInfo(i)
		factionList[name] = true
	end
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
	unitName = getName()
	unitLocation = getLocation()
	unitGuild = getGuild()
	
	-- Taken from CowTip
	local lastLine = 2
	local text2 = self.leftLines[2]:GetText()
	
	if not text2 then
		lastLine = lastLine - 1
	elseif not text2:find("^"..LEVEL) then
		lastLine = lastLine + 1
	end
	if not UnitPlayerControlled("mouseover") and not UnitIsPlayer("mouseover") then
		local factionText = self.leftLines[lastLine + 1]:GetText()
		if factionText == PVP then
			factionText = nil
		end
		if factionText and (factionList[factionText] or UnitFactionGroup("mouseover")) then
			lastLine = lastLine + 1
		end
	end
	if not UnitIsConnected("mouseover") or not UnitIsVisible("mouseover") or UnitIsPVP("mouseover") then
		lastLine = lastLine + 1
	end

	lastLine = lastLine + 1
	
	for i = lastLine, GameTooltip:NumLines() do
		local left = self.leftLines[i]
		local j = i - lastLine + 1
		linesToAdd[j] = left:GetText()
		local r, g, b = left:GetTextColor()
		linesToAddR[j] = r
		linesToAddG[j] = g
		linesToAddB[j] = b
		local right = self.rightLines[i]
		if right:IsShown() then
			linesToAddRight[j] = right:GetText()
			local r, g, b = right:GetTextColor()
			linesToAddRightR[j] = r
			linesToAddRightG[j] = g
			linesToAddRightB[j] = b
		end
	end
	-- End
	
	GameTooltip:ClearLines()

	lines()
	
	-- Another part taken from CowTip
	for i, left in ipairs(linesToAdd) do
		local right = linesToAddRight[i]
		if right then
			GameTooltip:AddDoubleLine(left, right, linesToAddR[i], linesToAddG[i], linesToAddB[i], linesToAddRightR[i], linesToAddRightG[i], linesToAddRightB[i])
		else
			GameTooltip:AddLine(left, linesToAddR[i], linesToAddG[i], linesToAddB[i], true)
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
	-- End
	
	timer = timer or self:ScheduleRepeatingTimer(updateLines, .5)
end
