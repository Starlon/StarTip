local mod = StarTip:NewModule("UnitTooltip", "AceEvent-3.0")
mod.name = "Unit Tooltip"
mod.toggled = true
local LibProperty = LibStub("LibScriptableDisplayProperty-1.0", true)
assert(LibProperty, "Text module requires LibScriptableDisplayProperty-1.0")
local WidgetText = LibStub("LibScriptableDisplayWidgetText-1.0", true)
assert(WidgetText, "Text module requires LibScriptableDisplayWidgetText-1.0")
local LCDText = LibStub("LibScriptableDisplayLCDText-1.0", true)
assert(LCDText, mod.name .. " requires LibScriptableDisplayLCDText-1.0")
local LibCore = LibStub("LibScriptableDisplayCore-1.0", true)
assert(LibCore, mod.name .. " requires LibScriptableDisplayCore-1.0")
local LibTimer = LibStub("LibScriptableDisplayTimer-1.0", true)
assert(LibTimer, mod.name .. " requires LibScriptableDisplayTimer-1.0")
local LibEvaluator = LibStub("LibScriptableDisplayEvaluator-1.0", true)
assert(LibEvaluator, mod.name .. " requires LibScriptableDisplayEvaluator-1.0")
local UnitTooltipStats = LibStub("LibScriptableDisplayPluginUnitTooltipStats-1.0", true)
assert(UnitTooltipStats, mod.name .. " requires LibScriptableDisplayPluginUnitTooltipStats-1.0")

local _G = _G
local StarTip = _G.StarTip
local self = mod
local GameTooltip = _G.GameTooltip
local tinsert = _G.tinsert
local unpack = _G.unpack
local select = _G.select
local format = _G.format
local floor = _G.floor
local tostring = _G.tostring
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

local unit
local environment = StarTip.environment

local appearance = StarTip:GetModule("Appearance")

local function errorhandler(err)
    return geterrorhandler()(err)
end

local ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_MARQUEE, ALIGN_AUTOMATIC, ALIGN_PINGPONG = 1, 2, 3, 4, 5, 6

local SCROLL_RIGHT, SCROLL_LEFT = 1, 2

mod.NUM_LINES = 0

local function copy(src, dst)
	if type(src) ~= "table" then return nil end
	if type(dst) ~= "table" then dst = {} end
	for k, v in pairs(src) do
		if type(v) == "table" then
			v = copy(v)
		end
		dst[k] = v
	end
	return dst
end


local defaults = {profile={titles=true, empty = true, lines = {}, refreshRate = 500, color = {r = 1, g = 1, b = 1}}}

local defaultLines={
    [1] = {
        name = "UnitName",
        left = [[
local r, g, b
if UnitIsPlayer(unit) then
    r, g, b = ClassColor(unit)
else
    r, g, b = UnitSelectionColor(unit)
end
return Colorize(Name(unit), r, g, b)
]],
        right = nil,
		bold = true,
		enabled = true,
		cols = 80,
		leftOutlined = 3
    },
    [2] = {
        name = "Target",
        left = 'return "Target:"',
        right = [[
local r, g, b
local unit = (unit or "mouseover") .. "target"
if UnitIsPlayer(unit) then
    r, g, b = ClassColor(unit)
else
    r, g, b = UnitSelectionColor(unit)
end
local name = UnitName(unit)
local name2 = UnitName("player")
if name == name2 and Realm(unit) == Realm("player") then name = "<<YOU>>" end
return name and Colorize(name, r, g, b) or "None"
]],
        rightUpdating = true,
		update = 1000,
		enabled = true
    },
    [3] = {
        name = "Guild",
        left = 'return "Guild:"',
        right = [[
return Guild(unit, true)
]],
		enabled = true
    },
    [4] = {
        name = "Rank",
        left = 'return "Rank:"',
        right = [[
return Rank(unit)
]],
		enabled = true,
    },
    [5] = {
        name = "Realm",
        left = 'return "Realm:"',
        right = [[
return Realm(unit)
]],
		enabled = true
    },
    [6] = {
        name = "Level",
        left = 'return "Level:"',
        right = [[
local classification = Classification(unit)
local lvl = Level(unit)
local str = ""
local r, g, b
if classification then
    str = classification
end
if lvl then
    str = str .. " (" .. lvl .. ")"
end
str = Colorize(str, DifficultyColor(unit))
return str
]],
		enabled = true,
    },
	[7] = {
		name = "Gender",
		left = 'return "Gender:"',
		right = [[
local sex = UnitSex(unit)
if sex == 2 then
    return "Male"
elseif sex == 3 then
    return "Female"
end		
]],
		enabled = true
	},
    [8] = {
        name = "Race",
        left = 'return "Race:"',
        right = [[
return SmartRace(unit)
]],
		enabled = true,
    },
    [9] = {
        name = "Class",
        left = 'return "Class:"',
        right = [[
if UnitClass(unit) == UnitName(unit) then return end
local r, g, b
if UnitIsPlayer(unit) then
    r, g, b = ClassColor(unit)
else
    r, g, b = 1, 1, 1
end
return Colorize(UnitClass(unit), r, g, b)
]],
		enabled = true,
    },
	[10] = {
	name = "Druid Form",
	left = 'return "Form:"',
	right = [[
return DruidForm(unit)	
]],
	enabled = true
	},
    [11] = {
        name = "Faction",
        left = 'return "Faction:"',
        right = [[
return Faction(unit)
]],
		enabled = true,
    },
    [12] = {
        name = "Status",
        left = 'return "Status:"',
        right = [[
if not UnitIsConnected(unit) then
    return "Offline"
elseif HasAura(unit, GetSpellInfo(19752)) then
    return "Divine Intervention"
elseif UnitIsFeignDeath(unit) then
    return "Feigned Death"
elseif UnitIsGhost(unit) then
    return "Ghost"
elseif UnitIsDead(unit) and HasAura(unit, GetSpellInfo(20707)) then
    return "Soulstoned"
elseif UnitIsDead(unit) then
    return "Dead"
end
return "Alive"
]],
		enabled = true,
		update = 1000,
		rightUpdating = true
    },
    [13] = {
        name = "Health",
        left = 'return "Health:"',
        right = [[
if not UnitExists(unit) and self.Stop then self:Stop(); return self.lastHealth end
local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
local r, g, b = HPColor(health, maxHealth)
local value = "Unknown"
if maxHealth == 100 then
    value = Colorize(health .. "%", r, g, b)
elseif maxHealth ~= 0 then
    value = Colorize(format("%s/%s (%d%%)", short(health), short(maxHealth), health/maxHealth*100), r, g, b)
end
self.lastHealth = value
return value
]],
        rightUpdating = true,
		update = 1000,
		enabled = true
    },
    [14] = {
        name = "Mana",
        left = [[
return PowerName(unit)
]],
        right = [[
if not UnitExists(unit) and self.Stop then self:Stop(); return self.lastMana end
local mana = UnitMana(unit)
local maxMana = UnitManaMax(unit)
local r, g, b = PowerColor(nil, unit)
local value = "Unknown"
if maxMana == 100 then
    value = Colorize(tostring(mana), r, g, b)
elseif maxMana ~= 0 then
    value = Colorize(format("%s/%s (%d%%)", short(mana), short(maxMana), mana/maxMana*100), r, g, b)
end
self.lastMana = value
return value
]],
        rightUpdating = true,
		enabled = true,
		update = 1000
    },
	[15] = {
		name = "Effects",
		left = "return 'Effects'",
		right = [[
local name = Name(unit)
local str = ""
if UnitIsBanished(unit) then
	sre = sre .. "[Banished]"
end
if UnitIsCharmed(unit) then
	str = str .. "[Charmed]"
end
if UnitIsConfused(unit) then
	str = str .. "[Confused]"
end
if UnitIsDisoriented(unit) then
	str = str .. "[Disoriented]"
end
if UnitIsFeared(unit) then
	str = str .. "[Feared]"
end
if UnitIsFrozen(unit) then
	str = str .. "[Frozen]"
end
if UnitIsHorrified(unit) then
	str = str .. "[Horrified]"
end
if UnitIsIncapacitated(unit) then
	str = str .. "[Incapacitated]"
end
if UnitIsPolymorphed(unit) then
	str = str .. "[Polymorphed]"
end
if UnitIsSapped(unit) then
	str = str .. "[Sapped]"
end
if UnitIsShackled(unit) then
	str = str .. "[Shackled]"
end
if UnitIsAsleep(unit) then
	str = str .. "[Asleep]"
end
if UnitIsStunned(unit) then
	str = str .. "[Stunned]"
end
if UnitIsTurned(unit) then
	str = str .. "[Turned]"
end
if UnitIsDisarmed(unit) then
	str = str .. "[Disarmed]"
end
if UnitIsPacified(unit) then
	str = str .. "[Pacified]"
end
if UnitIsRooted(unit) then
	str = str .. "[Rooted]"
end
if UnitIsSilenced(unit) then
	str = str .. "[Silenced]"
end
if UnitIsEnsnared(unit) then
	str = str .. "[Ensnared]"
end
if UnitIsEnraged(unit) then
	str = str .. "[Enraged]"
end
if UnitIsWounded(unit) then
	str = str .. "[Wounded]"
end
if str == "" then
	return "Has Control"	
else
	return str
end
]],
		rightUpdating = true,
		enabled = true,
		update = 500,
	},
	[16] = {
		name = "Marquee",
		left = 'return "StarTip " .. _G.StarTip.version',
		leftUpdating = true,
		enabled = false,
		marquee = true,
		cols = 40,
		bold = true,
		align = WidgetText.ALIGN_MARQUEE,
		update = 1000,
		speed = 100,
		direction = WidgetText.SCROLL_LEFT,
		dontRtrim = true
	},
	[17] = {
		name = "Memory Usage",
		left = "return 'Memory Usage:'",
		right = [[
local mem, percent, memdiff, totalMem, totaldiff, memperc = GetMemUsage("StarTip", true)
if mem then
    local num = floor(memperc)
    if num < 1 then num = 1 end
    if num > 100 then num = 100 end
    local r, g, b = gradient[num][1], gradient[num][2], gradient[num][3]
    return Colorize(format("%s (%.2f%%)", memshort(mem), memperc), r, g, b)
end
]],
		rightUpdating = true,
		update = 1000
	},
	[18] = {
		name = "CPU Usage",
		desc = "Note that you must turn on CPU profiling",
		left = 'return "CPU Usage:"',
		right = [[
local cpu, percent, cpudiff, totalCPU, totaldiff, cpuperc = GetCPUUsage("StarTip", true)
if cpu then
    local num = floor(cpuperc)
    if num < 1 then num = 1 end
    if num > 100 then num = 100 end
    local r, g, b = gradient[num][1], gradient[num][2], gradient[num][3]
    return Colorize(format("%s (%.2f%%)", timeshort(cpu), cpuperc), r, g, b)
end
]],
		rightUpdating = true,
		update = 1000
	},
	[19] = {
		name = "Talents",
		left = "return 'Talents:'",
		right = [[
return SpecText(unit)
]],
		rightUpdating = true,
		enabled = true,
		update = 1000
	},
	[20] = {
		name = "Current Role",
		left = [[
return "Current Role:"		
]],
		right = [[
return GetRole(unit)
]],
		rightUpdating = true,
		enabled = true,
		update = 1000
	},
	[21] = {
		name = "Old Role",
		left = [[
return "Old Role:"
]],
		right = [[
return select(2, GetRole(unit))
]],
		rightUpdating = true,
		enabled = true,
		update = 1000
	},
	[22] = {
		name = "Zone",
		left = [[
return "Zone:"
]],
		right = [[
return select(6, UnitGuildInfo(unit))
]],
		enabled = true
	},
	[23] = {
		name = "Location",
		left = [[
return "Location:"
]],
		right = [[
return select(3, GetUnitTooltipStats(unit))
]],
		enabled = true
	},
	[24] = {
		name = "Range",
		left = [[
local min, max = RangeCheck:GetRange(unit)
if not min then
    return "No range info"
elseif not max then
    return format("Target is over %d yards", min)
else
    return "Between " .. min .. " and " .. max .. " yards"
end
]],
		leftUpdating = true,
		enabled = true,
		update = 1000
	},
	[25] = {
		name = "Guild Note",
		left = [[
return "Guild Note:"
]],
		right = [[
return select(7, UnitGuildInfo(unit))
]],
		enabled = true
	},
	[26] = {
		name = "Main Name",
		left = [[
-- This requires Chatter
return "Main:"
]],
		right = [[
if not _G.Chatter then return end
local mod = _G.Chatter:GetModule("Alt Linking")
local name = UnitName(unit)
return mod.db.realm[name]
]],
		enabled = true
	},
	[27] = {
		name = "DPS",
		left = [[
return "DPS:"
]],
		right = [[
return UnitDPS(unit)
]],
		enabled = true
	},
	[28] = {
		name = "Skada DPS",
		left = [[
return "Skada DPS:"
]],
		right = [[
local dps = SkadaUnitDPS(unit)
if dps then
    return format("%d", dps)
end
]],
		enabled = true
	}
}

local options = {}

function mod:ReInit()
	self:ClearLines()
	self.db.profile.lines = {}
	for k, v in ipairs(defaultLines) do
		for j, vv in ipairs(self.db.profile.lines) do
			vv.colorLeft = nil
			vv.colorRight = nil
			if v.name == vv.name then
				for k, val in pairs(v) do
					if v[k] ~= vv[k] and not vv[k.."Dirty"] then
						vv[k] = v[k]
					end
				end
				v.tagged = true
			end
		end
	end

	for k, v in ipairs(defaultLines) do
		if not v.tagged and not v.deleted then
			tinsert(self.db.profile.lines, copy(v))
		end
	end
	self:CreateLines()
end

function mod:OnInitialize()
    self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)

	self:ReInit()
	
    self.leftLines = StarTip.leftLines
    self.rightLines = StarTip.rightLines
    self:RegisterEvent("UPDATE_FACTION")
    StarTip:SetOptionsDisabled(options, true)

	self.core = StarTip.core --LibCore:New(mod, environment, self:GetName(), {[self:GetName()] = {}}, "text", StarTip.db.profile.errorLevel)
	environment.core = self.core
	
	if ResourceServer then ResourceServer:New(environment) end
	--self.lcd = LCDText:New(self.core, 1, 40, 0, 0, 0, StarTip.db.profile.errorLevel)
	--self.core.lcd = self.lcd

	self.evaluator = LibEvaluator:New(environment, StarTip.db.profile.errorLevel)
end

local draw
local update
function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
	if self.db.profile.refreshRate > 0 then
		self.timer = LibTimer:New("Text module", self.db.profile.refreshRate, true, draw, nil, self.db.profile.errorLevel, self.db.profile.durationLimit)
	end
end

function mod:OnDisable()
    StarTip:SetOptionsDisabled(options, true)
	if self.timer then self.timer:Del() end
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

local widgetsToDraw = {}
local function updateWidget(widget)
	tinsert(widgetsToDraw, widget)
	if mod.db.profile.refreshRate == 0 then
		draw(UnitExists(StarTip.unit))
	end
end

do
	local fontsList = LSM:List("font")
	local widget, fontString
	function draw(show)
		if StarTip.fading then
			table.wipe(widgetsToDraw)
			return
		end
		for i, widget in ipairs(widgetsToDraw) do
			if not widget.fontString then break end
			local fontString = widget.fontString
			fontString:SetText(widget.buffer)

			font = LSM:Fetch("font", fontsList[appearance.db.profile.font])
			local filename, fontHeight, flags = fontString:GetFont()
			if widget.config.outlined and widget.config.outlined > 1 then
				if widget.config.outlined == 2 then
					fontString:SetFont(filename, fontHeight, "OUTLINED")
				elseif widget.config.outlined == 3 then
					fontString:SetFont(filename, fontHeight, "THICKOUTLINED")
				end
			end
		end
		table.wipe(widgetsToDraw)
		if UnitExists(StarTip.unit) then
			GameTooltip:Show()
		end
	end
end

function mod:ClearLines()
	for k, v in pairs(lines) do
		if v.leftObj then
			v.leftObj:Stop()
		end
		if v.rightObj then
			v.rightObj:Stop()
		end
	end
	wipe(lines)
end

local tbl
function mod:CreateLines()
    local llines = {}
	local j = 0
    for i, v in ipairs(self.db.profile.lines) do
		if not v.deleted then
			j = j + 1
			llines[j] = copy(v)
			llines[j].config = copy(v)
		end
    end
	self:ClearLines()
    lines = setmetatable(llines, {__call=function(self)
        local lineNum = 0
		GameTooltip:ClearLines()
        for i, v in ipairs(self) do
			if v.enabled and not v.deleted then
                local left, right, c, cc = '', ''
				environment.unit = StarTip.unit
				environment.self = mod
				v.config.unit = StarTip.unit
                if v.right and v.right ~= "" then
                    right = mod.evaluator.ExecuteCode(environment, v.name .. " right", v.right)
                    left = mod.evaluator.ExecuteCode(environment, v.name .. " left", v.left)
					if right == "" then right = "nil" end
                else
                    right = ''
                    left = mod.evaluator.ExecuteCode(environment, v.name .. " left", v.left)
                end
				environment.unit = nil
				environment.self = mod

                if left and left ~= "" and right ~= "nil" then
					StarTip.addingLine = true
                    lineNum = lineNum + 1
                    if v.right then
						GameTooltip:AddDoubleLine(' ', ' ', mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b, mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b)

						--if not v.leftObj or v.lineNum ~= lineNum then
							v.config.value = v.left
							v.config.outlined = v.leftOutlined
							local tmp = v.update
							if not v.leftUpdating then v.update = 0 end

							v.leftObj = v.leftObj or WidgetText:New(mod.core, v.name .. "left", copy(v.config), 0, 0, v.layer or 0, StarTip.db.profile.errorLevel, updateWidget)
							v.update = tmp
						--end
						--if not v.rightObj or v.lineNum ~= lineNum then
							v.config.value = v.right
							v.config.outlined = v.rightOutlined
							local tmp = v.update
							if not v.rightUpdating then v.update = 0 end
							v.rightObj = v.rightObj or WidgetText:New(mod.core, v.name .. "right", copy(v.config), 0, 0, v.layer or 0, StarTip.db.profile.errorLevel, updateWidget)
							v.update = tmp
						--end
						v.leftObj.fontString = mod.leftLines[lineNum]
						v.rightObj.fontString = mod.rightLines[lineNum]
                    else
						GameTooltip:AddLine(' ', mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b)

						v.config.value = v.left
						v.config.outlined = v.leftOutlined
						local tmp = v.update
						if not v.leftUpdating then v.update = 0 end
						v.leftObj = v.leftObj or WidgetText:New(mod.core, v.name, copy(v.config), 0, 0, 0, StarTip.db.profile.errorLevel, updateWidget)
						v.update = tmp
						v.leftObj.fontString = mod.leftLines[lineNum]
                    end
					if v.rightObj then
						v.rightObj.config.unit = StarTip.unit
						v.rightObj:Start()
					end
					if v.leftObj then
						v.leftObj.config.unit = StarTip.unit
						v.leftObj:Start()
					end
					StarTip.addingLine = false
					v.lineNum = lineNum
				end
			end

        end
        mod.NUM_LINES = lineNum
		draw()
		GameTooltip:Show()
    end})
end

--[[
function mod:OnHide()
	for i, v in ipairs(lines) do
		if v.leftObj then
			v.leftObj:Stop()
		end
		if v.rightObj then
			v.rightObj:Stop()
		end
	end
	if self.timer then
		self.timer:Stop()
	end
end
]]

function mod.OnHide()
	for i, v in ipairs(lines) do
		if v.leftObj then
			v.leftObj:Stop()
		end
		if v.rightObj then
			v.rightObj:Stop()
		end
	end
	if self.timer then
		self.timer:Stop()
	end
end

local function escape(text)
	return text:replace("|","||")
end

local function unescape(text)
	return text:replace("||", "|")
end

function mod:RebuildOpts()
    options = {
		add = {
			name = "Add Line",
			desc = "Give the line a name",
			type = "input",
			set = function(info, v)
				if v == "" then return end
				tinsert(self.db.profile.lines, {name = v, left = "", right = "", rightUpdating = false, enabled = true})
				self:RebuildOpts()
				StarTip:RebuildOpts()
				self:ClearLines()
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
			set = function(info, v)
				self.db.profile.refreshRate = tonumber(v)
				self:OnDisable()
				self:OnEnable()
			end,
			order = 6
		},
		color = {
			name = "Default Color",
			desc = "The default color for tooltip lines",
			type = "color",
			get = function() return self.db.profile.color.r, self.db.profile.color.g, self.db.profile.color.b end,
			set = function(info, r, g, b)
				self.db.profile.color.r = r
				self.db.profile.color.g = g
				self.db.profile.color.b = b
			end,
			order = 7
		},
		defaults = {
			name = "Restore Defaults",
			desc = "Roll back to defaults.",
			type = "execute",
			func = function()
				local replace = {}
				for i, v in ipairs(self.db.profile.lines) do
					local insert = true
					for j, vv in ipairs(defaultLines) do
						if v.name == vv.name then
							insert = false
						end
					end
					if insert then
						tinsert(replace, v)
					end
				end
				table.wipe(self.db.profile.lines)
				for i, v in ipairs(defaultLines) do
					tinsert(self.db.profile.lines, copy(v))
				end
				for i, v in ipairs(replace) do
					tinsert(self.db.profile.lines, copy(v))
				end
				StarTip:RebuildOpts()
				self:CreateLines()
			end,
			order = 9
		},
	}
    for i, v in ipairs(self.db.profile.lines) do
		if type(v) == "table" and not v.deleted then
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
							v.enabledDirty = true
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
							if v.update == 0 then
								v.update = 500
							end
							v.leftUpdatingDirty = true
							self:CreateLines()
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
							if v.update == 0 then
								v.update = 500
							end
							v.rightUpdatingDirty = true
							self:CreateLines()
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
							if tmp.deleted then return end
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
						set = function(info, val)
							v.bold = val
							v.boldDirty = true
							self:CreateLines()
						end,
						order = 7
					},
					leftOutlined = {
						name = "Left Outlined",
						desc = "Whether the left widget is outlined or not",
						type = "select",
						values = {"None", "Outlined", "Thick Outlilned"},
						get = function() return v.leftOutlined or 1 end,
						set = function(info, val)
							v.leftOutlined = val
							v.leftOutlinedDirty = true
							self:CreateLines()
						end,
						order = 8
					},
					rightOutlined = {
						name = "Right Outlined",
						desc = "Whether the right widget is outlined or not",
						type = "select",
						values = {"None", "Outlined", "Thick Outlilned"},
						get = function() return v.rightOutlined or 1 end,
						set = function(info, val)
							v.rightOutlined = val
							v.rightOutlinedDirty = true
							self:CreateLines()
						end,
						order = 9					
					},
					delete = {
						name = "Delete",
						desc = "Delete this line",
						type = "execute",
						func = function()
							local name = v.name
							local delete = true
							for i, line in ipairs(defaultLines) do
								if line.name == name then
									delete = false
								end
							end
							tremove(self.db.profile.lines, i)
							if not delete then
								wipe(v)
								v.deleted = true
								v.name = name
								tinsert(self.db.profile.lines, v)
							end
							StarTip:RebuildOpts()
							self:ClearLines()
							self:CreateLines()
						end,
						order = 10
					},
					linesHeader = {
						name = "Lines",
						type = "header",
						order = 11
					},
					left = {
						name = "Left",
						type = "input",
						desc = "Left text code",
						get = function() return escape(v.left or "") end,
						set = function(info, val)
							v.left = unescape(val)
							v.leftDirty = true
							if val == "" then v.left = nil end
							self:CreateLines()
						end,
						--[[validate = function(info, str)
							return mod.evaluator:Validate(environment, str)
						end,]]
						multiline = true,
						width = "full",
						order = 12
					},
					right = {
						name = "Right",
						type = "input",
						desc = "Right text code",
						get = function() return escape(v.right or "") end,
						set = function(info, val)
							v.right = unescape(val);
							v.rightDirty = true
							if val == "" then v.right = nil end
							self:CreateLines()
						end,
						multiline = true,
						width = "full",
						order = 13
					},
					marquee = {
						name = "Enhanced Settings",
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
									v.marqueeDirty = true
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
									v.prefixDirty = true
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
									v.postfixDirty = true
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
									v.precisionDirty = true
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
									return v.align
								end,
								set = function(info, val)
									v.align = val
									v.alignDirty = true
									self:CreateLines()
								end,
								order = 5
							},
							update = {
								name = "Text Update",
								desc = "How often to update the text. Use this option if you want your line to update.",
								type = "input",
								pattern = "%d",
								get = function()
									return tostring(v.update or WidgetText.defaults.update)
								end,
								set = function(info, val)
									v.update = tonumber(val)
									v.updateDirty = true
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
									v.speedDirty = true
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
									return v.direction or WidgetText.defaults.direction
								end,
								set = function(info, val)
									v.direction = val
									v.directionDirty = true
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
									v.colsDirty = true
									self:CreateLines()
								end,
								order = 9
							},
							dontRtrim = {
								name = "Don't right trim",
								desc = "Prevent trimming white space to the right of text",
								type = "toggle",
								get = function()
									return v.dontRtrim or WidgetText.defaults.dontRtrim
								end,
								set = function(info, val)
									v.dontRtrim = val
									v.dontRtrimDirty = true
									self:CreateLines()
								end,
								order = 10
							}
						},
						order = 9
					}
			}
		end
		--[[if v.desc then
			options["line" .. i].args.desc = {
				name = v.desc,
				type = "header",
				order = 1
			}

		end]]
    end
end

local plugin = LibStub("LibScriptableDisplayPluginString-1.0")
local ff = CreateFrame("Frame")
function mod:SetUnit()
	
    if ff:GetScript("OnUpdate") then ff:SetScript("OnUpdate", nil) end

	self.NUM_LINES = 0
	
    -- Taken from CowTip
    local lastLine = 2
    local text2 = self.leftLines[2]:GetText()

    if not text2 then
        lastLine = lastLine - 1
    elseif not text2:find("^"..LEVEL) then
        lastLine = lastLine + 1
    end
    if not UnitPlayerControlled(StarTip.unit) and not UnitIsPlayer(StarTip.unit) then
        local factionText = self.leftLines[lastLine + 1]:GetText()
        if factionText == PVP then
            factionText = nil
        end
        if factionText and (factionList[factionText] or UnitFactionGroup(StarTip.unit)) then
            lastLine = lastLine + 1
        end
    end
    if not UnitIsConnected(StarTip.unit) or not UnitIsVisible(StarTip.unit) or UnitIsPVP(StarTip.unit) then
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
	
	lines()

	if self.db.profile.refreshRate > 0 and self.timer then
		self.timer:Start()
	end
	
	self:RefixEndLines()
	
	GameTooltip:Show()

end

function mod:RefixEndLines()
    -- Another part taken from CowTip
    for i, left in ipairs(linesToAdd) do
		local left = linesToAdd[i]
        local right = linesToAddRight[i]
		StarTip.addingLine = true
        if right then
            GameTooltip:AddDoubleLine(left, right, linesToAddR[i], linesToAddG[i], linesToAddB[i], linesToAddRightR[i], linesToAddRightG[i], linesToAddRightB[i])
        else
            GameTooltip:AddLine(left, linesToAddR[i], linesToAddG[i], linesToAddB[i], true)
        end
		StarTip.addingLine = false
    end
	wipe(linesToAdd)
	wipe(linesToAddR)
	wipe(linesToAddG)
	wipe(linesToAddB)
	wipe(linesToAddRight)
	wipe(linesToAddRightR)
	wipe(linesToAddRightG)
	wipe(linesToAddRightB)
end