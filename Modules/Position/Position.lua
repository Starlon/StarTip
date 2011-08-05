local mod = StarTip:NewModule("Position", "AceEvent-3.0", "AceHook-3.0")
mod.name = "Positioning"
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0")
local Evaluator = LibStub("LibScriptableUtilsEvaluator-1.0")
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local self = mod
local L = StarTip.L

local square = {L["Left"], L["Right"], L["Top"], L["Bottom"], L["Offscreen"]}
local squareDict = {[L["Left"]] = 1, [L["Right"]] = 2, [L["Top"]] = 3, [L["Bottom"]] = 4, [L["Offscreen"]] = 5}
local squareNames = {"LEFT", "RIGHT", "TOP", "BOTTOM"}

local defaults = {
	profile = {
		inCombat = 1,
		anchor = 1,
		unitFrames = 1,
		other = 1,
		refreshRate = 50,
		inCombatXOffset = 10,
		inCombatYOffset = 0,
		anchorXOffset = 10,
		anchorYOffset = 0,
		unitFramesXOffset = 10,
		unitFramesYOffset = 0,
		otherXOffset = 10,
		otherYOffset = 0,
		defaultUnitTooltipPos = 5,
		anchorScript = [[
-- Modify locals x and y.They're set to mouse cursor position to start.
local mod = StarTip:GetModule("Position")
x = x + mod.db.profile.anchorXOffset
y = y + mod.db.profile.anchorYOffset
]],
		inCombatScript = [[
-- Modify locals x and y.They're set to mouse cursor position to start.
local mod = StarTip:GetModule("Position")
x = x + mod.db.profile.inCombatXOffset
y = y + mod.db.profile.inCombatYOffset
]],
		unitFramesScript = [[
-- Modify locals x and y.They're set to mouse cursor position to start.
local mod = StarTip:GetModule("Position")
x = x + mod.db.profile.unitFramesXOffset
y = y + mod.db.profile.unitFramesYOffset
]],
		otherScript = [[
-- Modify locals x and y.They're set to mouse cursor position to start.
local mod = StarTip:GetModule("Position")
x = x + mod.db.profile.otherXOffset
y = y + mod.db.profile.otherYOffset
]],
		animationInit = [[
t = 0
]],
		animationFrame = [[
t = t - 5
v = 0
]],
		animationPoint = [[
d=(v*0.3); r=t+i*PI*0.02; x=cos(r)*d; y=sin(r)*d
]]
		
	}
}
mod.defaults = defaults

local selections = {}
for i, v in ipairs(StarTip.anchorText) do
	selections[i] = v
end
selections[#selections+1] = "Hide"

local get = function(info)
	return self.db.profile[info[#info]]
end

local set = function(info,v)
	self.db.profile[info[#info]] = v
end

local inputGet = function(info)
	return tostring(self.db.profile[info[#info]] or 0)
end

local inputSet = function(info, v)
	self.db.profile[info[#info]] = tonumber(v)
end

local minX = -math.floor(GetScreenWidth()/5 + 0.5) * 5
local minY = -math.floor(GetScreenHeight()/5 + 0.5) * 5
local maxX = math.floor(GetScreenWidth()/5 + 0.5) * 5
local maxY = math.floor(GetScreenHeight()/5 + 0.5) * 5

local options = {
	anchor = {
		name = L["World Units"],
		desc = L["Where to anchor the tooltip when mousing over world characters"],
		type = "select",
		values = selections,
		get = get,
		set = set,
		order = 4
	},
	anchorXOffset = {
		name = format(L["X-axis offset: %d-%d"], minX, maxX),
		desc = L["The x-axis offset used to position the tooltip in relationship to the anchor point"],
		type = "input",
		pattern = "%d",
		get = inputGet,
		set = inputSet,
		validate = function(info, val)
			val = tonumber(val)
			return val >= minX and val <= maxX 
		end,		
		order = 5
	},
	anchorYOffset = {
		name = format(L["Y-axis offset: %d-%d"], minY, maxY),
		desc = L["The y-axis offset used to position the tooltip in relationship to the anchor point"],
		type = "input",
		pattern = "%d",
		get = inputGet,
		set = inputSet,
		validate = function(info, val)
			val = tonumber(val)
			return val >= minY and val <= maxY
		end,		
		order = 6
	
	},
	inCombatHeader = {
		name = "",
		type = "header",
		order = 7
	},
	inCombat = {
		name = L["In Combat"],
		desc = L["Where to anchor the world unit tooltip while in combat"],
		type = "select",
		values = selections,
		get = get,
		set = set,
		order = 8
	},
	inCombatXOffset = {
		name = format(L["X-axis offset: %d-%d"], minX, maxX),
		desc = L["The x-axis offset used to position the tooltip in relationship to the anchor point"],
		type = "input",
		pattern = "%d",
		get = inputGet,
		set = inputSet,
		validate = function(info, val)
			val = tonumber(val)
			return val >= minX and val <= maxX 
		end,
		order = 9
	},
	inCombatYOffset = {
		name = format(L["Y-axis offset: %d-%d"], minY, maxY),
		desc = L["The y-axis offset used to position the tooltip in relationship to the anchor point"],
		type = "input",
		pattern = "%d",
		get = inputGet,
		set = inputSet,
		validate = function(info, val)
			val = tonumber(val)
			return val >= minY and val <= maxX 
		end,
		order = 10,
	},	
	unitFramesHeader = {
		name = "",
		type = "header",
		order = 11
	},
	unitFrames = {
		name = L["Unit Frames"],
		desc = L["Where to anchor the tooltip when mousing over a unit frame"],
		type = "select",
		values = selections,
		get = get,
		set = set,
		order = 12
	},
	unitFramesXOffset = {
		name = format(L["X-axis offset: %d-%d"], minX, maxX),
		desc = L["The x-axis offset used to position the tooltip in relationship to the anchor point"],
		type = "input",
		pattern = "%d",
		get = inputGet,
		set = inputSet,
		validate = function(info, val)
			val = tonumber(val)
			return val >= minX and val <= maxX
		end,
		order = 13
	},
	unitFramesYOffset = {
		name = format(L["Y-axis offset: %d-%d"], minY, maxY),
		desc = L["The y-axis offset used to position the tooltip in relationship to the anchor point"],
		type = "input",
		pattern = "%d",
		get = inputGet,
		set = inputSet,
		validate = function(info, val)
			val = tonumber(val)
			return val >= minY and val <= maxY
		end,
		order = 14
	},	
	otherHeader = {
		name = "",
		type = "header",
		order = 15
	},
	other = {
		name = L["Other tooltips"],
		desc = L["Where to anchor most other tooltips"],
		type = "select",
		values = selections,
		get = get,
		set = set,
		order = 16
	},
	otherXOffset = {
		name = format(L["X-axis offset: %d-%d"], minX, maxX),
		desc = L["The x-axis offset used to position the tooltip in relationship to the anchor point"],
		type = "input",
		pattern = "%d",
		get = inputGet,
		set = inputSet,
		validate = function(info, val)
			val = tonumber(val)
			return val >= minX and val <= maxX
		end,
		order = 17
	},
	otherYOffset = {
		name = format(L["Y-axis offset: %d-%d"], minY, maxY),
		desc = L["The y-axis offset used to position the tooltip in relationship to the anchor point"],
		type = "input",
		pattern = "%d",
		get = inputGet,
		set = inputSet,
		validate = function(info, val) 
			val = tonumber(val)
			return val >= minY and val <= maxY
		end,
		order = 18
	},	
	defaultUnitTooltipPos = {
		name = "Position UI Tooltip",
		type = "select",
		values = square,
		get = function() return mod.db.profile.defaultUnitTooltipPos end,
		set = function(info, val)
			mod.db.profile.defaultUnitTooltipPos = val
		end,
		order = 20
	},
	refreshRate = {
		name = "Refresh Rate",
		type = "input",
		pattern = "%d",
		get = function() return tostring(mod.db.profile.refreshRate) end,
		set = function(info, val) mod.db.profile.refreshRate = tonumber(val) end,
		order = 21
	},	
	anchorScript = {
		name = "Gametooltip Non-Unit",
		type = "input",
		multiline = true,
		width = "full",
		get = function() return mod.db.profile.anchorScript end,
		set = function(info, val)
			mod.db.profile.anchorScript = val
		end,
		order = 22
	},
	inCombatScript = {
		name = "Gametooltip Is-Unit",
		type = "input",
		multiline = true,
		width = "full",
		get = function() return mod.db.profile.inCombatScript end,
		set = function(info, val)
			mod.db.profile.inCombatScript = val
		end,
		order = 23
	},
	unitFramesScript = {
		name = "Tooltip Main",
		type = "input",
		multiline = true,
		width = "full",
		get = function() return mod.db.profile.unitFramesScript end,
		set = function(info, val)
			mod.db.profile.unitFramesScript = val
		end,
		order = 24
	},
	otherScript = {
		name = "Other objects",
		type = "input",
		multiline = true,
		width = "full",
		get = function() return mod.db.profile.otherScript end,
		set = function(info, val) mod.db.profile.otherScript = val end,
		order = 25
	},
	animationInit = {
		name = "Animation Init Script",
		type = "input",
		multiline = true,
		width = "full",
		get = function() return mod.db.profile.animationInit end,
		set = function(info, val) mod.db.profile.animationInit = val end,
		order = 26
	},
	animationFrame = {
		name = "Animation Frame Script",
		type = "input",
		multiline = true,
		width = "full",
		get = function() return mod.db.profile.animationFrame end,
		set = function(info, val) mod.db.profile.animationFrame = val end,
		order = 27
	},
	animationPoint = {
		name = "Animation Point Script",
		type = "input",
		multiline = true,
		width = "full",
		get = function() return mod.db.profile.animationPoint end,
		set = function(info, val) mod.db.profile.animationPoint = val end,
		order = 28
	}
}

local PositionTooltip, PositionMainTooltip
function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
end

function mod:OnEnable()
	self:RegisterEvent("REGEN_DISABLED")
	self:RegisterEvent("REGEN_ENABLED")
	self:SecureHook("GameTooltip_SetDefaultAnchor")
	StarTip:SetOptionsDisabled(options, false)
	self.updateTimer = LibTimer:New("Position timer", self.db.profile.refreshRate, true, PositionTooltip)
	self.fakeUpdateTimer = LibTimer:New("Position fake timer", self.db.profile.refreshRate, true, PositionMainTooltip)
	self.environment = {}
	for k, v in pairs(StarTip.environment) do
		self.environment[k] = v
	end
        Evaluator.ExecuteCode(self.environment, "StarTip.Position.animationInit", mod.db.profile.animationInit)
end

function mod:OnDisable()
	self:UnregisterEvent("REGEN_DISABLED")
	self:UnregisterEvent("REGEN_ENABLED")
	self:Unhook("GameTooltip_SetDefaultAnchor")
	StarTip:SetOptionsDisabled(options, true)
end

function mod:GetOptions()
	return options
end

local currentOwner
local currentThis
local getIndex = function()
	local index = self.db.profile.other
	if GameTooltip:GetUnit() and UnitExists(StarTip.unit) then
		if InCombatLockdown() then
			index = self.db.profile.inCombat
		elseif currentOwner == UIParent then
			index = self.db.profile.anchor
		else
			index = self.db.profile.unitFrames
		end
	else
		index = self.db.profile.other
	end
	return index
end

function mod:GetPosition(x, y)
	local environment = self.environment
	environment.x = x
	environment.y = y
	if currentOwner == UIParent then
		if UnitExists(StarTip.unit) then
			if InCombatLockdown() then
				Evaluator.ExecuteCode(environment, "StarTip.Position.inCombat", self.db.profile.inCombatScript)
			else
				Evaluator.ExecuteCode(environment, "StarTip.Position.inCombat", self.db.profile.anchorScript)
			end
		else
			Evaluator.ExecuteCode(environment, "StarTip.Position.other", self.db.profile.otherScript)
		end
	else
		if UnitExists(StarTip.unit) then
			Evaluator.ExecuteCode(environment, "StarTip.Position.unitFrameScript", self.db.profile.unitFramesScript)
		else
			Evaluator.ExecuteCode(environment, "StarTip.Position.other", self.db.profile.otherScript)
		end
	end
	return environment.x, environment.y
end

local function hideGameTooltip()
	GameTooltip:ClearAllPoints()
	GameTooltip:SetClampRectInsets(10000, 0, 0, 0)
	GameTooltip:SetPoint("RIGHT", UIParent, "LEFT")
end

local isUnitTooltip
local currentAnchor = "BOTTOM"
PositionTooltip = function()
	local environment = mod.environment
	local effScale = GameTooltip:GetEffectiveScale()
	local x, y = GetCursorPosition()

	environment.relativeFrame = UIParent

	x, y = mod:GetPosition(x, y) -- execute user script


	local xx, yy = Evaluator.ExecuteCode(mod.environment, "Position.animation", mod.db.profile.animation)
	
	local index = getIndex(environment.anchorFrame)
	local anchor =  environment.anchor or StarTip.opposites[StarTip.anchors[index]:sub(8)]
	local relative = environment.relativeRelative or "BOTTOMLEFT"
	environment.anchor = false
	environment.anchorRelative = false

	if not isUnitTooltip then
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint(anchor, environment.relativeFrame, relative, x / effScale, y / effScale)
	end

	if UnitExists(StarTip.unit or "mouseover") then
		if mod.db.profile.defaultUnitTooltipPos == 5 then
			hideGameTooltip()	
		else
			local pos = squareNames[self.db.profile.defaultUnitTooltipPos]
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint(StarTip.opposites[pos], StarTip.tooltipMain, pos)
		end
	end

end
	local minX = -math.floor(GetScreenWidth()/5 + 0.5) * 5
	local minY = -math.floor(GetScreenHeight()/5 + 0.5) * 5
	local maxX = math.floor(GetScreenWidth()/5 + 0.5) * 5
	local maxY = math.floor(GetScreenHeight()/5 + 0.5) * 5

PositionMainTooltip = function()
	local tooltip = StarTip.tooltipMain
	local environment = mod.environment
	environment.effScale = tooltip:GetEffectiveScale()
	local x, y = GetCursorPosition()
	x, y = mod:GetPosition(x, y) -- execute user script
	mod.environment.i = (mod.environment.i or 0) + 1
	mod.environment.v = (mod.environment.v or 0) +  random() / 100
	Evaluator.ExecuteCode(mod.environment, "Position.animationPoint", mod.db.profile.animationPoint)
	local xx, yy = mod.environment.x, mod.environment.y
        x = x + floor((((xx or 0) + 1.0) * GetScreenWidth() * 0.01))
        y = y + floor((((yy or 0) + 1.0) * GetScreenHeight() * 0.01))

	local effScale = environment.effScale
	local anchor =  environment.anchor or "BOTTOMRIGHT"
	local relativeFrame = environment.relativeFrame or GameTooltip:GetParent()
	local anchorRelative = environment.anchorRelative or "BOTTOMLEFT"
	local index = getIndex(relativeFrame)
	environment.anchor = false
	environment.relativeFrame = false
	environment.anchorRelative = false

	if StarTip.anchors[index]:find("^CURSOR_")  then
		anchor = StarTip.opposites[StarTip.anchors[index]:sub(8)]
	end

	tooltip:ClearAllPoints()
	tooltip:SetPoint(anchor, relativeFrame, anchorRelative, x / effScale, y / effScale)
end

local updateTimer = LibTimer:New("Position timer", 40, true, PositionTooltip)
local fakeUpdateTimer = LibTimer:New("Position fake timer", 40, true, PositionMainTooltip)

--[[
mod:SetOffsets = function()
	if currentOwner == UIParent then
		if UnitExists(StarTip.unit) then
			if InCombatLockdown() then
				xoffset = self.db.profile.inCombatXOffset
				yoffset = self.db.profile.inCombatYOffset
			else
				xoffset = self.db.profile.anchorXOffset
				yoffset = self.db.profile.anchorYOffset
			end
		else
			xoffset = self.db.profile.otherXOffset
			yoffset = self.db.profile.otherYOffset
		end
	else
		if UnitExists(StarTip.unit) then
			xoffset = self.db.profile.unitFramesXOffset
			yoffset = self.db.profile.unitFramesYOffset
		else
			xoffset = self.db.profile.otherXOffset
			yoffset = self.db.profile.otherYOffset
		end
	end
end
]]

local function delayAnchor()
	local this = currentThis
	local owner = currentOwner
	local index = getIndex(owner)

	if index == #selections then
		this:Hide()
		return
	elseif StarTip.anchors[index]:find("^CURSOR_")  then
		currentAnchor = StarTip.opposites[StarTip.anchors[index]:sub(8)]
		isUnitTooltip = false
		if GameTooltip:GetUnit() then
			isUnitTooltip = true
			fakeUpdateTimer:Start()
			PositionMainTooltip()
		end
		updateTimer:Start()
		PositionTooltip()
	elseif GameTooltip:GetUnit() then
		fakeUpdateTimer:Stop()
		updateTimer:Stop()
		StarTip.envirnoment.x = 0
		mod.environment.y = 0
		Evaluator.ExecuteCode(mod.environment, "StarTip.Position", mod.db.profile.anchorScript)
		StarTip.tooltipMain:ClearAllPoints()
		StarTip.tooltipMain:SetPoint(StarTip.anchors[index], UIParent, StarTip.anchors[index], mod.environment.x, mod.environment.y)
	else
		fakeUpdateTimer:Stop()
		updateTimer:Stop()
		GameTooltip:ClearAllPoints()
		mod.environment.x = 0
		mod.environment.y = 0
		mod.environment.i = index
		Evaluator.ExecuteCode(mod.environment, "StarTip.Position", mod.db.profile.otherScript)
		index = StarTip.envirnment.i
		local anchor = StarTip.anchor or StarTip.anchors[index]
		local relative = StarTip.anchorRelative or anchor
		GameTooltip:SetPoint(anchor, UIParent, anchorRelative, mod.environment.x, mod.environment.y)
		StarTip.anchor = false
	end
end
local delayTimer = LibTimer:New("Position delay timer", 30, false, delayAnchor)

function mod:GameTooltip_SetDefaultAnchor(this, owner)
	currentOwner = owner
	currentThis = this
	local index = getIndex(owner)
	local ownername = owner:GetName()

	Evaluator.ExecuteCode(mod.environment, "StarTip.Position.animationFrame", self.db.profile.animationFrame)

	if owner == MainMenuMicroButton then -- This one is troublesome, so single it out and anchor right away.
		delayAnchor() 
	else
		delayTimer:Start()
	end
end

function mod:REGEN_DISABLED()
	if not currentOwner then return end
	updateFrame:SetScript("OnUpdate", nil)
	self:GameTooltip_SetDefaultAnchor(GameTooltip, currentOwner)
end

mod.REGEN_ENABLED = mod.REGEN_DISABLED

function mod:OnHide()
	updateTimer:Stop()
	delayTimer:Stop()
	fakeUpdateTimer:Stop()
end

function mod:SetSpell()
	local index = getIndex(currentOwner)
	if StarTip.anchors[index]:find("^CURSOR_")  then
		updateTimer:Stop()
		PositionTooltip()
	else
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint(StarTip.anchors[index], UIParent, StarTip.anchors[index], xoffset, yoffset)
	end
end

function mod:SetItem()
	local index = getIndex(currentOwner)
	if StarTip.anchors[index]:find("^CURSOR_")  then
		updateTimer:Stop()
		PositionTooltip()
	else
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint(StarTip.anchors[index], UIParent, StarTip.anchors[index], xoffset, yoffset)
	end
end

function mod:SetUnit()
	local index = getIndex(currentOwner)
	if not StarTip.anchors[index]:find("^CURSOR_") then
		hideGameTooltip()
	end
end
