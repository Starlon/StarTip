local mod = StarTip:NewModule("Text", "AceTimer-3.0")
mod.name = "Text"
mod.toggled = true
mod.childGroup = true
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
	["Name"] = {
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
	["Health"] = {
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
	["Mana"] = {
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
}

local defaults = {
	profile = {
		classColors = true,
	}
}

local options = {
	add = {
		name = "Add Text",
		desc = "Add a text widget",
		type = "input",
		set = function(info, v)
			mod.db.profile.texts[v] = {
				type = "text",
				min = "return 0",
				max = "return 100",
				height = 6,
				point = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT"},
				texture = LSM:GetDefault("statustext"),
				expression = ""
			}
			StarTip:RebuildOpts()
			createTexts()
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
			StarTip:Print("Bug: You'll have to reload your UI to see the change in the texts list. I'm not sure why.")
		end,
		order = 6
	},
	texts = {
		name = "Texts",
		type = "group",
		args = {}
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

function createTexts()
	if type(mod.texts) ~= "table" then mod.texts = {} end
	--[[for k, v in pairs(mod.texts) do
		v:Del()
		v.text:Hide()
		del(v.text)
	end]]
	local appearance = StarTip:GetModule("Appearance")	
	for k, v in pairs(self.db.profile.texts) do
		if v.enabled then
			local text = new(v.cols or WidgetText.defaults.cols)
			local cfg = copy(v)
			cfg.unit = StarTip.unit
			local widget = mod.texts[v] or WidgetText:New(mod.core, k, cfg, v.row or 0, v.col or 0, v.layer or 0, StarTip.db.profile.errorLevel, updateText) 
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
		for j, vv in ipairs(self.db.profile.lines) do
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

	for i, v in ipairs(defaultWidgets) do
		if not v.tagged and not v.deleted then
			tinsert(self.db.profile.texts, v)
		end
	end
	
	self.db.profile.texts = copy(defaultWidgets)
--[[	
	for k, v in pairs(defaultWidgets) do
		for kk, vv in pairs(self.db.profile.texts) do
			if v.name == vv.name then
				for k, val in pairs(v) do
					if v[k] ~= vv[k] and not vv[k.."Dirty"] then
						vv[k] = copy(v[k])
					end
				end
				v.tagged = true
			end
		end
	end
]]
	for k, v in pairs(defaultWidgets) do
		if not v.tagged and not v.deleted then
			self.db.profile.texts[k] = copy(v)
		end
	end
	
	self.core = LibCore:New(mod, environment, "StarTip.Texts", {["StarTip.Texts"] = {}}, nil, StarTip.db.profile.errorLevel)		
	
	StarTip:SetOptionsDisabled(options, true)

end

function mod:OnEnable()
	if not self.texts then self.texts = {} end
	
	for k, text in pairs(self.texts) do
		text.text:Hide()
	end
	createTexts()
	GameTooltip:SetClampRectInsets(0, 0, 10, 10)
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	for k, text in pairs(self.texts) do
		text:Del()
		text.text:Hide()
	end
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
	
	for k, db in pairs(self.db.profile.texts) do
		options.texts.args[k:gsub(" ", "_")] = {
			name = k,
			type="group",
			order = 6,
			args=WidgetText:GetOptions(StarTip, db)
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