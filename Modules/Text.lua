local mod = StarTip:NewModule("Text", "AceEvent-3.0")
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
local LibTimer = LibStub("StarLibTimer-1.0", true)
assert(LibTimer, mod.name .. " requires StarLibTimer-1.0")
local LibEvaluator = LibStub("StarLibEvaluator-1.0", true)
assert(LibEvaluator, mod.name .. " requires StarLibEvaluator-1.0")

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
local LSM = _G.LibStub("LibSharedMedia-3.0")
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

local appearance = StarTip:GetModule("Appearance")

local function errorhandler(err)
    return geterrorhandler()(err)
end

local ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_MARQUEE, ALIGN_AUTOMATIC, ALIGN_PINGPONG = 1, 2, 3, 4, 5, 6

local SCROLL_RIGHT, SCROLL_LEFT = 1, 2

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

local defaults = {profile={titles=true, empty = true, lines = {}, refreshRate = 100}}

local defaultLines={
    [1] = {
        name = "UnitName",
        left = [[
return self.unitName
]],
        right = nil,
		colorLeft = [[
local c
if self.UnitIsPlayer("mouseover") then
    c = self.RAID_CLASS_COLORS[select(2, self.UnitClass("mouseover"))]
else
    c = self:new()
    c.r, c.g, c.b = self.UnitSelectionColor("mouseover")
end
return c
]],
		bold = true,
		enabled = true
    },
    [2] = {
        name = "Target",
        left = 'return "Target:"',
        right = [[		
if self.UnitExists("mouseovertarget") then
    local name = self.UnitName("mouseovertarget")
    return name
else
    return "None"
end
]],
		colorRight = [[
if self.UnitExists("mouseovertarget") then
    local c
    if self.UnitIsPlayer("mouseovertarget") then
        c = self.RAID_CLASS_COLORS[select(2, self.UnitClass("mouseovertarget"))]
    else
        c = self.new()
        c.r, c.g, c.b = self.UnitSelectionColor("mouseovertarget")
    end
    return c
else
	c = self.new()
	c.r = 1
	c.g = 1
	c.b = 1
    return c
end		
]],
        rightUpdating = true,
		enabled = true
    },
    [3] = {
        name = "Guild",
        left = 'return "Guild:"',
        right = [[
local guild = self.GetGuildInfo("mouseover")
if guild then return "<" .. guild .. ">" else return self.unitGuild end
]],
		enabled = true
    },
    [4] = {
        name = "Rank",
        left = 'return "Rank:"',
        right = [[
return select(2, self.GetGuildInfo("mouseover"))
]],    
		enabled = true
    },
    [5] = {
        name = "Realm",
        left = 'return "Realm:"',
        right = [[
return select(2, self.UnitName("mouseover"))
]],
		enabled = true
    },
    [6] = {
        name = "Level",
        left = 'return "Level:"',
        right = [[
local lvl = self.UnitLevel("mouseover")
local class = self.UnitClassification("mouseover")

if lvl <= 0 then
    lvl = ''
end

if class == "worldboss" then
    lvl = lvl .. "Boss"
elseif class == "rareelite" then
    lvl = lvl .. "+ Rare"
elseif class == "elite" then
    lvl = lvl .. "+"
elseif class == "rare" then
    lvl = lvl .. "rare"
end

return lvl
]],
		enabled = true
    },	
    [7] = {
        name = "Race",
        left = 'return "Race:"',
        right = [[
local race
if self.UnitIsPlayer("mouseover") then
    race = self.UnitRace("mouseover")
else
    race = self.UnitCreatureFamily("mouseover") or self.UnitCreatureType("mouseover")
end
return race
]],
		enabled = true
    },
    [8] = {
        name = "Class",
        left = 'return "Class:"',
        right = [[
local class = self.UnitClass("mouseover")
if class == self.UnitName("mouseover") then return end
return class
]],
		colorRight = [[
return self.UnitIsPlayer("mouseover") and self.RAID_CLASS_COLORS[select(2, self.UnitClass("mouseover"))]
]],
		enabled = true
    },
    [9] = {
        name = "Faction",
        left = 'return "Faction:"',
        right = [[
return self.UnitFactionGroup("mouseover")
]],
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
		enabled = true
    },
    [11] = {
        name = "Health",
        left = 'return "Health:"',
        right = [[
local health, maxHealth = self.UnitHealth("mouseover"), self.UnitHealthMax("mouseover")
local value = "Unknown"
if maxHealth == 100 then
    value = health .. "%"
elseif maxHealth ~= 0 then
    value = format("%s/%s (%d%%)", self.short(health), self.short(maxHealth), health/maxHealth*100)
end
return value
]],
        rightUpdating = true,
		update = 1000,
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
local value = "Unknown"
if maxMana == 100 then
    value = mana
elseif maxMana ~= 0 then
    value = format("%s/%s (%d%%)", self.short(mana), self.short(maxMana), mana/maxMana*100)
end
return value
]],
        rightUpdating = true,
		enabled = true,
		update = 1000
    },
    [13] = {
        name = "Location",
        left = 'return "Location:"',
        right = "return self.unitLocation",
		enabled = true
    },
	[14] = {
		name = "Marquee",
		left = 'return "StarTip " .. self._G.StarTip.version',
		rightUpdating = true,
		enabled = false,
		marquee = true,
		cols = 100,
		bold = true,
		align = WidgetText.ALIGN_MARQUEE,
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
		leftUpdating = true,
		enabled = true,
		update = 1000
	},
	[16] = {
		name = "Memory Usage",
		left = "return 'Memory Usage:'",
		right = [[
local mem, percent = GetMemUsage("StarTip")
if mem then
    return memshort(tonumber(format("%.2f", mem))) .. " (" .. format("%.2f", percent) .. "%)"
end
]],
		rightUpdating = true,
		update = 1000
	},
	[17] = {
		name = "CPU Usage",
		desc = "Note that you must turn on CPU profiling",
		left = 'return "CPU Usage:"',
		right = [[
local cpu, percent, cpudiff, totalCPU, totaldiff = GetCPUUsage("StarTip")
if cpu then
    percent = cpudiff / totaldiff * 100
    return format("%.2f", cpu) .. " (" .. format("%.2f", percent)  .. "%)"
end
]],
		rightUpdating = true,
		update = 1000
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
    StarTip:SetOptionsDisabled(options, true)
	
	-- create our core object. Note that we must provide it with an LCD after it is created.
	
	self.core = LibCore:New(mod, environment, self:GetName(), {[self:GetName()] = {}}, "text", StarTip.db.profile.errorLevel)
	self.lcd = LCDText:New(self.core, 1, 0, 0, 0, 0, 0)
	self.core.lcd = self.lcd
	
	self.evaluator = LibEvaluator:New(environment, StarTip.db.profile.errorLevel)
	assert(self.evaluator)
end

local draw
local update
function mod:OnEnable()
        StarTip:SetOptionsDisabled(options, false)
		self:CreateLines()
		self.timer = LibTimer:New("Text module", self.db.profile.refreshRate, true, draw, nil, self.db.profile.errorLevel, self.db.profile.durationLimit)
		self.timer:Start()
end

function mod:OnDisable()
    StarTip:SetOptionsDisabled(options, true)
	self.timer:Stop()
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

local linesToDraw = {}
local function updateFontString(widget, fontString)
	tinsert(linesToDraw, {widget, fontString})
end

function draw()
	for i, table in ipairs(linesToDraw) do
		local widget = table[1]
		local fontString = table[2]
		fontString:SetText(widget.buffer)
		fontString:SetVertexColor(widget.color.r / 255, widget.color.g / 255, widget.color.b / 255, widget.color.a / 255)
		
		local font = appearance.db.profile.font
		local fontsList = LSM:List("font")
		font = LSM:Fetch("font", fontsList[font])	
	
		if widget.bold then
			if mod.leftLines and mod.leftLines[widget.i] then
				mod.leftLines[widget.i]:SetFont(font, appearance.db.profile.fontSizeBold)
			end
			if mod.rightLines and mod.rightLines[widget.i] then
				mod.rightLines[widget.i]:SetFont(font, appearance.db.profile.fontSizeBold)
			end
		else
			if mod.leftlines and mod.leftLines[widget.i] then
				mod.leftLines[widget.i]:SetFont(font, appearance.db.profile.fontSizeNormal)
		end
			if mod.rightLines and mod.rightLines[widget.i] then
				mod.rightLines[widget.i]:SetFont(font, appearance.db.profile.fontSizeNormal)
			end
		end
	end		
	if UnitExists("mouseover") and drawn then 
		GameTooltip:Hide()
		GameTooltip:Show()
	end
	StarTip.del(linesToDraw)
	linesToDraw = StarTip.new()
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
			if v.enabled then
				
                local left, right, c, cc = '', ''
                if v.right then 
                    right = mod.evaluator.ExecuteCode(environment, v.name, v.right)
					c = mod.evaluator.ExecuteCode(environment, v.name, v.colorRight)
                    left = mod.evaluator.ExecuteCode(environment, v.name, v.left)
					cc = mod.evaluator.ExecuteCode(environment, v.name, v.colorLeft)
					if right == "" then right = "nil" end
                else 
                    right = ''
                    left = mod.evaluator.ExecuteCode(environment, v.name, v.left)
					c = mod.evaluator.ExecuteCode(environment, v.name, v.colorLeft)
                end 

                if left and left ~= "" and right ~= "nil" and not v.deleted then 
                    lineNum = lineNum + 1
                    if v.right then
						GameTooltip:AddDoubleLine(' ', ' ')
						
						if false and not v.leftObj or v.lineNum ~= lineNum then
							if v.leftObj then  v.leftObj:Del() end
							v.value = v.left
							local tmp = v.update
							if not v.leftUpdating then v.update = 0 end
							v.leftObj = WidgetText:New(mod.core, v.name .. "left", v, 0, 0, v.layer or 0, StarTip.db.profile.errorLevel, updateFontString, mod.leftLines[lineNum])
							v.leftObj.visitor.lcd = self.lcd
							v.leftObj:Start()
							v.update = tmp
						else
							v.leftObj:Start()
						end
						if type(cc) == "table" and cc.r and cc.g and cc.b then
							v.leftObj.color.r = (cc.r * 255)
							v.leftObj.color.g = (cc.g * 255)
							v.leftObj.color.b = (cc.b * 255)
							v.leftObj.color.a = (cc.a or 1) * 255
						end
					
						if not v.rightObj or v.lineNum ~= lineNum then
							if v.rightObj then v.rightObj:Del() end
							v.value = v.right
							local tmp = v.update
							if not v.rightUpdating then v.update = 0 end
							v.rightObj = WidgetText:New(mod.core, v.name .. "right", v, 0, 0, v.layer or 0, StarTip.db.profile.errorLevel, updateFontString, mod.rightLines[lineNum]) 					
							v.rightObj.visitor.lcd = self.lcd
							v.rightObj:Start()
							v.update = tmp
						end
						if type(c) == "table" and c.r and c.g and c.b then
							v.rightObj.color.r = (c.r * 255)
							v.rightObj.color.g = (c.g * 255)
							v.rightObj.color.b = (c.b * 255)
							v.rightObj.color.a = (c.a or 1) * 255
						end
						tinsert(linesToDraw, {v.leftObj, mod.leftLines[lineNum]})
						tinsert(linesToDraw, {v.rightObj, mod.rightLines[lineNum]})
                    else
						GameTooltip:AddLine(' ')
							
						if false and not v.leftObj or v.lineNum ~= lineNum then
							if v.leftObj then v.leftObj:Del() end
							v.value = v.left
							local tmp = v.update
							if not v.leftUpdating then v.update = 0 end
							v.leftObj = WidgetText:New(mod.core, v.name, v, 0, 0, 0, StarTip.db.profile.errorLevel, updateFontString, mod.leftLines[lineNum]) 
							v.leftObj.visitor.lcd = lcd						
							v.leftObj:Start()
							v.lineNum = lineNum
							v.update = tmp
						end
						if type(c) == "table" and c.r and c.g and c.b then
							v.leftObj.color.r = c.r * 255 or 255
							v.leftObj.color.g = c.g * 255 or 255
							v.leftObj.color.b = c.b * 255 or 255
							v.leftObj.color.a = (c.a or 1) * 255 or 255
						end						
						tinsert(linesToDraw, {v.leftObj, mod.leftLines[lineNum]})
                    end
					if v.rightObj then 
						v.rightObj:Start()
					end
					if v.leftObj then
						v.leftObj:Start()
					end
					v.lineNum = lineNum
                end
				StarTip.del(c)
				StarTip.del(cc)
			end

        end
        self.NUM_LINES = lineNum
	draw()
    end})
end

function mod:OnHide()
	for i, v in ipairs(lines) do
		if v.leftObj then
			v.leftObj:Stop()
		end
		if v.rightObj then
			v.rightObj:Stop()
		end
	end
	self.timer:Stop()
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
				tinsert(self.db.profile.lines, {name = v, left = "", right = "", rightUpdating = false})
				self:RebuildOpts()
				StarTip:RebuildOpts()
				self:CreateLines()
			end,
			order = 5
		},
		refreshRate = {
			name = "Refresh Rate",
			desc = "The rate at which the tooltip will be refreshed",
			type = "input",
			pattern = "%d",
			get = function() return tostring(self.db.profile.refreshRate) end,
			set = function(info, v) self.db.profile.refreshRate = tonumber(v) end,
			order = 6
		},
		defaults = {
			name = "Restore Defaults",
			desc = "Roll back to defaults.",
			type = "execute",
			func = function()
				for i, v in ipairs(defaultLines) do
					local replaced
					for j, vv in ipairs(self.db.profile.lines) do
						if v.name == vv.name then
							self.db.profile.lines[j] = v
							replaced = true
						end
					end
					if not replaced then
						tinsert(self.db.profile.lines, v)
					end
				end
				self:RebuildOpts()
				StarTip:RebuildOpts()
				self:CreateLines()
			end,
			order = 7
		},
	}
    for i, v in ipairs(self.db.profile.lines) do
		if type(v) ~= "table" or v.deleted then break end
        options["line" .. i] = {
            name = v.name,
            type = "group",
            order = i + 5
        }
		options["line" .. i].args = {
				enabled = {
					name = "Enabled",
					desc = "Whether to show this line or not",
					type = "toggle",
					get = function() return self.db.profile.lines[i].enabled end,
					set = function(info, val)
						v.enabled = val
						self:CreateLines()
					end,
					order = 2
				},		
				leftUpdating = {
					name = "Left Updating",
					desc = "Whether this segment refreshes",
					type = "toggle",
					get = function() return v.leftUpdating end,
					set = function(info, val)
						v.leftUpdating = val
						self:CreateLines()
						if v.update == 0 then
							v.update = 500
						end						
					end,
					order = 3
				},
                rightUpdating = {
                    name = "Right Updating",
                    desc = "Whether this segment refreshes",
                    type = "toggle",
                    get = function() return v.rightUpdating end,
                    set = function(info, val) 
						v.rightUpdating = val 
						self:CreateLines()
						if v.update == 0 then
							v.update = 500
						end						
					end,
                    order = 4
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
                    order = 5
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
                    order = 6
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
	            left = {
                    name = "Left",
                    type = "input",
                    desc = "Left text code",
                    get = function() return v.left end,
                    set = function(info, val) 
						v.left = val 
						v.leftDirty = true 
						if val == "" then
							v.left = nil
						end
						self:CreateLines()						
					end,
                    validate = function(info, str)	
						return mod.evaluator:Validate(environment, str)
					end,
                    multiline = true,
					width = "full",
                    order = 9
                },
                right = {
                    name = "Right",
                    type = "input",
                    desc = "Right text code",
                    get = function() return v.right end,
                    set = function(info, val) 
						v.right = val; 
						v.rightDirty = true 
						if val == "" then
							v.right = nil
						end
						self:CreateLines()						
					end,
                    validate = function(info, str)	
						return mod.evaluator:Validate(environment, str)
					end,
                    multiline = true,
					width = "full",
                    order = 10
                },
				colorLeft = {
					name = "Left Color",
					type = "input",
					desc = "Color for left segment",
					get = function() return v.colorLeft end,
					set = function(info, val)
						v.colorLeft = val
						self:CreateLines()
					end,
                    validate = function(info, str)	
						return mod.evaluator:Validate(environment, str)
					end,					
					multiline = true,
					width = "full",
					order = 11
				},
				colorRight = {
					name = "Right Color",
					type = "input",
					desc = "Color for right segment",
					get = function() return v.colorRight end,
					set = function(info, val)
						v.colorRight = val
						self:CreateLines()
					end,
                    validate = function(info, str)	
						return mod.evaluator:Validate(environment, str)
					end,
					multiline = true,
					width = "full",
					order = 12
				},
				marquee = {
					name = "Maruqee Settings",
					type = "group",
					args = {
						header = {
							name = "Note that only the left line script is used for marquee text",
							type = "header",
							order = 1
						},
						marquee = {
							name = "Enabled",
							desc = "Enable marquee. Note that this just makes marquees use the left line only. Technically all segments on the tooltip are marquee widgets.",
							type = "toggle",
							get = function() return v.marquee end,
							set = function(info, val) 
								v.marquee = val 
								self:CreateLines()
							end
						},
						prefix = {
							name = "Prefix",
							desc = "The prefix for this marquee",
							type = "input",
							width = "full",
							multiline = true,
							get = function()
								return v.prefix
							end,
							set = function(info, val)
								v.prefix = val
								self:CreateLines()
							end,
							order = 2
						},
						postfix = {
							name = "Postfix",
							desc = "The postfix for this marquee",
							type = "input",
							width = "full",
							multiline = true,
							get = function()
								return v.postfix or WidgetText.defaults.postfix
							end,
							set = function(info, val)
								v.postfix = v
								self:CreateLines()
							end,
							order = 3
						},
						precision = {
							name = "Precision",
							desc = "How precise displayed numbers are",
							type = "input",
							pattern = "%d",
							get = function()
								return tostring(v.precision or WidgetText.defaults.precision)
							end,
							set = function(info, val)
								v.precision = tonumber(val)
								self:CreateLines()
							end,
							order = 4
						},
						align = {
							name = "Alignment",
							desc = "The alignment information",
							type = "select",
							values = WidgetText.alignmentList,
							get = function()
								return WidgetText.alignmentDict[v.align]
							end,
							set = function(info, val)
								v.align = WidgetText.alignmentList[val]
								self:CreateLines()
							end,
							order = 5
						},
						update = {
							name = "Text Update",
							desc = "How often to update the text",
							type = "input",
							pattern = "%d",
							get = function()
								return tostring(v.update or WidgetText.defaults.update)
							end,
							set = function(info, val)
								v.update = tonumber(val)
								self:CreateLines()
							end,
							order = 6
						},
						speed = {
							name = "Scroll Speed",
							desc = "How fast to scroll the marquee",
							type = "input",
							pattern = "%d",
							get = function()
								return tostring(v.speed or WidgetText.defaults.speed)
							end,
							set = function(info, val)
								v.speed = tonumber(val)
								self:CreateLines()
							end,
							order = 7
						},
						direction = {
							name = "Direction",
							desc = "Which direction to scroll",
							type = "select",
							values = WidgetText.directionList,
							get = function()
								return tonumber(WidgetText.directionDict[v.direction]) or WidgetText.defaults.direction
							end,
							set = function(info, val)
								v.direction = WidgetText.directionList[val]
								self:CreateLines()
							end,
							order = 8
						},
						cols = {
							name = "Columns",
							desc = "How wide the marquee is",
							type = "input",
							pattern = "%d",
							get = function()
								return tostring(v.cols or WidgetText.defaults.cols)
							end,
							set = function(info, val)
								v.cols = tonumber(val)
								self:CreateLines()
							end,
							order = 9
						}
					},
					order = 9
				}
        }
		if v.desc then
			options["line" .. i].args.desc = {
				name = v.desc,
				type = "header",
				order = 1
			}
			
		end
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
        
    GameTooltip:Show()
	
	self.timer:Start()
end
