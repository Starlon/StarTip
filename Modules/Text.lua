local mod = StarTip:NewModule("Text", "AceTimer-3.0", "AceEvent-3.0")
mod.name = "Text"
mod.toggled = true
assert(LibStub("StarLibEvaluator-1.0", true), "Text module requires StarLibEvaluator-1.0")
local LibProperty = LibStub("StarLibProperty-1.0", true)
assert(LibProperty, "Text module requires StarLibProperty-1.0")
local WidgetText = LibStub("StarLibWidgetText-1.0", true)
assert(WidgetText, "Text module requires StarLibWidgetText-1.0")
local LCDText = LibStub("StarLibLCDText-1.0", true)
assert(LCDText, mod.name .. " requires StarLibLCDText-1.0")
local LibCore = LibStub("StarLibCore-1.0", true)
assert(LibCore, mod.name .. " requires StarLibCore-1.0")
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
local environment = {}
environment.new = StarTip.new
environment.newDict = StarTip.newDict
environment.del = StarTip.del
environment._G = _G
environment.UnitExists = _G.UnitExists
environment.UnitIsPlayer = _G.UnitIsPlayer
environment.UnitBuff = _G.UnitBuff
environment.GetSpellInfo = _G.GetSpellInfo
environment.UnitIsConnected = _G.UnitIsConnected
environment.UnitIsFeignDeath = _G.UnitIsFeignDeath
environment.UnitIsGhost = _G.UnitIsGhost
environment.UnitIsDead = _G.UnitIsDead
environment.UnitLevel = _G.UnitLevel
environment.UnitClassification = _G.UnitClassification
environment.UnitSelectionColor = _G.UnitSelectionColor
environment.UnitRace = _G.UnitRace
environment.GetGuildInfo = _G.GetGuildInfo
environment.UnitName = _G.UnitName
environment.UnitClass = _G.UnitClass
environment.UnitHealth = _G.UnitHealth
environment.UnitHealthMax = _G.UnitHealthMax
environment.UnitMana = _G.UnitMana
environment.UnitManaMax = _G.UnitManaMax
environment.UnitFactionGroup = _G.UnitFactionGroup
environment.UnitCreatureFamily = _G.UnitCreatureFamily
environment.UnitCreatureType = _G.UnitCreatureType
environment.UnitIsUnit = _G.UnitIsUnit
environment.RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local LSM = _G.LibStub("LibSharedMedia-3.0")
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
local lines = {}

local function errorhandler(err)
    return geterrorhandler()(err)
end

local ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_MARQUEE, ALIGN_AUTOMATIC, ALIGN_PINGPONG = 1, 2, 3, 4, 5, 6

local SCROLL_RIGHT, SCROLL_LEFT = 1, 2

-- Thanks to ckknight for this
environment.short = function(value)
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

environment.powers = {
    ["WARRIOR"] = "Rage:",
    ["ROGUE"] = "Energy:",
	["DEATHKNIGHT"] = "Rune Power:"
}

environment.unitHasAura = function(aura)
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
            local left, c = StarTip.ExecuteCode(environment, v.name, v.left)
            local right, cc = StarTip.ExecuteCode(environment, v.name, v.right)
            if left and right then
                for i = 1, self.NUM_LINES do
                    if mod.leftLines[i]:GetText() == left then
                        mod.rightLines[i]:SetText(right)
                        if type(cc) == "table" and cc.r then
                            mod.rightLines[i]:SetVertexColor(cc.r, cc.g, cc.b)
                        end
						if type(c) == "table" and c.r then
							mod.leftLines[i]:SetVertexColor(c.r, c.g, c.b)
						end
                    end
                end				
            end
			StarTip.del(c)
			StarTip.del(cc)			
        end
    end
end

--[[
local newFont, delFont
do
	local pool = setmetatable({},{__mode='k'})
	newFont = function(key) 
		local t = next(pool)
		if not t then
			t = CreateFont(key)
			t:CopyFontObject(GameTooltipText)			
		end
		pool[t] = nil
		return t
	end
	delFont = function(tbl)
		pool[tbl] = true
	end
end
]]

function copy(t)
	local tmp = StarTip.new()
	for k, v in pairs(t) do
		if type(v) == "table" then
			v = copy(v)
		end	
		tmp[k] = v
	end
	
	return tmp
end

--[[
function del(t)
	for k, v in pairs(t) do
		if type(v) == "table" then
			del(v)
		end
		t[k] = nil
		StarTip.del(t)
	end
end
]]

local defaults = {profile={titles=true, empty = true, lines = {}}}

local defaultLines={
    [1] = {
        name = "UnitName",
        left = [[
local c
if self.UnitIsPlayer("mouseover") then
    c = self.RAID_CLASS_COLORS[select(2, self.UnitClass("mouseover"))]
else
    c = self:new()
    c.r, c.g, c.b = self.UnitSelectionColor("mouseover")
end
return self.unitName, c
]],
        right = nil,
        updating = false,
		bold = true,
		enabled = true
    },
    [2] = {
        name = "Target",
        left = 'return "Target:"',
        right = [[		
if self.UnitExists("mouseovertarget") then
    local c
    if self.UnitIsPlayer("mouseovertarget") then
        c = self.RAID_CLASS_COLORS[select(2, self.UnitClass("mouseovertarget"))]
    else
        c = self:new()
        c.r, c.g, c.b = self.UnitSelectionColor("mouseovertarget")
    end
    local name = self.UnitName("mouseovertarget")
    return name, c
else
    return "None", self:newDict("r", 1, "g", 1, "b", 1)
end
]],
        updating = true,
		enabled = true
    },
    [3] = {
        name = "Guild",
        left = 'return "Guild:"',
        right = [[
local guild = self.GetGuildInfo("mouseover")
if guild then return "<" .. guild .. ">" else return self.unitGuild end
]],
        updating = false,
		enabled = true
    },
    [4] = {
        name = "Rank",
        left = 'return "Rank:"',
        right = [[
return select(2, self.GetGuildInfo("mouseover"))
]],    
        updating = false,
		enabled = true
    },
    [5] = {
        name = "Realm",
        left = 'return "Realm:"',
        right = [[
return select(2, self.UnitName("mouseover"))
]],
        updating = false,
		enabled = true
    },
    [6] = {
        name = "Level",
        left = 'return "Level:"',
        right = [[
local classifications = self:newDict(
    "worldboss", "Boss",
    "rareelite", "+ Rare",
    "elite", "+",
    "rare", "Rare")
            
local lvl = self.UnitLevel("mouseover")    
local class = self.UnitClassification("mouseover")
    
if lvl <= 0 then 
    lvl = ''
end

if classifications[class] then
    lvl = lvl .. classifications[class]
end

self.del(classifications)

return lvl
]],
        updating = false,
		enabled = true
    },
    [7] = {
        name = "Race",
        left = 'return "Race:"',
        right = [[
local race
if self.UnitIsPlayer("mouseover") then
    race = self.UnitRace("mouseover");
else
    race = self.UnitCreatureFamily("mouseover") or self.UnitCreatureType("mouseover")
end
return race        
]],
        updating = false,
		enabled = true
    },
    [8] = {
        name = "Class",
        left = 'return "Class:"',
        right = [[
local class = self.UnitClass("mouseover")
if class == self.UnitName("mouseover") then return end
local c = self.UnitIsPlayer("mouseover") and self.RAID_CLASS_COLORS[select(2, self.UnitClass("mouseover"))]
return class, c
]],
        updating = false,
		enabled = true
    },
    [9] = {
        name = "Faction",
        left = 'return "Faction:"',
        right = [[
return self.UnitFactionGroup("mouseover")
]],
        updating = false,
		enabled = true
    },
    [10] = {
        name = "Status",
        left = 'return "Status:"',
        right = [[
if not self.UnitIsConnected("mouseover") then
    return "Offline"
elseif self.unitHasAura(self.GetSpellInfo(19752)) then
    return "Divine Intervention"
elseif self.UnitIsFeignDeath("mouseover") then
    return "Feigned Death"
elseif self.UnitIsGhost("mouseover") then
    return "Ghost"
elseif self.UnitIsDead("mouseover") and  self.unitHasAura(self.GetSpellInfo(20707)) then
    return "Soulstoned"
elseif self.UnitIsDead("mouseover") then
    return "Dead"
end
]],
        updating = true,
		enabled = true
    },
    [11] = {
        name = "Health",
        left = 'return "Health:"',
        right = [[
local health, maxHealth = self.UnitHealth("mouseover"), self.UnitHealthMax("mouseover")    
local value
if maxHealth == 100 then 
    value = health .. "%"
elseif maxHealth ~= 0 then
    value = format("%s/%s (%d%%)", self.short(health), self.short(maxHealth), health/maxHealth*100)
end
return value
]],
        updating = true,
		enabled = true
    },
    [12] = {
        name = "Mana",
        left = [[
            
local class = select(2, self.UnitClass("mouseover"))
if not self.UnitIsPlayer("mouseover") then
	class = "MAGE"
end

return (self.powers[class] or "Mana:")
]],
        right = [[
local mana = self.UnitMana("mouseover")
local maxMana = self.UnitManaMax("mouseover")
if maxMana == 100 then
    value = mana
elseif maxMana ~= 0 then
    value = format("%s/%s (%d%%)", self.short(mana), self.short(maxMana), mana/maxMana*100)
end
return value
]],
        updating = true,
		enabled = true
    },
    [13] = {
        name = "Location",
        left = 'return "Location:"',
        right = [[
return self.unitLocation
]],
        updating = true,
		enabled = true
    },
	[14] = {
		name = "Marquee",
		left = 'return "StarTip " .. self._G.StarTip.version',
		updating = true,
		enabled = false,
		marquee = true,
		width = 20,
		prefix = 'return "---"',
		postfix = 'return "---"',
		bold = true,
		align = 'M',
		update = 1000,
		speed = 100,
		direction = DIRECTION_LEFT		
	},
	[15] = {
		name = "Range",
		left = [[
local min, max = RangeCheck:GetRange("mouseover")
if not min then
    return "No range info"
elseif not max then
    return "Target is over " .. min .. " yards"
else
    return "Between " .. min .. " and " .. max .. " yards"
end
]],
		updating = true,
		enabled = true
	}
}

local options = {}

function mod:OnInitialize()    
    self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	
	for i, v in ipairs(defaultLines) do
		for j, vv in ipairs(self.db.profile.lines) do
			if v.name == vv.name then
				if v.left ~= vv.left and not vv.leftDirty then
					vv.left = v.left
					v.leftDirty = nil
				end
				if v.right ~= vv.right and not vv.rightDirty then
					vv.right = v.right
					v.rightDirty = nil
				end
				v.tagged = true
			end
		end
	end
	
	for i, v in ipairs(defaultLines) do
		if not v.tagged and not v.deleted then
			tinsert(self.db.profile.lines, v)
		end
	end
	
	--[[if self.db.profile.empty then
		for i, v in ipairs(defaultLines) do
			tinsert(self.db.profile.lines, v)
		end
		self.db.profile.empty = false
	end]]
		
    self.leftLines = StarTip.leftLines
    self.rightLines = StarTip.rightLines
    self:RegisterEvent("UPDATE_FACTION")
	self:RegisterEvent("PLAYER_LOGIN")
    StarTip:SetOptionsDisabled(options, true)
	
	self.core = LibCore:New(mod, environment, name, config, "ModuleText", lcd, StarTip.db.profile.errorLevel)
	self.evaluator = LibStub("StarLibEvaluator-1.0"):New(environment, StarTip.db.profile.errorLevel)
	
end

function mod:OnEnable()
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


local function makeMarquee(line, text)
	
	return text
end

function mod:CreateLines()
    local llines = {}
    for i, v in ipairs(self.db.profile.lines) do
        llines[i] = copy(v)
    end
    lines = setmetatable(llines, {__call=function(self)
        local lineNum = 0
		GameTooltip:ClearLines()
        for i, v in ipairs(self) do
			if not v.leftProp then
			--[[
				v.leftProp = LibProperty:New(mod, v.name .. " left", v.left, "", StarTip.db.profile.errorLevel)
				v.rightProp = LibProperty:New(mod, v.name .. " right", v.right, "", StarTip.db.profile.errorLevel)
				v.prefixProp = LibProperty:New(mod, v.name .. " prefix", v.prefix, "", StarTip.db.profile.errorLevel)
				v.postfixProp = LibProperty:New(mod, v.name .. " postfix", v.postfix, "", StarTip.db.profile.errorLevel)
				v.leftProp:Eval()
				StarTip:Print(v.leftProp:P2S())
				]]
			end
			if v.enabled then
				
                local left, right, c = '', ''
				
				
                if v.right then 
                    right, c = mod.evaluator.ExecuteCode(environment, v.name, v.right)
                    left, cc = mod.evaluator.ExecuteCode(environment, v.name, v.left)
                else 
                    right = ''
                    left, c = mod.evaluator.ExecuteCode(environment, v.name, v.left)
                end
				
                if left and right and not v.deleted then 
                    lineNum = lineNum + 1
                    if v.right then
						GameTooltip:AddDoubleLine(' ', ' ', 1, 1, 1, 1, 1, 1)
                        mod.leftLines[lineNum]:SetText(left)
                        mod.rightLines[lineNum]:SetText(right)
                        if type(c) == "table" and c.r then
                            mod.rightLines[lineNum]:SetVertexColor(c.r, c.g, c.b)
                        end
						if type(cc) == "table" and cc.r then
							mod.leftLines[lineNum]:SetVertexColor(cc.r, cc.g, cc.b)
						end
                    else
						GameTooltip:AddLine(' ', 1, 1, 1)
                        mod.leftLines[lineNum]:SetText(left)
                        if type(c) == "table" and c.r then
                            mod.leftLines[lineNum]:SetVertexColor(c.r, c.g, c.b)
                        end
						if v.marquee then
							v.string = v.left
							if v.marqueeObj and v.marqueeObj.visitor and v.marqueeObj.visitor.lcd then
								v.marqueeObj.visitor.lcd:Del()
								v.marqueeObj.vistior.lcd = nil
							end
							
							if v.marqueeObj then
								v.marqueeObj:Stop()
								v.marqueeObj:Del()
								v.marqueeObj = nil
							end
							--(visitor, name, config, row, col, layer, fontString, env, errorLevel, callback, data) 
							v.marqueeObj = WidgetText:New(mod.core, v.name, v, 0, 0, 0, mod.leftLines[lineNum], environment, StarTip.db.profile.errorLevel) 
							v.marqueeObj.visitor.lcd = LCDText:New(mod.core, 1, v.width, 0, 0, 0, 0)							
							v.marqueeObj:Start()
							v.lastLine = lineNum
						end
                    end
                end
				StarTip.del(c)
				StarTip.del(cc)
			end

--[[			if v.marquee and v.enabled then				
				--GameTooltip:AddLine(' ', 1, 1, 1)
				--lineNum = lineNum + 1
				v.string = v.left
				if v.marqueeObj then
					v.marqueeObj:Stop() -- just to be double sure
					v.marqueeObj:Del()
					v.marqueeObj = nil
				end
				if not v.marqueeObj then
					
					v.marqueeObj = WidgetText:New(self, v.name, v, 0, 0, 0, mod.leftLines[lineNum], environment, StarTip.db.profile.errorLevel) 
				end				
				v.marqueeObj:Start()
				v.lastLine = lineNum
			end
--]]
        end
        self.NUM_LINES = lineNum

    end})
	for i, v in ipairs(self.db.profile.lines) do
		local appearance = StarTip:GetModule("Appearance")
		
		local font = appearance.db.profile.font
		local fontsList = LSM:List("font")
		font = LSM:Fetch("font", fontsList[font])
		if v.bold then
			mod.leftLines[i]:SetFont(font, appearance.db.profile.fontSizeBold, "OUTLINE")
			mod.rightLines[i]:SetFont(font, appearance.db.profile.fontSizeBold, "OUTLINE")
		else
			mod.leftLines[i]:SetFont(font, appearance.db.profile.fontSizeNormal)
			mod.rightLines[i]:SetFont(font, appearance.db.profile.fontSizeNormal)
		end
	end
end

function mod:OnHide()
	for i, v in ipairs(lines) do
		if v.marqueeObj then
			v.marqueeObj:Stop()
			v.marqueeObj = nil
		end
	end
end

function mod:PLAYER_LOGIN()
	for i, v in ipairs(mod.db.profile.lines) do
		v.marqueeObj = nil
	end
	mod:CreateLines()
end

local function copy(t)
	local new = {}
	for k, v in pairs(t) do
		if type(t) == "table" then
			new[k] = copy(t)
		else
			name[k] = v
		end
	end
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
		},
	}
    for i, v in ipairs(self.db.profile.lines) do
		if type(v) ~= "table" or v.deleted then break end
        options["line" .. i] = {
            name = v.name,
            type = "group",
            args = {
                left = {
                    name = "Left",
                    type = "input",
                    desc = "Left text code",
                    get = function() return v.left end,
                    set = function(info, val) v.left = val; v.leftDirty = true end,
                    validate = function(info, str)	
						StarTip:Print("Validate " .. str)
						
						local ret, err = mod.evaluator.ExecuteCode(environment, "validate", str)
						
						if not ret then
							StarTip:Print(("Code failed to load. Error message: %s"):format(err or ""))
							v.error = true
							return false
						end
						v.left = str
						StarTip:Print(("Code loaded without error. Return value: %s"):format(ret or ""))
						self:CreateLines()
						return true
					
					end,
                    multiline = true,
					width = "full",
                    order = 1
                },
                right = {
                    name = "Right",
                    type = "input",
                    desc = "Right text code",
                    get = function() return v.right end,
                    set = function(info, val) v.right = val; v.rightDirty = true end,
                    validate = function(info, str)
						if str == "" then str = "return ''" end
						
						local ret, err = mod.evaluator.ExecuteCode(environment, "validate", str)
						
						if not ret then
							StarTip:Print(("Code failed to load. Error message: %s"):format(err or ""))
							return false
						end
						
						v.right = str
						StarTip:Print(("Code loaded without error. Return value: %s"):format(ret or ""))
						self:CreateLines()
					    return true
					
					end,
                    multiline = true,
					width = "full",
                    order = 2
                },
                updating = {
                    name = "Updating",
                    desc = "Whether this line refreshes while hovering over unit.",
                    type = "toggle",
                    get = function() return v.updating end,
                    set = function(info, val) 
						v.updating = val 
						self:CreateLines()
					end,
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
						if not v.left then v.left = "" end
						if not v.right then v.right = "" end
						if not tmp.left then tmp.left = "" end
						if not tmp.right then tmp.right = "" end
                        self.db.profile.lines[i + 1] = v
                        self.db.profile.lines[i] = tmp
                        self:RebuildOpts()
						StarTip:RebuildOpts()
						self:CreateLines()
                    end,
                    order = 5
                },
				bold = {
					name = "Bold",
					desc = "Whether to bold this line or not",
					type = "toggle",
					get = function() return self.db.profile.lines[i].bold end,
					set = function(info, v) 
						self.db.profile.lines[i].bold = v
						self:CreateLines() 
					end,
					order = 6
				},
				enabled = {
					name = "Enabled",
					desc = "Whether to show this line or not",
					type = "toggle",
					get = function() return self.db.profile.lines[i].enabled end,
					set = function(info, v)
						self.db.profile.lines[i].enabled = v
						self:CreateLines()
					end,
					order = 7
				},
				delete = {
					name = "Delete",
					desc = "Delete this line",
					type = "execute",
					func = function()
						local deleted
						
						for j, vv in ipairs(defaultLines) do
							if vv.name == v.name then
								deleted = true
							else
								
							end
						end
						
						if deleted then
							v.deleted = true
						else
							table.remove(self.db.profile.lines, i)
						end
						
						self:RebuildOpts()
						StarTip:RebuildOpts()
						self:CreateLines()
					end,
					order = 8
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
    if ff:GetScript("OnUpdate") then ff:SetScript("OnUpdate", nil) end
    
    environment.unitName = getName()
    environment.unitLocation = getLocation()
    environment.unitGuild = getGuild()
    
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
