local mod = StarTip:NewModule("Gestures")
mod.name = "Gestures"
mod.toggled = true
mod.defaultOff = true
local L = StarTip.L
local WidgetGestures = LibStub("LibScriptableWidgetGestures-1.0")
local LibMouse = LibStub("LibMouseGestures-1.0")
local LibCore = LibStub("LibScriptableLCDCore-1.0")
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local gestures = {}
local environment = {}

-- LeftButtonDown
local buttonsList = {L["Left Button"], L["Right Button"], L["Center Button"]}
local buttons = {"LeftButton", "RightButton", "CenterButton"}
local directionsList = {L["Up"], L["Down"]}
local directions = {"Up", "Down"}

local defaults = {
	profile = {
		gestures = {}
	}
}

local defaultWidgets = {
	[1] = {
		name = "Wipe Data",
		enabled = false,
		minGestures = 4,
		gestures = {{type="line", pattern="right"}, {type="line", pattern="left"}, {type="line", pattern="right"}, {type="line", pattern="left"}},
		expression = [[
WipeDPS()
WipeNoise()
WipeInspect()
]]
	},
	[2] = {
		name = "Start Data",
		enabled = false,
		gestures = {{type="circle", pattern="clockwise"}},
		expression = [[
StartDPS()
StartNoise()
]]
	},
	[3] = {
		name = "Stop Data",
		enabled = false,
		gestures = {{type="circle", pattern="counterclockwise"}},
		expression = [[
StopDPS()
StopNoise()
]]
	},
	[4] = {
		name = "Draw",
		enabled = false,
		gestures = {},
		drawLayer = "ChatFrame1",
		expression = [[

]],
		startButton = "LeftButtonDown",
		stopButton = "LeftButtonUp",
		nextButton = "RightButtonDown",
		cancelBUtton = "RightButtonUp",
		startFunc = [[
return function(rec, a, b, c, d) 
print("startFunc")
    local self = rec.widgetData
    self.cdoodle = self.cdoodle or {}
    self.cdoodle.creator = self.name
    self.dw, self.dh = 1000, 1000
    rec.w, rec.h = self.drawLayer:GetWidth(), self.drawLayer:GetHeight()
end
]],
		updateFunc = [[
return function(rec, a, b, c, d)
print("updateFunc")
    local self = rec.widgetData
    if #rec.cdoodle > 0 then
        local l = rec.cdoodle[#rec.cdoodle]
        if l and (floor(l[1]) ~= floor(c) or floor(l[2]) ~= floor(d)) then
            local dist = sqrt( pow(l[1] - c, 2) + pow(l[2] - d, 2))
            if ( dist >= 3 and (rec.x ~= c or rec.y ~= d)) then
                tinsert(rec.cdoodle, {c*(self.dw/rec.w), d*(self.dh/rec.h), nil})
                rec.x, rec.y = c, d
            end
        end
    else
        table.insert(rec.cdoodle, {c*(self.dw/rec.w),d*(self.dh/rec.h), nil})
    end
    self:Draw()
end
]],
		stopFunc = false,
		stopFuncoff = [[
return function(rec, a, b, c, d)
print("Stop func")
    local sefl = rec.widgetData
    self:Draw()
    self:Start()
    rec.cdoodle = {creator=self.name}
end
]],

		nextFunc = [[
return function(rec, a, b, c, d)
print("nextFunc")
end
]],
		cancelFunc = [[
return function(rec, a, b, c, d)
print("cancelFunc")
    self:Start()
end
]],
		tooltip = false,

		maxGestures = 1,
		showTrail = true,
		tooltip = "Test"
		
		
	}
}

mod.defaults = defaults

local options = {}
local optionsDefaults = {
	add = {
		name = L["Add Gesture"],
		desc = L["Add a gesture"],
		type = "input",
		set = function(info, v)
			local widget = {
				name = v,
				type = "gesture",
				enabled = true,
				points = {{"TOPLEFT", "GameTooltip", "BOTTOMLEFT", 0, -50}},
				frame = "UIParent",
				expression = "return random(100)",
				custom = true
			}
			tinsert(mod.db.profile.gestures, widget)
			StarTip:RebuildOpts()

		end,
		order = 5
	},
	defaults = {
		name = L["Restore Defaults"],
		desc = L["Restore Defaults"],
		type = "execute",
		func = function()
			mod.db.profile.gestures = {}
			mod:WipeGestures()
			mod:ReInit()
			StarTip:RebuildOpts()
		end,
		order = 6
	},
}

local function copy(tbl)
	if type(tbl) ~= "table" then return tbl end
	local newTbl = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" or type(v) == "number" or type(v) == "string" then
			newTbl[k] = copy(v)
		end
	end
	return newTbl
end

function mod:CreateGestures()
	for i, gesture in ipairs(self.db.profile.gestures) do
		if gesture.enabled then
			local widget = WidgetGestures:New(self.core, gesture.name, copy(gesture), StarTip.db.profile.errorLevel, timer) 
			widget:Start()
			tinsert(gestures, widget)
		end
	end
end

function mod:WipeGestures()
	for i, gesture in ipairs(gestures) do
		gesture:Del()
	end
	wipe(gestures)
end

function mod:ReInit()
    self:WipeGestures()
    for k, v in ipairs(defaultWidgets) do
        for j, vv in ipairs(self.db.profile.gestures) do
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
    for k, v in ipairs(defaultWidgets) do
        if not v.tagged then
            tinsert(self.db.profile.gestures, copy(v))
        end
    end
    self:CreateGestures()
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	self.core = StarTip.core 
	self:ReInit() -- initialize database if needed
	StarTip:SetOptionsDisabled(options, true)
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
	self:CreateGestures()
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
	self:WipeGestures()
end

function mod:GetOptions()
	return options
end

function mod:RebuildOpts()
	local defaults = WidgetGestures.defaults
	self:WipeGestures()
	self:CreateGestures()
	wipe(options)
	for k, v in pairs(optionsDefaults) do
		options[k] = v
	end
	for i, db in ipairs(self.db.profile.gestures) do
		options[db.name:gsub(" ", "_")] = {
			name = db.name,
			type="group",
			order = i,
			args=WidgetGestures:GetOptions(db, StarTip.RebuildOpts, StarTip)
		}
		options[db.name:gsub(" ", "_")].args.delete = {
			name = L["Delete"],
			desc = L["Delete this widget"],
			type = "execute",
			func = function()
				self.db.profile.gestures[i] = {}
				StarTip:RebuildOpts()
			end,
			order = 100
		}
	end
end

