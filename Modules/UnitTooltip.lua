local mod = StarTip:NewModule("UnitTooltip", "AceEvent-3.0")
mod.name = "Unit Tooltip"
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
local UnitTooltipStats = LibStub("StarLibPluginUnitTooltipStats-1.0", true)
assert(UnitTooltipStats, mod.name .. " requires StarLibPluginUnitTooltipStats-1.0")

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
local environment = {}

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
		enabled = true
    },
    [2] = {
        name = "Target",
        left = 'return "Target:"',
        right = [[
local r, g, b
local unit = (unit or "mouseover") .. "target"
if UnitExists(unit) then
    if UnitIsPlayer(unit) then
        r, g, b = ClassColor(unit)
    else
        r, g, b = UnitSelectionColor(unit)
    end
else
    r = 1
    g = 1
    b = 1
end
local name = UnitName(unit)
if name == select(1, UnitName("player")) then name = "<<YOU>>" end
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
guild = Guild(unit)
if guild then return "<" .. guild .. ">" else return unitGuild end
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
local lvl = UnitLevel(unit)
local class = " "
if Classification(unit) then
    class = " (" .. Classification(unit) .. ")"
end

if lvl < 0 then
    return Classification(unit) or "Unknown"
else 
    return format("%s", Level(unit))
end
]],
		enabled = true,
    },
    [7] = {
        name = "Race",
        left = 'return "Race:"',
        right = [[
return Race(unit)
]],
		enabled = true,
    },
    [8] = {
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
    [9] = {
        name = "Faction",
        left = 'return "Faction:"',
        right = [[
return Faction(unit)
]],
		enabled = true,
    },
    [10] = {
        name = "Status",
        left = 'return "Status:"',
        right = [[
if not UnitIsConnected(unit) then
    return "Offline"
elseif HasAura(GetSpellInfo(19752)) then
    return "Divine Intervention"
elseif UnitIsFeignDeath(unit) then
    return "Feigned Death"
elseif UnitIsGhost(unit) then
    return "Ghost"
elseif UnitIsDead(unit) and HasAura(GetSpellInfo(20707)) then
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
    [11] = {
        name = "Health",
        left = 'return "Health:"',
        right = [[
local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
local r, g, b = HPColor(health, maxHealth)
local value = "Unknown"
if maxHealth == 100 then
    value = Colorize(health .. "%", r, g, b)
elseif maxHealth ~= 0 then
    value = Colorize(format("%s/%s (%d%%)", short(health), short(maxHealth), health/maxHealth*100), r, g, b)
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
return PowerName(unit)
]],
        right = [[
local mana = UnitMana(unit)
local maxMana = UnitManaMax(unit)
local r, g, b = PowerColor(nil, unit)
local value = "Unknown"
if maxMana == 100 then
    value = Colorize(tostring(mana), r, g, b)
elseif maxMana ~= 0 then
    value = Colorize(format("%s/%s (%d%%)", short(mana), short(maxMana), mana/maxMana*100), r, g, b)
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
        right = "return unitLocation",
		enabled = true
    },
	[14] = {
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
	[15] = {
		name = "Memory Usage",
		left = "return 'Memory Usage:'",
		right = [[
local mem, percent, memdiff, totalMem, totaldiff, memperc = GetMemUsage("StarTip")
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
	[16] = {
		name = "CPU Usage",
		desc = "Note that you must turn on CPU profiling",
		left = 'return "CPU Usage:"',
		right = [[
local cpu, percent, cpudiff, totalCPU, totaldiff, cpuperc = GetCPUUsage("StarTip")
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
	[17] = {
		name = "Talents",
		left = "return 'Talents:'",
		right = [[
return SpecText(unit)
]],
		rightUpdating = true,
		enabled = true,
		update = 1000
	},
	[18] = {
		name = "Range",
		left = [[
local min, max = RangeCheck:GetRange(unit)
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
}

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
	
	local text = StarTip:GetModule("Text")
	if text.db.profile.lines then
		local lines = copy(text.db.profile.lines)
		for k, line in pairs(lines) do
			self.db.profile.lines[k] = line
		end
		text.db.profile.lines = nil
	end

    self.leftLines = StarTip.leftLines
    self.rightLines = StarTip.rightLines
    self:RegisterEvent("UPDATE_FACTION")
    StarTip:SetOptionsDisabled(options, true)

	self.core = LibCore:New(mod, environment, self:GetName(), {[self:GetName()] = {}}, "text", StarTip.db.profile.errorLevel)
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
		table.wipe(widgetsToDraw)
		if UnitExists(StarTip.unit) then
			GameTooltip:Show()
		end
	end
end

--@debug@
local PluginResources = ResourceServer or LibStub("StarLibPluginResourceTools-1.0")
local plugin = {}
LibStub("StarLibPluginString-1.0"):New(plugin)
--@end-debug@

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
		--@debug@
		if debugging then
			PluginResources.Update()
			local mem, percent, memdiff, totalMem, totaldiff = PluginResources.GetMemUsage("StarTip")
		end
		--@end-debug@
        local lineNum = 0
		GameTooltip:ClearLines()
        for i, v in ipairs(self) do
			if v.enabled and not v.deleted then
                local left, right, c, cc = '', ''
				environment.unit = StarTip.unit
				v.config.unit = StarTip.unit
                if v.right and v.right ~= "" then
                    right = mod.evaluator.ExecuteCode(environment, v.name .. " right", v.right)
                    left = mod.evaluator.ExecuteCode(environment, v.name .. " left", v.left)
					if right == "" then right = "nil" end

                else
                    right = ''
                    left = mod.evaluator.ExecuteCode(environment, v.name .. " left", v.left)
                end

                if left and left ~= "" and right ~= "nil" then
                    lineNum = lineNum + 1
                    if v.right then
						GameTooltip:AddDoubleLine(' ', ' ', mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b, mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b)

						if not v.leftObj or v.lineNum ~= lineNum then
							v.config.value = v.left
							local tmp = v.update
							if not v.leftUpdating then v.update = 0 end

							v.leftObj = v.leftObj or WidgetText:New(mod.core, v.name .. "left", copy(v.config), 0, 0, v.layer or 0, StarTip.db.profile.errorLevel, updateWidget)
							v.update = tmp
						end
						if not v.rightObj or v.lineNum ~= lineNum then
							v.config.value = v.right
							local tmp = v.update
							if not v.rightUpdating then v.update = 0 end
							v.rightObj = v.rightObj or WidgetText:New(mod.core, v.name .. "right", copy(v.config), 0, 0, v.layer or 0, StarTip.db.profile.errorLevel, updateWidget)
							v.update = tmp
						end
						v.leftObj.fontString = mod.leftLines[lineNum]
						v.rightObj.fontString = mod.rightLines[lineNum]
                    else
						GameTooltip:AddLine(' ', mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b)

						v.config.value = v.left
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
					v.lineNum = lineNum
				end
			end

        end
        mod.NUM_LINES = lineNum
		--@debug@
		if debugging then
			PluginResources.Update()
			local mem2, percent2, memdiff2, totalMem2, totaldiff2 = PluginResources.GetMemUsage("StarTip")
			StarTip:Print("Memory: ", plugin.memshort(mem2 - mem))
		end
		--@end-debug@
		draw()
		GameTooltip:Show()
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
			order = 8
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
							StarTip:Print("up", i)
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
						order = 8
					},
					linesHeader = {
						name = "Lines",
						type = "header",
						order = 9
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
						order = 10
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
						order = 11
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

local ff = CreateFrame("Frame")
function mod:SetUnit()
    if ff:GetScript("OnUpdate") then ff:SetScript("OnUpdate", nil) end

	environment.unitName, environment.unitGuild, environment.unitLocation = UnitTooltipStats.GetUnitTooltipStats("mouseover")

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

	wipe(linesToAdd)
	wipe(linesToAddR)
	wipe(linesToAddG)
	wipe(linesToAddB)
	wipe(linesToAddRight)
	wipe(linesToAddRightR)
	wipe(linesToAddRightG)
	wipe(linesToAddRightB)
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

	GameTooltip:Show()

	if self.db.profile.refreshRate > 0 and self.timer then
		self.timer:Start()
	end

	if GameTooltip:NumLines() > mod.NUM_LINES then GameTooltip:Hide(); return end
	
	self:RefixEndLines()
	
	local hide = 1
	for i = 1, GameTooltip:NumLines() do
		if string.trim(self.leftLines[i]:GetText() or "") == "" and string.trim(self.rightLines[i]:GetText() or "") == "" then hide = hide + 1 end
	end
	
	if hide >= GameTooltip:NumLines() then
		GameTooltip:Hide()
	end
end

function mod:RefixEndLines()
    -- Another part taken from CowTip
    for i, left in ipairs(linesToAdd) do

        local right = linesToAddRight[i]
        if right then
            GameTooltip:AddDoubleLine(left, right, linesToAddR[i], linesToAddG[i], linesToAddB[i], linesToAddRightR[i], linesToAddRightG[i], linesToAddRightB[i])
        else
            GameTooltip:AddLine(left, linesToAddR[i], linesToAddG[i], linesToAddB[i], true)
        end
    end
    -- End
end