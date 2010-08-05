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
local UnitSelectionColor = _G.UnitSelectionColor
local UnitRace = _G.UnitRace
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
local timer
local factionList = {}
local linesToAdd = {}
local linesToAddR = {}
local linesToAddG = {}
local linesToAddB = {}
local linesToAddRight = {}
local linesToAddRightR = {}
local linesToAddRightG = {}
local linesToAddRightB = {}
local lines

local function errorhandler(err)
    return geterrorhandler()(err)
end

local executeCode = function(tag, code)
    if not code then return end

    return assert(loadstring(code, tag))(xpcall, errorhandler)
end

-- Thanks to ckknight for this
mod.short = function(value)
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

mod.unitHasAura = function(aura)
    local i = 1
    while true do
        local buff = UnitBuff("mouseover", i, true)
        if not buff then return end
        if buff == aura then return true end
        i = i + 1
    end
end

local function updateLines()
    if not UnitExists("mouseover") then
        mod:CancelTimer(timer)
        timer = nil
        return
    end
    for _, v in ipairs(lines) do
        if v.updating and v.right and self.db.profile[v.db] then
            local left = executeCode(v.name, v.left)
            local right, c = executeCode(v.name, v.right)
            if left and right then
                for i = 1, self.NUM_LINES do
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

local defaults = {profile={titles=true, empty = true, lines = {}}}

local defaultLines={
    [1] = {
        name = "UnitName",
        left = [[
local text = StarTip:GetModule("Text")
local c
if UnitIsPlayer("mouseover") then
    c = RAID_CLASS_COLORS[select(2, UnitClass("mouseover"))]
else
    c = {}
    c.r, c.g, c.b = UnitSelectionColor("mouseover")
end
return text.unitName, c
]],
        right = nil,
        updating = false
    },
    [2] = {
        name = "Target",
        left = 'return "Target:"',
        right = [[
if UnitExists("mouseovertarget") then
    local c
    if UnitIsPlayer("mouseovertarget") then
        c = RAID_CLASS_COLORS[select(2, UnitClass("mouseovertarget"))]
    else
        c = {}
        c.r, c.g, c.b = UnitSelectionColor("mouseovertarget")
    end
    local name = UnitName("mouseovertarget")
    return name, c
else
    return "None", {r=1, g=1, b=1}
end
]],
        updating = true
    },
    [3] = {
        name = "Guild",
        left = 'return "Guild:"',
        right = [[
local guild = GetGuildInfo("mouseover")
local text = StarTip:GetModule("Text")
if guild then return guild else return text.unitGuild end
]],
        updating = false
    },
    [4] = {
        name = "Rank",
        left = 'return "Rank:"',
        right = [[
return select(2, GetGuildInfo("mouseover"))
]],    
        updating = false
    },
    [5] = {
        name = "Realm",
        left = 'return "Realm:"',
        right = [[
return select(2, UnitName("mouseover"))
]],
        updating = false
    },
    [6] = {
        name = "Level",
        left = 'return "Level:"',
        right = [[
local classifications = {
    worldboss = "Boss",
    rareelite = "+ Rare",
    elite = "+",
    rare = "Rare"
}        
            
local lvl = UnitLevel("mouseover")
local class = UnitClassification("mouseover")
    
if lvl <= 0 then 
    lvl = ''
end

if classifications[class] then
    lvl = lvl .. classifications[class]
end

return lvl
]],
        updating = false
    },
    [7] = {
        name = "Race",
        left = 'return "Race:"',
        right = [[
local race
if UnitIsPlayer("mouseover") then
    race = UnitRace("mouseover");
else
    race = UnitCreatureFamily("mouseover") or UnitCreatureType("mouseover")
end
return race        
]],
        updating = false
    },
    [8] = {
        name = "Class",
        left = 'return "Class:"',
        right = [[
local class = UnitClass("mouseover")
if class == UnitName("mouseover") then return end
local c = UnitIsPlayer("mouseover") and RAID_CLASS_COLORS[select(2, UnitClass("mouseover"))]
return class, c
]],
        updating = false
    },
    [9] = {
        name = "Faction",
        left = 'return "Faction:"',
        right = [[
return UnitFactionGroup("mouseover")
]],
        updating = false
    },
    [10] = {
        name = "Status",
        left = 'return "Status:"',
        right = [[
local text = StarTip:GetModule("Text")
if not UnitIsConnected("mouseover") then
    return "Offline"
elseif text.unitHasAura(GetSpellInfo(19752)) then
    return "Divine Intervention"
elseif UnitIsFeignDeath("mouseover") then
    return "Feigned Death"
elseif UnitIsGhost("mouseover") then
    return "Ghost"
elseif UnitIsDead("mouseover") and  text.unitHasAura(GetSpellInfo(20707)) then
    return "Soulstoned"
elseif UnitIsDead("mouseover") then
    return "Dead"
end
]],
        updating = true
    },
    [11] = {
        name = "Health",
        left = 'return "Health:"',
        right = [[
local text = StarTip:GetModule("Text")
local health, maxHealth = UnitHealth("mouseover"), UnitHealthMax("mouseover")    
local value
if maxHealth == 100 then 
    value = health .. "%"
elseif maxHealth ~= 0 then
    value = format("%s/%s (%d%%)", text.short(health), text.short(maxHealth), health/maxHealth*100)
end
return value
]],
        updating = true
    },
    [12] = {
        name = "Mana",
        left = [[
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
            
local class = select(2, UnitClass("mouseover"))
return powers[class]
]],
        right = [[
local text = StarTip:GetModule("Text")
local mana = UnitMana("mouseover")
local maxMana = UnitManaMax("mouseover")
local value
if maxMana == 100 then
    value = mana
elseif maxMana ~= 0 then
    value = format("%s/%s (%d%%)", text.short(mana), text.short(maxMana), mana/maxMana*100)
end
return value        
]],
        updating = true
    },
    [13] = {
        name = "Location",
        left = 'return "Location:"',
        right = [[
local text = StarTip:GetModule("Text")
return text.unitLocation
]],
        updating = true
    },
}

local options = {}

--[[do
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
end]]

function mod:OnInitialize()    
    self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	if self.db.profile.empty then
		for i, v in ipairs(defaultLines) do
			tinsert(self.db.profile.lines, v)
		end
		self.db.profile.empty = false
	end
    self.leftLines = StarTip.leftLines
    self.rightLines = StarTip.rightLines
    self:RegisterEvent("UPDATE_FACTION")
    StarTip:SetOptionsDisabled(options, true)
end

function mod:OnEnable()
	self:CreateLines()
    if TalentQuery then TalentQuery.RegisterCallback(self, "TalentQuery_Ready") end
    
    StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
    if TalentQuery then TalentQuery.UnregisterCallback(self, "TalentQuery_Ready") end
    StarTip:SetOptionsDisabled(options, true)
end

function mod:GetOptions()
    self:RebuildOpts()
    return options
end

function mod:UPDATE_FACTION()
    for i = 1, GetNumFactions() do
        local name = GetFactionInfo(i)
        factionList[name] = true
    end
end

function mod:CreateLines()
    local llines = {}
    for i, v in ipairs(self.db.profile.lines) do
        llines[i] = v
    end
    lines = setmetatable(llines, {__call=function(this)
        local lineNum = 0
        for i, v in ipairs(this) do
            --if self.db.profile[v.db] then
                local left, right, c
                if v.right then 
                    right, c = executeCode(v.name, v.right)
                    left = executeCode(v.name, v.left)
                else 
                    right = ''
                    left, c = executeCode(v.name, v.left)
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
            --end
        end
        self.NUM_LINES = lineNum
    end})    
end

function validateCode(code) 
    local ret, err = loadstring(code, "validate")
    if not ret then
        StarTip:Print(("Code failed to execute. Error message: %s"):format(err or ""))
        return false
    end
    StarTip:Print(("Code executed without error. Return value: %s"):format(ret or ""))
    return true
end

function mod:RebuildOpts()
    options = {
		add = {
			name = "Add Line",
			desc = "Give the line a name",
			type = "input",
			set = function(info, v)
				if v == "" then return end
				tinsert(self.db.profile.lines, {name = v, left = "", right = "", updating = false})
				self:RebuildOpts()
				StarTip:RebuildOpts()
				self:CreateLines()
			end,
			order = 5
		},
		defaults = {
			name = "Restore Defaults",
			desc = "Roll back to defaults.",
			type = "execute",
			func = function()
				self.db.profile.lines = {}
				for i, v in ipairs(defaultLines) do
					tinsert(self.db.profile.lines, v)
				end
				self:RebuildOpts()
				StarTip:RebuildOpts()
				self:CreateLines()
			end,
			order = 6
		}
	}
    for i, v in ipairs(self.db.profile.lines) do
        options["line" .. i] = {
            name = v.name,
            type = "group",
            args = {
                left = {
                    name = "Left",
                    type = "input",
                    desc = "Left text code",
                    get = function() return v.left end,
                    set = function(info, val) v.left = val end,
                    validate = validateCode,
                    multiline = true,
					width = "full",
                    order = 1
                },
                right = {
                    name = "Right",
                    type = "input",
                    desc = "Right text code",
                    get = function() return v.right end,
                    set = function(info, val) v.right = val end,
                    validate = validateCode,
                    multiline = true,
					width = "full",
                    order = 2
                },
                updating = {
                    name = "Updating",
                    desc = "Whether this line refreshes while hovering over object/unit.",
                    type = "toggle",
                    get = function() return v.updating end,
                    set = function(info, val) v.updating = val end,
                    order = 3
                },
                up = {
                    name = "Move Up",
                    desc = "Move this line up by one",
                    type = "execute",
                    func = function()
                        if i == 1 then return end
                        local tmp = self.db.profile.lines[i - 1]
						if not v.left then v.left = "" end
						if not v.right then v.right = "" end
						if not tmp.left then tmp.left = "" end
						if not tmp.right then tmp.right = "" end
                        self.db.profile.lines[i - 1] = v
                        self.db.profile.lines[i] = tmp
                        self:RebuildOpts()
						StarTip:RebuildOpts()
						self:CreateLines()
                    end,
                    order = 4
                },
                down = {
                    name = "Move Down",
                    desc = "Move this line down by one",
                    type = "execute",
                    func = function()
                        if i == #self.db.profile.lines then return end
                        local tmp = self.db.profile.lines[i + 1]
                        self.db.profile.lines[i + 1] = v
                        self.db.profile.lines[i] = tmp
                        self:RebuildOpts()
						StarTip:RebuildOpts()
						self:CreateLines()
                    end,
                    order = 5
                },
				delete = {
					name = "Delete",
					desc = "Delete this line",
					type = "execute",
					func = function()
						table.remove(self.db.profile.lines, i)
						self:RebuildOpts()
						StarTip:RebuildOpts()
						self:CreateLines()
					end,
					order = 6
				},
            },
            order = i + 5
        }
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

local ff = CreateFrame("Frame")
function mod:SetUnit()
    --[[self = mod
    if not UnitExists("mouseover") then 
        if ff:GetScript("OnUpdate") then
            ff:SetScript("OnUpdate", nil)
        else
            ff:SetScript("OnUpdate", self.SetUnit)
        end
        return 
    end]]
        
    if ff:GetScript("OnUpdate") then ff:SetScript("OnUpdate", nil) end
    
    self.unitName = getName()
    self.unitLocation = getLocation()
    self.unitGuild = getGuild()
    
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
    
    GameTooltip:Show()
end
