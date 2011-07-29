local mod = StarTip:NewModule("UnitTooltip", "AceEvent-3.0")
mod.name = "Unit Tooltip"
mod.toggled = true
local WidgetText = LibStub("LibScriptableWidgetText-1.0", true)
assert(WidgetText, "Text module requires LibScriptableWidgetText-1.0")
local LCDText = LibStub("LibScriptableLCDText-1.0", true)
assert(LCDText, mod.name .. " requires LibScriptableLCDText-1.0")
local LibCore = LibStub("LibScriptableLCDCore-1.0", true)
assert(LibCore, mod.name .. " requires LibScriptableLCDCore-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
assert(LibTimer, mod.name .. " requires LibScriptableUtilsTimer-1.0")
local LibEvaluator = LibStub("LibScriptableUtilsEvaluator-1.0", true)
assert(LibEvaluator, mod.name .. " requires LibScriptableUtilsEvaluator-1.0")
local _G = _G
local StarTip = _G.StarTip
local L = StarTip.L
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
mod.lines = lines
local environment = StarTip.environment
local appearance = StarTip:GetModule("Appearance")
local function errorhandler(err)
    return geterrorhandler()(err)
end
local ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_MARQUEE, ALIGN_AUTOMATIC, ALIGN_PINGPONG = 1, 2, 3, 4, 5, 6
local SCROLL_RIGHT, SCROLL_LEFT = 1, 2
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
local defaults = {profile={titles=true, empty = true, lines = {}, refreshRate = 0, color = {r = 1, g = 1, b = 1}}}
local defaultLines={
    [1] = {
        name = "UnitName",
        left = [[
local r, g, b
if UnitIsPlayer(unit) then
    r, g, b = ClassColor(unit)
else
    if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
        r, g, b = .5, .5, .5
    else
        r, g, b = UnitSelectionColor(unit)
    end
end
local afk = AFK(unit)
if afk then
    afk = " " .. Angle(afk)
else
    afk = ""
end
local dnd = DND(unit)
if dnd and afk == "" then
    afk = " " .. Angle(dnd)
end
local offline = Offline(unit)
if offline then
    afk = " " .. Angle(offline)
end
local port = StarTip:GetModule("Portrait")
local texture  = ""
if port and port.texture then
	texture = port.texture:GetTexture()	
end
if texture ~= "" then
	texture = Texture("", port.db.profile.size) .. " "
end
return texture .. Colorize((Name(unit, true) or Name(unit)) .. afk , r, g, b)
]],
        right = nil,
        bold = true,
        enabled = true,
        cols = 80,
        leftOutlined = 3,
	leftUpdating = true,
	update = 500
    },
    [2] = {
        name = "Target",
        left = 'return L["Target:"]',
        right = [[
-- Here's an example of how to deal with DogTag support.
-- Note that you have to consider which quote characters
-- you are using to contain the entire dog tag within,
-- as opposed what you're using inside. Here I'm using `'` surrounding 
-- everything, and I'm using `"` within the dog tag itself.
-- Also, each new line inside a string should end with a '\'.
-- Also note; you'll have to "escape" where you wish to enter a '\' character
-- inside your dog tag. Do that by repeating the '\' character.
-- Example: return "\\ FOO \\"
-- Would print "\ FOO \"
if not UnitExists(unit) then return L["None"] end

local dt = '\
[IsPlayer and "<YOU>":ClassColor or Color(Name, %f, %f, %f)  \
(if PvP then \
 "++":Red \
end)]'

local r, g, b
if UnitIsPlayer(unit) then
    r, g, b = ClassColor(unit)
else
    r, g, b = UnitSelectionColor(unit)
end

return dt:format(r, g, b)
]],
	unitOverride = "mouseovertarget",
        rightUpdating = true,
	leftUpdating = true,
        update = 500,
        enabled = true,
	dogtag = true
    },
    [3] = {
        name = L["Guild"],
        left = 'return L["Guild:"]',
        right = [[
return Guild(unit, true)
]],
        enabled = true
    },
    [4] = {
        name = L["Rank"],
        left = 'return L["Rank:"]',
        right = [[
local rank = Rank(unit)
local index = RankIndex(unit)
if rank then
  return format("%s (%d)", rank, index)
end
]],
        enabled = true,
    },
    [5] = {
        name = L["Realm"],
        left = 'if Realm(unit) then return L["Realm:"] end',
        right = [[
return Realm(unit)
]],
        enabled = true
    },
    [6] = {
        name = L["Level"],
        left = 'return L["Level:"]',
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
        name = L["Gender"],
        left = 'return L["Gender:"]',
        right = [[
local sex = UnitSex(unit)
if sex == 2 then
    return L["Male"]
elseif sex == 3 then
    return L["Female"]
end
]],
        enabled = true
    },
    [8] = {
        name = L["Race"],
        left = 'return L["Race:"]',
        right = [[
return SmartRace(unit)
]],
        enabled = true,
    },
    [9] = {
        name = "Class",
        left = 'return L["Class:"]',
        right = [[
local class, tag = UnitClass(unit)
if class == UnitName(unit) then return end
local r, g, b
if UnitIsPlayer(unit) then
    r, g, b = ClassColor(unit)
else
    r, g, b = 1, 1, 1
end
return Texture(format("Interface\\Addons\\StarTip\\Media\\icons\\%s.tga", tag), 16) .. Colorize(" " .. class, r, g, b)
]],
        enabled = true,
        cols = 100
    },
    [10] = {
        name = L["Druid Form"],
        left = 'return L["Form:"]',
        right = [[
return DruidForm(unit)
]],
        enabled = true
    },
    [11] = {
        name = L["Faction"],
        left = 'return L["Faction:"]',
        right = [[
return Faction(unit)
]],
        enabled = true,
    },
    [12] = {
        name = L["Status"],
        left = 'return L["Status:"]',
        right = [[
if not UnitIsConnected(unit) then
    return L["Offline"]
elseif HasAura(unit, GetSpellInfo(19752)) then
    return L["Divine Intervention"]
elseif UnitIsFeignDeath(unit) then
    return L["Feigned Death"]
elseif UnitIsGhost(unit) then
    return L["Ghost"]
elseif UnitIsDead(unit) and HasAura(unit, GetSpellInfo(20707)) then
    return L["Soulstoned"]
elseif UnitIsDead(unit) then
    return L["Dead"]
end
return L["Alive"]
]],
        enabled = true,
    },
    [13] = {
        name = L["Health"],
        left = 'return L["Health:"]',
        right = [[
if not UnitExists(unit) then self:Stop(); return self.lastHealth end
local health, maxHealth = HP(unit), MaxHP(unit)
local r, g, b = HPColor(health, maxHealth)
local value = L["Unknown"]
if maxHealth == 100 then
    value = Colorize(health .. "%", r, g, b)
elseif maxHealth ~= 0 then
    value = Colorize(format("%s/%s (%d%%)", Short(health, true), Short(maxHealth, true), health/maxHealth*100), r, g, b)
end
self.lastHealth = value
return value
]],
        rightUpdating = true,
        update = 1000,
        enabled = true
    },
    [14] = {
        name = L["Mana"],
        left = [[
return PowerName(unit)
]],
        right = [[
if not UnitExists(unit) then self:Stop(); return self.lastMana end
local mana = Power(unit)
local maxMana = MaxPower(unit)
local r, g, b = PowerColor(nil, unit)
local h, s, v = RGB2HSV(r, g, b)
s = .5
r, g, b = HSV2RGB(h, s, v)
local value = L["Unknown"]
if maxMana == 100 or maxMana == 120 then
    value = Colorize(tostring(mana), r, g, b)
elseif maxMana ~= 0 then
    value = Colorize(format("%s/%s (%d%%)", Short(mana, true), Short(maxMana, true), mana/maxMana*100), r, g, b)
end
self.lastMana = value
return value
]],
        rightUpdating = true,
        enabled = true,
        update = 1000,
	colorR = "",
    },
    [15] = {
        name = L["Effects"],
        left = 'return L["Effects:"]',
        right = [[
local name = Name(unit)
local str = ""
if UnitIsBanished(unit) then
    str = str .. Angle(L["Banished"])
end
if UnitIsCharmed(unit) then
    str = str .. Angle(L["Charmed"])
end
if UnitIsConfused(unit) then
    str = str .. Angle(L["Confused"])
end
if UnitIsDisoriented(unit) then
    str = str .. Angle(L["Disoriented"])
end
if UnitIsFeared(unit) then
    str = str .. Angle(L["Feared"])
end
if UnitIsFrozen(unit) then
    str = str .. Angle(L["Frozen"])
end
if UnitIsHorrified(unit) then
    str = str .. Angle(L["Horrified"])
end
if UnitIsIncapacitated(unit) then
    str = str .. Angle(L["Incapacitated"])
end
if UnitIsPolymorphed(unit) then
    str = str .. Angle(L["Polymorphed"])
end
if UnitIsSapped(unit) then
    str = str .. Angle(L["Sapped"])
end
if UnitIsShackled(unit) then
    str = str .. Angle(L["Shackled"])
end
if UnitIsAsleep(unit) then
    str = str .. Angle(L["Asleep"])
end
if UnitIsStunned(unit) then
    str = str .. Angle(L["Stunned"])
end
if UnitIsTurned(unit) then
    str = str .. Angle(L["Turned"])
end
if UnitIsDisarmed(unit) then
    str = str .. Angle(L["Disarmed"])
end
if UnitIsPacified(unit) then
    str = str .. Angle(L["Pacified"])
end
if UnitIsRooted(unit) then
    str = str .. Angle(L["Rooted"])
end
if UnitIsSilenced(unit) then
    str = str .. Angle(L["Silenced"])
end
if UnitIsEnsnared(unit) then
    str = str .. Angle(L["Ensnared"])
end
if UnitIsEnraged(unit) then
    str = str .. Angle(L["Enraged"])
end
if UnitIsWounded(unit) then
    str = str .. Angle(L["Wounded"])
end
if str == "" then
    return L["Has Control"]
else
    return str
end
]],
        rightUpdating = true,
        enabled = true,
        update = 500,
    },
    [16] = {
        name = L["Marquee"],
        left = 'return "StarTip " .. StarTip.version',
        leftUpdating = true,
        enabled = false,
        marquee = true,
        cols = 40,
        bold = true,
        align = WidgetText.ALIGN_MARQUEE,
        update = 1000,
        speed = 200,
        direction = WidgetText.SCROLL_LEFT,
        dontRtrim = true,
	colorL = "return random(), random(), random(), 1"
    },
    [17] = {
        name = L["Memory Usage"],
        left = "return L['Memory Usage:']",
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
        name = L["CPU Usage"],
        desc = L["Note that you must turn on CPU profiling"],
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
        name = L["Talents"],
        left = "return L['Talents:']",
        right = [[
if not UnitExists(unit) then return lastTalents end
local str = SpecText(unit)
local ilvl = UnitILevel(unit, true)
if ilvl then
    str = format("%s (%s ilvl)", str, ilvl)
end
lastTalents = str
return str
]],
        rightUpdating = true,
        enabled = true,
        cols = 180,
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
        update = 1000,
        deleted = true
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
        update = 1000,
        deleted = true
    },
    [22] = {
        name = "Avg Item Level",
        left = [[
if not UnitExists(unit) then return "" end
return "Item Level:"
]],
        right = [[
if not UnitExists(unit) then return "" end
return UnitILevel(unit)
]],
        rightUpdating = true,
        enabled = true,
        update = 1000,
        deleted = true
    },
    [23] = {
        name = L["Zone"],
        left = [[
-- This doesn't work. Leaving it here for now.
return L["Zone:"]
]],
        right = [[
return select(6, UnitGuildInfo(unit))
]],
        enabled = false
    },
    [24] = {
        name = L["Location"],
        left = [[
return L["Location:"]
]],
        right = [[
return select(3, GetUnitTooltipScan(unit))
]],
        enabled = true
    },
    [25] = {
        name = L["Range"],
        left = [[
if not UnitExists(unit) then return lastRange end
local min, max = RangeCheck:GetRange(unit)
local str
if not min then
    str = ""
elseif not max then
    str = format(L["Target is over %d yards"], min)
else
    str = format(L["Between %s and %s yards"], min, max)
end
lastRange = str
return str
]],
        leftUpdating = true,
        enabled = true,
        update = 500
    },
    [26] = {
        name = L["Movement"],
        left = [[
if not UnitExists(unit) then return lastMovement end
local pitch = GetUnitPitch(unit)
local speed = GetUnitSpeed(unit)
local str = ""
if abs(pitch) > .01 then
    str = format("Pitch: %.1f", pitch)
end
if speed > 0 then
    if str ~= "" then
        str = str .. " - "
    end
    str = str .. format("Speed: %.1f", speed)
end
lastMovement = str
return str
]],
        leftUpdating = true,
        enabled = true,
        update = 500
    },
    [27] = {
        name = L["Guild Note"],
        left = [[
return L["Guild Note:"]
]],
        right = [[
return select(7, UnitGuildInfo(unit))
]],
        enabled = true
    },
    [28] = {
        name = L["Main"],
        left = [[
-- This requires Chatter
return L["Main:"]
]],
        right = [[
if not _G.Chatter then return end
local mod = _G.Chatter:GetModule("Alt Linking")
local name = UnitName(unit)
return mod.db.realm[name]
]],
        enabled = true
    },
    [29] = {
        name = "Recount",
        left = [[
return "Recount:"
]],
right = [[
local val, perc, persec, maxvalue, total = RecountUnitData(unit)
if val and val ~= 0 then
    local p = total ~= 0 and (val / maxvalue) or 1
    local r, g, b = Gradient(p)
    local prefix=""
    if persec then
        prefix = persec .. ", "
    end
    return Colorize(string.format("%d (%s%d%%)", val, prefix, perc), r, g, b)
end
]],
        enabled = true,
        rightUpdating = true,
        update = 1000
    },
    [30] = {
        name = "DPS",
        left = [[
return "DPS:"
]],
        right = [[
return UnitDPS(unit)
]],
        enabled = true,
        rightUpdating = true,
        update = 1000
    },
    [31] = {
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
        enabled = true,
        rightUpdating = true,
        update = 1000
    },
    [32] = {
        name = L["Spell Cast"],
        left = [[
local cast_data = CastData(unit)
if cast_data then
    if cast_data.channeling then
        return L["Channeling:"]
    end
    return L["Casting:"]
end
return ""
]],
        right = [[
local cast_data = CastData(unit)
if cast_data then
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target
  local stop_time,stop_duration = cast_data.stop_time
  local i = -1
  if cast_data.casting then
    local start_time = cast_data.start_time
    i = (GetTime() - start_time) / (cast_data.end_time - start_time) * 100
  elseif cast_data.channeling then
    local end_time = cast_data.end_time
    i = (end_time - GetTime()) / (end_time - cast_data.start_time) * 100
  end
  local icon = Texture(format("Interface\\Addons\\StarTip\\Media\\gradient\\gradient-%d.blp", i), 12) .. " "
  
  if stop_time then
    stop_duration = GetTime() - stop_time
  end
  Alpha(-(stop_duration or 0) + 1)
  
  if stop_message then
    return stop_message
  elseif target then
    return icon .. format("%s (%s)",spell,target)
  else
    return icon .. spell 
  end
end
]],
        enabled = true,
        cols = 100,
        rightUpdating = true,
        update = 500
    },
    [33] = {
        name = L["Fails"],
        left = [[
local fails = NumFails(unit)
if fails and fails > 0 then
  return format(L["Fails: %d"], fails)
end
]],
        enabled = true
    },
    [34] = {
        name = L["Threat"],
        left = [[
local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation(unit, "target")
if not threatpct then return "" end
isTanking = isTanking and 0 or 1
return Colorize(format("%s: %d%% (%.2f%%)", L["Threat"], threatpct, rawthreatpct), 1, isTanking, isTanking)
]],
        enabled = true,
        update = 300,
        leftUpdating = true
    },
    [35] = {
        name = L["Feats"],
        left = [[
return L["Feats:"]; 
]],
        right = [[
if UnitExists(unit) and not UnitIsPlayer(unit) then return end
if not UnitExists(unit) then return lastFeats end
local feats = UnitFeats(unit)
local txt
if feats and feats > 0 then
    self:Stop()
    txt = feats
else
    txt = L["Loading Achievements..."]
end
lastFeats = txt
return txt
]],
        enabled = true,
        update = 500,
        rightUpdating = true
    },
    [36] = {
        name = L["PVP Rank"],
        left = [[
return L["PVP Rank:"]; 
]],
		right = [[
if UnitExists(unit) and not UnitIsPlayer(unit) then return end
if not UnitExists(unit) then return lastPVPRank end
lastPVPRank = PVPRank(unit)
return lastPVPRank	
]],
        enabled = true,
        update = 300,
        rightUpdating = true,
        cols = 50
    },
    [37] = {
        name = L["Arena 2s"],
		left = [[
if not UnitExists(unit) then return lastArena2 end
lastArena2 =  ArenaTeam(unit, 2)	
return lastArena2
]],
        enabled = true,
        update = 300,
        leftUpdating = true,
        cols = 100
    },
    [38] = {
        name = L["Arena 3s"],
		left = [[
if not UnitExists(unit) then return lastArena3 end
lastArena3 = ArenaTeam(unit, 3)	
return lastArena3
]],
        enabled = true,
        update = 300,
        leftUpdating = true,
        cols = 100
    },
    [39] = {
        name = L["Arena 5s"],
		left = [[
if not UnitExists(unit) then return lastArena5 end
lastArena5 = ArenaTeam(unit, 5)
return lastArena5
]],
        enabled = true,
        update = 300,
        leftUpdating = true,
        cols = 100
    }
}
for i, v in ipairs(defaultLines) do
    v.default = true
end
local options = {}
function mod:ReInit()
    self:ClearLines()
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
                v.default = true
            end
        end
    end
    for k, v in ipairs(defaultLines) do
        if not v.tagged then
            tinsert(self.db.profile.lines, copy(v))
        end
    end
    self:CreateLines()
end
function mod:OnInitialize()
    self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
    self.leftLines = StarTip.leftLines
    self.rightLines = StarTip.rightLines
    self:RegisterEvent("UPDATE_FACTION")
    StarTip:SetOptionsDisabled(options, true)
    self.core = StarTip.core
    self.evaluator = LibEvaluator
    self:ReInit()
end

local draw
local update
function mod:OnEnable()
    StarTip:SetOptionsDisabled(options, false)
    self.timer = LibTimer:New("Text module", self.db.profile.refreshRate, true, draw, nil, self.db.profile.errorLevel)
    self.trunkTimer = LibTimer:New("Text trunk timer", 500, true, self.AppendTrunk, self, self.db.profile.errorLevel)
end

function mod:OnDisable()
    StarTip:SetOptionsDisabled(options, true)
    self.timer:Del()
    self.trunkTimer:Del()
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

local widgetUpdate
do
    local widgetsToDraw = {}
    function widgetUpdate(widget)
	tinsert(widgetsToDraw, widget)
	if mod.db.profile.refreshRate == 0 then
		draw(true)
	end
    end
    --local fontsList = LSM:List("font")
    function draw(bypass)
        if not UnitExists(StarTip.unit) then 
		mod.timer:Stop()
		mod.trunkTimer:Stop()
		StarTip.tooltipMain:Hide()
		return
	end
--[[
        if #StarTip.trunk > 0 and not bypass then
            wipe(widgetsToDraw)
            for k, v in pairs(lines) do
                if v.leftObj then
    	             v.leftObj:Update()
            	     tinsert(widgetsToDraw, v.leftObj)
                end
                if v.rightObj then
    		    v.rightObj:Update()
                    tinsert(widgetsToDraw, v.rightObj)
                end
            end
        end
]]
        for i, widget in ipairs(widgetsToDraw) do
            local font = LSM:Fetch("font", appearance.db.profile.font)
            local headerFont = LSM:Fetch("font", appearance.db.profile.headerFont)
            local justification = "LEFT"
            if widget.x == 2 then
                justification = "RIGHT"
            end
            local outlined = ""
            if widget.config.outlined and widget.config.outlined > 1 then
                if widget.config.outlined == 2 then
			outlined = "OUTLINE"
                elseif widget.config.outlined == 3 then
			outline = "THICKOUTLINE"
                end
            end
            if widget.y == 1 then
		widget.fontObj:SetFont(headerFont, appearance.db.profile.fontSizeHeader, outlined)
            else
                widget.fontObj:SetFont(font, appearance.db.profile.fontSizeNormal, outlined)
            end
            local colSpan = 1
            if not widget.config.right and widget.x == 1 then 
               colSpan = 2
            end
            if type(widget.y) == "number" and widget.y <= StarTip.tooltipMain:GetLineCount() and widget.buffer ~= "" then
                StarTip.tooltipMain:SetCell(widget.y, widget.x, widget.buffer, widget.fontObj, 
			justification, colSpan, nil, 0, 0, nil, nil, 40)

		if type(widget.config.color) == "string" and widget.config.color ~= "" and widget.color.is_valid then
			widget.color:Eval()
			local r, g, b, a = widget.color:P2N()
			StarTip.tooltipMain:SetCellColor(widget.y, widget.x, 
        	            r or 0, g or 0, b or 0, a or 1)
		end
            end
        end
        table.wipe(widgetsToDraw)
    end
end

function mod:AppendTrunk()
	for i, v in ipairs(StarTip.trunk) do
		if #v == 2 then
			local y = StarTip.tooltipMain:AddLine('', '')
			StarTip.tooltipMain:SetCell(y, 1, v[1])
			StarTip.tooltipMain:SetCell(y, 2, v[2])
		else
			local y = StarTip.tooltipMain:AddLine('')
			StarTip.tooltipMain:SetCell(y, 1, v[1], nil, "LEFT", 2)
		end
	end
	StarTip:TrunkClear()
end

function mod:StopLines()
    for k, v in pairs(lines) do
        if v.leftObj then
            v.leftObj:Stop()
        end
        if v.rightObj then
            v.rightObj:Stop()
        end
    end

end

function mod:ClearLines()
    self:StopLines()
    wipe(lines)
end

local tbl
function mod:CreateLines()
    local llines = {}
    local j = 0
    for i, v in ipairs(self.db.profile.lines) do
        if not v.deleted and v.enabled and v.left then
            v = copy(v)
            j = j + 1
            llines[j] = copy(v)
            llines[j].config = copy(v)

            v.value = v.left
            v.outlined = v.leftOutlined
            v.color = v.colorL
            v.maxWidth = v.maxWidthL
            v.minWidth = v.minWidthL
            local update = v.update or 0
            v.update = 0
            if v.left and v.leftUpdating then v.update = update end
            llines[j].leftObj = v.left and WidgetText:New(mod.core, "StarTip.UnitTooltip:" .. v.name .. ":left:", copy(v), 0, 0, v.layer or 0, StarTip.db.profile.errorLevel, widgetUpdate)

            v.value = v.right
            v.outlined = v.rightOutlined
            v.update = 0
            if v.right and v.rightUpdating then v.update = update end
            v.color = v.colorR
            v.maxWidth = v.maxWidthR
            v.minWidth = v.minWidthR
            llines[j].rightObj = v.right and WidgetText:New(mod.core, "StarTip.UnitTooltip:" .. v.name .. ":right:", copy(v), 0, 0, v.layer or 0, StarTip.db.profile.errorLevel, widgetUpdate)

           if v.left then
               llines[j].leftObj.fontObj = _G[v.name .. "Left"] or CreateFont(v.name .. "Left")
           end
           if v.right then
               llines[j].rightObj.fontObj = _G[v.name .. "Right"] or CreateFont(v.name .. "Right")
           end
        end
    end
    self:ClearLines()
    lines = setmetatable(llines, {__call=function(self)
            local lineNum = 0
            StarTip.tooltipMain:Clear()
            --GameTooltip:ClearLines()
            for i, v in ipairs(self) do
                if v.leftObj then
                    v.leftObj.x = nil
                    v.leftObj.y = nil
                end
                if v.rightObj then
                    v.rightObj.x = nil
                    v.rightObj.y = nil
                end
                local left, right = '', ''
                environment.unit = v.leftObj and v.leftObj.unitOverride or StarTip.unit or "mouseover"
                if v.right then
                    if v.rightObj then
                        environment.self = v.rightObj
                        right = mod.evaluator.ExecuteCode(environment, v.name .. " right", v.right)
                        if type(right) == "number" then right = right .. "" end
                    end
                    if v.leftObj then
                        environment.self = v.leftObj
                        left = mod.evaluator.ExecuteCode(environment, v.name .. " left", v.left)
                        if type(left) == "number" then left = left .. "" end
                    end
                else
                    if v.leftObj then
                        environment.self = v.leftObj
                        left = mod.evaluator.ExecuteCode(environment, v.name .. " left", v.left)
                        if type(left) == "number" then left = left .. "" end
                    end
                    right = ''
                end
                
                if type(left) == "string" and type(right) == "string" then
                    lineNum = lineNum + 1
                    if v.right and v.right ~= "" then
                        --GameTooltip:AddDoubleLine(' ', ' ', mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b, mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b)
                        local y, x = StarTip.tooltipMain:AddLine('', '')
                        --v.leftObj.fontString = mod.leftLines[lineNum]
                        --v.rightObj.fontString = mod.rightLines[lineNum]
			--v.leftObj.fontString = StarTip.qtipLines[y][1]
			--v.rightObj.fontString = StarTip.qtipLines[y][2]
			v.leftObj.y = y
			v.leftObj.x = 1
			v.rightObj.y = y
			v.rightObj.x = 2
                    else
                        local y, x = StarTip.tooltipMain:AddLine('')
                        v.leftObj.y = y
                        v.leftObj.x = 1
                        --GameTooltip:AddLine(' ', mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b, v.wordwrap)
                        --v.leftObj.fontString = mod.leftLines[lineNum]
                    end
                    if v.rightObj then
			v.rightObj.buffer = false
                        v.rightObj:Start()
                    end
                    if v.leftObj then
			v.leftObj.buffer = false
                        v.leftObj:Start()
                    end
                    v.lineNum = lineNum
                end
            end
    end})
end

function mod:OnHide()
    self:StopLines()
    self.timer:Stop()
    self.trunkTimer:Stop()
end

function mod:OnFadeOut()
    self:OnHide()
end

local function escape(text)
    return string.gsub(text, "|","||")
end

local function unescape(text)
    return string.gsub(text, "||", "|")
end

function mod:GetNames()
    local new = {}
    for i, v in ipairs(self.db.profile.lines) do
        new[i] = v.name
    end
    return new
end

function mod:RebuildOpts()
    options = {
        add = {
            name = L["Add Line"],
            desc = L["Give the line a name"],
            type = "input",
            validate = function(info, v) 
                for k, line in pairs(self.db.profile.lines) do
			if line.name == v and not v.deleted then 
				StarTip:Print(format(L["A line named %s already exists."], v))
				return false
			end
		end
		return true
            end,
            set = function(info, v)
                if v == "" then return end
		local key
		for k, v in pairs(self.db.profile.lines) do
			if v.name == v then
				key = k
				break
			end
		end
		if key then tremove(self.db.profile.lines, key) end
                tinsert(self.db.profile.lines, {name = v, left = nil, right = nil, update=500, enabled = true, custom=true})
                self:RebuildOpts()
                StarTip:RebuildOpts()
                self:ClearLines()
                self:CreateLines()
            end,
            order = 5
        },
        refreshRate = {
            name = L["Refresh Rate"],
            desc = L["The rate at which the tooltip will be refreshed"],
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
            name = L["Default Color"],
            desc = L["The default color for tooltip lines"],
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
            name = L["Restore Defaults"],
            desc = L["Roll back to defaults."],
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
                        name = L["Enabled"],
                        desc = L["Whether to show this line or not"],
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
                        name = L["Left Updating"],
                        desc = L["Whether this line's left segment refreshes"],
                        type = "toggle",
                        get = function() return v.leftUpdating end,
                        set = function(info, val)
                            v.leftUpdating = val
                            v.leftUpdatingDirty = true
                            self:CreateLines()
                        end,
                        order = 3
                    },
                    rightUpdating = {
                        name = L["Right Updating"],
                        desc = L["Whether this line's right segment refreshes"],
                        type = "toggle",
                        get = function() return v.rightUpdating end,
                        set = function(info, val)
                            v.rightUpdating = val
                            v.rightUpdatingDirty = true
                            self:CreateLines()
                        end,
                        order = 4
                    },
                    up = {
                        name = L["Move Up"],
                        desc = L["Move this line up by one"],
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
                        name = L["Move Down"],
                        desc = L["Move this line down by one"],
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
                    --[[bold = {
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
                    },]]
                    leftOutlined = {
                        name = L["Left Outlined"],
                        desc = L["Whether the left widget is outlined or not"],
                        type = "select",
                        values = {L["None"], L["Outlined"], L["Thick Outlilned"]},
                        get = function() return v.leftOutlined or 1 end,
                        set = function(info, val)
                            v.leftOutlined = val
                            v.leftOutlinedDirty = true
                            self:CreateLines()
                        end,
                        order = 8
                    },
                    rightOutlined = {
                        name = L["Right Outlined"],
                        desc = L["Whether the right widget is outlined or not"],
                        type = "select",
                        values = {L["None"], L["Outlined"], L["Thick Outlilned"]},
                        get = function() return v.rightOutlined or 1 end,
                        set = function(info, val)
                            v.rightOutlined = val
                            v.rightOutlinedDirty = true
                            self:CreateLines()
                        end,
                        order = 9
                    },
                    updateAnyways = {
			name = L["Update Anyways"],
			desc = L["Line segments won't update if the text never changes. Enable this option to bypass this restriction"],
			type = "toggle",
			get = function() return v.updateAnyways end,
			set = function(info, val)
				v.updateAnyways = val
				v.updateAnywayDirty = true
				self:CreateLines()
			end,
			order = 10
                    },
                    dogtag = {
                        name = L["Dog Tags"],
                        desc = L["Whether to parse the return values as DogTags or not."],
                        type = "toggle",
                        get = function() return v.dogtag end,
                        set = function(info, val) 
                            v.dogtag = val
                            v.dogtagDIrty = true
                            self:CreateLines()
                        end,
                        order = 11
                    },
                    unitOverride = {
                        name = L["Unit Override"],
                        desc = L["There's a default unit provided to each run environment, and you access it with 'unit' in your script. These \"units\" include 'mouseover', 'target', 'party1', etc... Here you can override that unit specifier."],
			type = "input",
			get = function() return v.unitOverride end,
			set = function(info, val)
				v.unitOverride = val
				v.unitOverrideDirty = true
				self:CreateLines()
			end,
			order = 12
                    },
--[[
                    wordwrap = {
                        name = L["Word Wrap"],
                        desc = L["Whether this line should word wrap lengthy text"],
                        type = "toggle",
                        get = function() 
                            return v.wordwrap
                        end,
                        set = function(info, val)
                            v.wordwrap = val
                        end,
                        order = 10
                    },
]]

                    delete = {
                        name = L["Delete"],
                        desc = L["Delete this line"],
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
                        order = 100
                    },
                    linesHeader = {
                        name = L["Lines"],
                        type = "header",
                        order = 101
                    },
                    left = {
                        name = L["Left Segment"],
                        type = "input",
                        desc = L["Enter code for this line's left segment."],
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
                        order = 113
                    },
                    right = {
                        name = L["Right Segment"],
                        type = "input",
                        desc = L["Enter code for this line's right segment."],
                        get = function() return escape(v.right or "") end,
                        set = function(info, val)
                            v.right = unescape(val);
                            v.rightDirty = true
                            if val == "" then v.right = nil end
                            self:CreateLines()
                        end,
                        multiline = true,
                        width = "full",
                        order = 114
                    },
                    colorL = {
                        name = L["Left Color"],
                        desc = L["Background color for left segment. Return r, g, b, and a."],
			type = "input",
                        get = function()
				return escape(v.colorL or "")
                        end,
                        set = function(info, val)
                            v.colorL = unescape(val)
                            self:CreateLines()
                        end,
			multiline = true,
			width = "full",
                        order = 115
                    },
                    colorR = {
                        name = L["Right Color"],
                        desc = L["Background color for right segment. Return r, g, b, and a."],
			type = "input",
                        get = function()
				return escape(v.colorR or "")
                        end,
                        set = function(info, val)
                            v.colorR = unescape(val)
                            self:CreateLines()
                        end,
			multiline = true,
			width = "full",
                        order = 116
                    },

                    marquee = {
                        name = "Marquee Settings",
                        type = "group",
                        args = {
                            header = {
                                name = L["Note that only the left line script is used for marquee text"],
                                type = "header",
                                order = 1
                            },
                            prefix = {
                                name = L["Prefix"],
                                desc = L["The prefix for this marquee"],
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
                                desc = L["The postfix for this marquee"],
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
                            --[[precision = {
                                name = "Precision",
                                desc = L["How precise displayed numbers are"],
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
                            },]]
                            align = {
                                name = L["Alignment"],
                                desc = L["The alignment information"],
                                type = "select",
                                values = WidgetText.alignmentList,
                                get = function()
                                    return v.align or WidgetText.defaults.align
                                end,
                                set = function(info, val)
                                    v.align = val
                                    v.alignDirty = true
                                    self:CreateLines()
                                end,
                                order = 5
                            },
                            update = {
                                name = L["Text Update"],
                                desc = L["How often to update the text. A value of zero means the text won't repeatedly update."],
                                type = "input",
                                pattern = "%d",
                                get = function()
                                    return tostring(v.update or WidgetText.defaults.update)
                                end,
                                set = function(info, val)
print("lolol")
                                    v.update = tonumber(val)
                                    v.updateDirty = true
                                    self:CreateLines()
                                end,
                                order = 6
                            },
                            speed = {
                                name = L["Scroll Speed"],
                                desc = L["How fast to scroll marquee text."],
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
                                name = L["Direction"],
                                desc = L["Which direction to scroll."],
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
                                name = L["Columns"],
                                desc = L["How wide the marquee is. If your text is cut short then increase this value."],
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
                                name = L["Don't right trim"],
                                desc = L["Prevent trimming white space to the right of text"],
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
                            },
                            limited = {
                                name = L["Clip Length"],
                                desc = L["Whether to clip the string's length when it is longer than the value of Columns."],
                                type = "toggle",
                                get = function()
                                    return v.limited or WidgetText.defaults.limited
                                end,
                                set = function(info, val)
                                    v.limited = val
                                    v.limitedDirty = true
                                    sel:CreateLines()
                                end,
                                order = 11
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
local plugin = LibStub("LibScriptablePluginString-1.0")
local ff = CreateFrame("Frame")
function mod:SetUnit()
    if ff:GetScript("OnUpdate") then ff:SetScript("OnUpdate", nil) end
    --self.NUM_LINES = 0
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
        local right = self.rightLines[i]
        local txt1 = left:GetText()
        local r1, g1, b1 = left:GetTextColor()
	local txt2
	local r2, g2, b2
	if right:IsShown() then
		txt2 = right:GetText()
		r2, g2, b2 = right:GetTextColor()
	end
	StarTip:TrunkAdd(txt1, r1, g1, b1, txt2, r2, g2, b2)
    end

    mod:StopLines()
    lines()
    mod:AppendTrunk()

    if mod.db.profile.refreshRate ~= 0 then 
	self.timer:Start()
    end
    self.trunkTimer:Start()
end

--[[
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
]]
