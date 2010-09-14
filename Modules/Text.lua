local mod = StarTip:NewModule("Text", "AceTimer-3.0")
mod.name = "Text"
mod.toggled = true
--mod.childGroup = true
mod.defaultOff = true
local _G = _G
local StarTip = _G.StarTip
local GameTooltip = _G.GameTooltip
local GameTooltipStatusBar = _G.GameTooltipStatusBar
local UnitIsPlayer = _G.UnitIsPlayer
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitSelectionColor = _G.UnitSelectionColor
local UnitClass = _G.UnitClass
local self = mod
local timer
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetText = LibStub("StarLibWidgetText-1.0")
local LibCore = LibStub("StarLibCore-1.0")
local Utils = LibStub("StarLibUtils-1.0")
local LibQTip = LibStub("LibQTip-1.0")

local environment = {}

local anchors = {
	"TOP",
	"TOPRIGHT",
	"TOPLEFT",
	"BOTTOM",
	"BOTTOMRIGHT",
	"BOTTOMLEFT",
	"RIGHT",
	"LEFT",
	"CENTER"
}

local anchorsDict = {}

for i, v in ipairs(anchors) do
	anchorsDict[v] = i
end

local createTexts
local widgets = {}

local function copy(tbl)
	if type(tbl) ~= "table" then return tbl end
	local newTbl = {}
	for k, v in pairs(tbl) do
		newTbl[k] = copy(v)
	end
	return newTbl
end

local defaultWidgets = {
	[1] = {
		name = "Name",
		enabled = true,
		value = [[
if not UnitExists(unit) then return end
return '--' .. select(1, UnitName(unit)) .. '--'
]],
		color = [[
if not UnitExists(unit) then return end
return ClassColor(unit)
]],
		cols = 50,
		align = WidgetText.ALIGN_PINGPONG,
		update = 1000,
		speed = 100,
		direction = SCROLL_LEFT,
		dontRtrim = true,
		point = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT", 0, 12},
		parent = "GameTooltip",
	},	
	[2] = {
		name = "Health",
		enabled = true,
		value = [[
if not UnitExists(unit) then return end
local health, max = UnitHealth(unit), UnitHealthMax(unit)
if max == 0 then max = 0.0001 end
return format('Health: %.1f%%', health / max * 100)
]],
		color = [[
if not UnitExists(unit) then return end
local health, max = UnitHealth(unit), UnitHealthMax(unit)
return HPColor(health, max)		
]],
		cols = 15,
		update = 1000,
		dontRtrim = true,
		point = {"TOPLEFT", "GameTooltip", "BOTTOMLEFT", 0, 1},
		parent = "GameTooltip"
	},
	[3] = {
		name = "Power",
		enabled = true,
		value = [[
if not UnitExists(unit) then return end
local mana, max = UnitMana(unit), UnitManaMax(unit)
if max == 0 then max = 0.0001 end		
return format(PowerName(unit)..': %.1f%%', mana / max * 100)
]],
		color = [[
if not UnitExists(unit) then return end
local mana, max = UnitMana(unit), UnitManaMax(unit)
return HPColor(mana, max)
]],
		cols = 15,
		update = 1000,
		dontRtrim = true,
		point = {"TOPRIGHT", "GameTooltip", "BOTTOMRIGHT", 0, 1},
		parent = "GameTooltip"
	},
	[4] = {
		name = "Memory Percent",
		enabled = false,
		value = [[		
local mem, percent, memdiff, totalMem, totaldiff = GetMemUsage("StarTip")
if mem then
    if totaldiff == 0 then totaldiff = 1 end
    memperc = (memdiff / totaldiff * 100)
    local num = floor(memperc + 0.5)
    if num < 1 then num = 1 end
    if num > 100 then num = 100 end
    local r, g, b = gradient[num][1], gradient[num][2], gradient[num][3]
    return format("Mem: %.2f%%", memperc)
end
]],
		color = [[
local mem, percent, memdiff, totalMem, totaldiff = GetMemUsage("StarTip")
if mem then
    if totaldiff == 0 then totaldiff = 1 end
    memperc = (memdiff / totaldiff * 100)
    local num = floor(memperc + 0.5)
    if num < 1 then num = 1 end
    if num > 100 then num = 100 end
    local r, g, b = gradient[num][1], gradient[num][2], gradient[num][3]
    return r, g, b
end

]],
		cols = 20,
		update = 1000,
		dontRtrim = true,
		point = {"TOPLEFT", "GameTooltip", "BOTTOMLEFT", 0, -62},
		parent = "GameTooltip"
	},
	[5] = {
		name = "Memory Total",
		enabled = false,
		value = [[		
local mem, percent, memdiff, totalMem, totaldiff = GetMemUsage("StarTip")
if mem then
    if totaldiff == 0 then totaldiff = 1 end
    memperc = (mem / totalMem * 100)
    local num = floor(memperc + 0.5)
    if num < 1 then num = 1 end
    if num > 100 then num = 100 end
    return format("%s (%.2f%%)", memshort(mem), memperc)
end
]],
		color = [[
return 1, 1, 0
]],
		cols = 10,
		update = 1000,
		dontRtrim = true,
		point = {"TOPLEFT", "GameTooltip", "BOTTOMLEFT", 0, -124},
		parent = "GameTooltip"
	},	
	[6] = {
		name = "CPU Percent",
		enabled = false,
		value = [[
local cpu, percent, cpudiff, totalCPU, totaldiff = GetCPUUsage("StarTip")
if cpu then
    if totaldiff == 0 then totaldiff = 100 end
    cpuperc = cpudiff / totaldiff * 100;
    local num = floor(cpuperc + 0.5)
    if num < 1 then num = 1 end
    if num > 100 then num = 100 end
    local r, g, b = gradient[num][1], gradient[num][2], gradient[num][3]
    return format("CPU: %.2f%%", cpuperc)
end
]],
		color = [[
local cpu, percent, cpudiff, totalCPU, totaldiff = GetCPUUsage("StarTip")
if cpu then
    if totaldiff == 0 then totaldiff = 1 end
    cpuperc = (cpudiff / totaldiff * 100)
    local num = floor(cpuperc)
    if num < 1 then num = 1 end
    if num > 100 then num = 100 end
    local r, g, b = gradient[num][1], gradient[num][2], gradient[num][3]
    return r, g, b
end		
]],
		cols = 20,
		align = WidgetText.ALIGN_RIGHT,
		update = 1000,
		dontRtrim = true,
		point = {"TOPRIGHT", "GameTooltip", "BOTTOMRIGHT", 0, -62},
		parent = "GameTooltip"
	},
	[7] = {
		name = "CPU Total",
		enabled = false,
		value = [[
local cpu, percent, cpudiff, totalCPU, totaldiff = GetCPUUsage("StarTip")
if cpu then
    if totalCPU == 0 then totalCPU = 100 end
    cpuperc = cpu / totalCPU * 100;
    return format("%s (%.2f%%)", timeshort(cpu), cpuperc)
end
]],
		color = [[
return 1, 1, 0 
]],
		cols = 10,
		align = WidgetText.ALIGN_RIGHT,
		update = 1000,
		dontRtrim = true,
		point = {"TOPRIGHT", "GameTooltip", "BOTTOMRIGHT", 0, -124},
		parent = "GameTooltip"
	},	
}

local defaults = {
	profile = {
		classColors = true,
	}
}

local options = {}
local optionsDefaults = {
	add = {
		name = "Add Text",
		desc = "Add a text widget",
		type = "input",
		set = function(info, v)
			local widget = {
				name = v,
				type = "text",
				min = "return 0",
				max = "return 100",
				height = 6,
				point = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"},
				texture = LSM:GetDefault("statustext"),
				expression = "",
				custom = true
			}
			tinsert(mod.db.profile.texts, widget)
			StarTip:RebuildOpts()
			mod:ClearTexts()
		end,
		order = 5
	},
	defaults = {
		name = "Restore Defaults",
		desc = "Restore Defaults",
		type = "execute",
		func = function() 
			mod.db.profile.texts = copy(defaultWidgets); 
			StarTip:RebuildOpts() 
		end,
		order = 6
	},
}

function updateText(widget)
	widget.text:SetText(widget.buffer)
	
	local r, g, b = 0, 0, 1
	
	if widget.color then
		r, g, b, a = widget.color.res1, widget.color.res2, widget.color.res3, widget.color.res4
	end
	
	if type(r) == "number" then
		widget.text:SetVertexColor(r, g, b, a)
	end
end

local textureDict = {}

function mod:CreateTexts()
	createTexts()
end

local new, del
do
	local pool = {}
	local i = 0
	function new(cols)
		local text = next(pool)
		
		if text then
			pool[text] = nil
		else
			text = GameTooltip:CreateFontString()
			text:SetFontObject(GameTooltipText)
		end
		
		return text
	end
	function del(text)
		pool[text] = true
	end
end

local defaultPoint = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"}
	
local strataNameList = {
	"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"
}

local strataLocaleList = {"Background", "Low", "Medium", "High", "Dialog", "Fullscreen", "Fullscreen Dialog", "Tooltip"}

local function clearText(obj)
	local widget = mod.texts[obj]
	if not widget then return end
	widget:Del()
	del(widget.text)
end

function mod:ClearTexts()
	for k, v in pairs(mod.texts) do
		clearText(v)
	end
	wipe(mod.texts)
end

function createTexts()
	if type(mod.texts) ~= "table" then mod.texts = {} end
	--[[for k, v in pairs(mod.texts) do
		v:Del()
		v.text:Hide()
		del(v.text)
	end]]
	local appearance = StarTip:GetModule("Appearance")	
	for i, v in ipairs(self.db.profile.texts) do
		if v.enabled and not v.deleted then
			local text = new(v.cols or WidgetText.defaults.cols)
			local widget = mod.texts[v] or WidgetText:New(mod.core, v.name, v, v.row or 0, v.col or 0, v.layer or 0, StarTip.db.profile.errorLevel, updateText) 
			widget.config.unit = StarTip.unit
			text:ClearAllPoints()
			text:SetParent(v.parent)
			local arg1, arg2, arg3, arg4, arg5 = unpack(v.point)
			arg4 = (arg4 or 0)
			arg5 = (arg5 or 0)
			text:SetPoint(arg1, arg2, arg3, arg4, arg5)
			text:Show()
			widget.text = text
			mod.texts[v] = widget
		end
	end
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	
	if not self.db.profile.texts then
		self.db.profile.texts = {}
	end
		
	for i, v in ipairs(defaultWidgets) do
		for j, vv in ipairs(self.db.profile.texts) do
			if v.name == vv.name and not vv.custom then
				for k, val in pairs(v) do
					if v[k] ~= vv[k] and not vv[k.."Dirty"] then
						vv[k] = v[k]
					end
				end
				v.tagged = true
			end
		end
	end

	for i, v in ipairs(defaultWidgets) do
		if not v.tagged and not v.deleted then
			tinsert(self.db.profile.texts, copy(v))
		end
	end
	
	self.core = LibCore:New(mod, environment, "StarTip.Texts", {["StarTip.Texts"] = {}}, nil, StarTip.db.profile.errorLevel)		
	
	StarTip:SetOptionsDisabled(options, true)

	self.texts = {}
end

function mod:OnEnable()
	self:ClearTexts()
	createTexts()
	GameTooltip:SetClampRectInsets(0, 0, 10, 10)
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	self:ClearTexts()
	GameTooltip:SetClampRectInsets(0, 0, 0, 0)
	StarTip:SetOptionsDisabled(options, true)
end

--[[function mod:RebuildOpts()
	for k, v in ipairs(self.db.profile.texts) do
		options.texts.args[k] = WidgetText:GetOptions(v)
	end
end]]

function mod:GetOptions()
	return options
end

function mod:SetUnit()
	GameTooltipStatusBar:Hide()
	createTexts()
	for k, text in pairs(self.texts) do
		text:Start()
		text.text:Show()
	end
end

function mod:SetItem()
	for i, text in pairs(self.texts) do
		text:Stop()
		text.text:Hide()
	end
end

function mod:SetSpell()
	for i, text in pairs(self.texts) do
		text:Stop()
		text.text:Hide()
	end
end

function mod:OnHide()
	if timer then
		self:CancelTimer(timer)
		timer = nil
	end
	for i, text in pairs(self.texts) do
		text:Stop()
		text.text:Hide()
	end
end

local function colorGradient(perc)
    if perc <= 0.5 then
        return 1, perc*2, 0
    else
        return 2 - perc*2, 1, 0
    end
end

function mod:RebuildOpts()
	local defaults = WidgetText.defaults
	self:ClearTexts()

	wipe(options)
	for k, v in pairs(optionsDefaults) do
		options[k] = v
	end
	
	for i, db in ipairs(self.db.profile.texts) do
		options[db.name:gsub(" ", "_")] = {
			name = db.name,
			type="group",
			order = i,
			args=WidgetText:GetOptions(StarTip, db)
		}
		options[db.name:gsub(" ", "_")].args.delete = {
			name = "Delete",
			type = "execute",
			func = function()
				local delete = true
				for i, v in ipairs(defaultWidgets) do
					if db.name == v.name then
						db.deleted = true
						delete = false
					end
				end
				if delete then
					self.db.profile.texts[i] = nil
				end
				self:ClearTexts()
				StarTip:RebuildOpts()
			end,
			order = 100
		}
	end
end

--[[				enabled = {
					name = "Enabled",
					desc = "Whether this text is enabled or not",
					type = "toggle",
					get = function() return db.enabled end,
					set = function(info, v)
						db.enabled = v
						db["enabledDirty"] = true
						createTexts()
					end,
					order = 1
				},
				height = {
					name = "Text height",
					desc = "Enter the text's height",
					type = "input",
					pattern = "%d",
					get = function() return tostring(db.height or defaults.height) end,
					set = function(info, v) 
						db.height = tonumber(v); 
						db["heightDirty"] = true
						createTexts();  
					end,
					order = 2
				},
				update = {
					name = "Text update rate",
					desc = "Enter the text's refresh rate",
					type = "input",
					pattern = "%d",
					get = function() return tostring(db.update or defaults.update) end,
					set = function(info, v) 
						db.update = tonumber(v); 
						db["updateDirty"] = true						
						createTexts() 
					end,
					order = 3
				},
				strata = {
					name = "Strata",
					type = "select",
					values = strataLocaleList,
					get = function() return db.strata end,
					set = function(info, v) db.strata = v end,
					order = 6
				},
				point = {
					name = "Anchor Points",
					desc = "This text's anchor point. These arguments are passed to text:SetPoint()",
					type = "group",
					args = {
						point = {
							name = "Text anchor",
							type = "select",
							values = anchors,
							get = function() return anchorsDict[db.point[1] or 1] end,
							set = function(info, v) db.point[1] = anchors[v] end,
							order = 1
						},
						relativeFrame = {
							name = "Relative Frame",
							type = "input",
							get = function() return db.point[2] end,
							set = function(info, v) db.point[2] = v end,
							order = 2
						},
						relativePoint = {
							name = "Relative Point",
							type = "select",
							values = anchors,
							get = function() return anchorsDict[db.point[3] or 1] end,
							set = function(info, v) db.point[3] = anchors[v] end,
							order = 3
						},
						xOfs = {
							name = "X Offset",
							type = "input",
							pattern = "%d",
							get = function() return tostring(db.point[4] or 0) end,
							set = function(info, v) db.point[4] = tonumber(anchors[v]) end,
							order = 4
						},
						yOfs = {
							name = "Y Offset",
							type = "input",
							pattern = "%d",
							get = function() return tostring(db.point[5] or 0) end,
							set = function(info, v) db.point[5] = tonumber(anchors[v]) end,
							order = 4						
						}
					},
					order = 7
				},
				top = {
					name = "First is Top",
					desc = "Toggle whether to place the first text on top",
					type = "toggle",
					get = function() return db.top end,
					set = function(info, v) 
						db.top = v; 
						db["topDirty"] = true						
						createTexts() 
					end,
					order = 8
				},
				value = {
					name = "Text expression",
					desc = "Enter the text's expression",
					type = "input",
					multiline = true,
					width = "full",
					get = function() return db.value end,
					set = function(info, v) 
						db.value = v; 
						db["valueDirty"] = true
						createTexts() 
					end,
					order = 9
				},
			}
		}
	end
end
]]