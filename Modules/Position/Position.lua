local mod = StarTip:NewModule("Position", "AceEvent-3.0", "AceHook-3.0")
mod.name = "Positioning"
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0")
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
		inCombatXOffset = 10,
		inCombatYOffset = 0,
		anchorXOffset = 10,
		anchorYOffset = 0,
		unitFramesXOffset = 10,
		unitFramesYOffset = 0,
		otherXOffset = 10,
		otherYOffset = 0,
		defaultUnitTooltipPos = 5
		
	}
}

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
	--[[anchorXOffset = {
		name = "X-axis offset",
		desc = "The x-axis offset used to position the tooltip in relationship to the anchor point",
		type = "range",
		min = minX,
		max = maxX,
		step = 1,
		bigStep = 5,
		get = get,
		set = set,
		order = 5
	},
	anchorYOffset = {
		name = "Y-axis offset",
		desc = "The y-axis offset used to position the tooltip in relationship to the anchor point",
		type = "range",
		min = minY,
		max = maxY,
		step = 1,
		bigStep = 5,
		get = get,
		set = set,
		order = 6
	
	},]]
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
	--[[inCombatXOffset = {
		name = "X-axis offset",
		desc = "The x-axis offset used to position the tooltip in relationship to the anchor point",
		type = "range",
		min = minX,
		max = maxX,
		step = 1,
		bigStep = 5,
		get = get,
		set = set,
		order = 9
	},
	inCombatYOffset = {
		name = "Y-axis offset",
		desc = "The y-axis offset used to position the tooltip in relationship to the anchor point",
		type = "range",
		min = minY,
		max = maxY,
		step = 1,
		bigStep = 5,
		get = get,
		set = set,
		order = 10
	},]]
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
	--[[unitFramesXOffset = {
		name = "X-axis offset",
		desc = "The x-axis offset used to position the tooltip in relationship to the anchor point",
		type = "range",
		min = minX,
		max = maxX,
		step = 1,
		bigStep = 5,
		get = get,
		set = set,
		order = 13
	},
	unitFramesYOffset = {
		name = "Y-axis offset",
		desc = "The y-axis offset used to position the tooltip in relationship to the anchor point",
		type = "range",
		min = minY,
		max = maxY,
		step = 1,
		bigStep = 5,
		get = get,
		set = set,
		order = 14
	},]]
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
	--[[otherXOffset = {
		name = "X-axis offset",
		desc = "The x-axis offset used to position the tooltip in relationship to the anchor point",
		type = "range",
		min = minX,
		max = maxX,
		step = 1,
		bigStep = 5,
		get = get,
		set = set,
		order = 17
	},
	otherYOffset = {
		name = "Y-axis offset",
		desc = "The y-axis offset used to position the tooltip in relationship to the anchor point",
		type = "range",
		min = minY,
		max = maxY,
		step = 1,
		bigStep = 5,
		get = get,
		set = set,
		order = 18
	}]]
	defaultUnitTooltipPos = {
		name = "Position UI Tooltip",
		type = "select",
		values = square,
		get = function() return mod.db.profile.defaultUnitTooltipPos end,
		set = function(info, val)
			mod.db.profile.defaultUnitTooltipPos = val
		end,
		order = 20
	}
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	self.timer = LibTimer:New("Position.timer ", 100, false, positionTooltip)
end

function mod:OnEnable()
	self:RegisterEvent("REGEN_DISABLED")
	self:RegisterEvent("REGEN_ENABLED")
	self:SecureHook("GameTooltip_SetDefaultAnchor")
	StarTip:SetOptionsDisabled(options, false)
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

local getIndex = function(owner)
	local index
	if UnitExists(StarTip.unit) then
		if InCombatLockdown() then
			index = self.db.profile.inCombat
		elseif owner == UIParent then
			index = self.db.profile.anchor
		else
			index = self.db.profile.unitFrames
		end
	else
		index = self.db.profile.other
	end
	return index
end

local function hideGameTooltip()
	GameTooltip:ClearAllPoints()
	GameTooltip:SetClampRectInsets(10000, 0, 0, 0)
	GameTooltip:SetPoint("RIGHT", UIParent, "LEFT")
end

local isUnitTooltip
local updateFrame = CreateFrame("Frame")
local fakeUpdateFrame = CreateFrame("Frame")
local currentAnchor = "BOTTOM"
local xoffset, yoffset = 0, 0
local positionTooltip = function()
	local x, y = GetCursorPosition()
	
	local effScale = GameTooltip:GetEffectiveScale()
	
	if not isUnitTooltip then
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint(currentAnchor, UIParent, "BOTTOMLEFT", (x + xoffset) / effScale, (y + yoffset) / effScale + 5)
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

local positionMainTooltip = function()
	local x, y = GetCursorPosition()

	local index = getIndex(UIParent)
	local currentAnchor = StarTip.opposites[StarTip.anchors[index]:sub(8)]
	local tooltip = StarTip.tooltipMain
	local effScale = tooltip:GetEffectiveScale()

	tooltip:ClearAllPoints()
	tooltip:SetPoint(currentAnchor, UIParent, "BOTTOMLEFT", 
		(x + xoffset) / effScale, (y + yoffset) / effScale)
end


local setOffsets = function(owner)
	if owner == UIParent then
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

local currentOwner
local currentThis
local delayFrame = CreateFrame("Frame")
local function delayAnchor()
	delayFrame:SetScript("OnUpdate", nil)
	
	local this = currentThis
	local owner = currentOwner
	setOffsets(owner)
	local index = getIndex(owner)
	if index == #selections then
		this:Hide()
		return
	elseif StarTip.anchors[index]:find("^CURSOR_")  then
		oldX, oldY = 0, 0
		currentAnchor = StarTip.opposites[StarTip.anchors[index]:sub(8)]
		isUnitTooltip = false
		if GameTooltip:GetUnit() then
			isUnitTooltip = true
			fakeUpdateFrame:SetScript("OnUPdate", positionMainTooltip)
			positionMainTooltip()
		end
		updateFrame:SetScript("OnUpdate", positionTooltip)
		positionTooltip()
	else
		if updateFrame:GetScript("OnUpdate") then updateFrame:SetScript("OnUpdate", nil) end
		if fakeUpdateFrame:GetScript("OnUpdate") then fakeUpdateFrame:SetScript("OnUpdate", nil) end
		StarTip.tooltipMain:ClearAllPoints()
		StarTip.tooltipMain:SetPoint(StarTip.anchors[index], UIParent, StarTip.anchors[index], xoffset, yoffset)
		hideGameTooltip()
	end
end

function mod:GameTooltip_SetDefaultAnchor(this, owner)
	currentOwner = owner
	currentThis = this
	delayFrame:SetScript("OnUpdate", delayAnchor)
end

function mod:REGEN_DISABLED()
	if not currentOwner then return end
	updateFrame:SetScript("OnUpdate", nil)
	self:GameTooltip_SetDefaultAnchor(GameTooltip, currentOwner)
end

mod.REGEN_ENABLED = mod.REGEN_DISABLED

function mod:OnHide()
	updateFrame:SetScript("OnUpdate", nil)
	delayFrame:SetScript("OnUpdate", nil)
	fakeUpdateFrame:SetScript("OnUpdate", nil)
end

function mod:SetSpell()
	local index = getIndex(currentOwner)
	if StarTip.anchors[index]:find("^CURSOR_")  then
		updateFrame:SetScript("OnUpdate", nil)
		positionTooltip()
	else
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint(StarTip.anchors[index], UIParent, StarTip.anchors[index], xoffset, yoffset)
	end
end

function mod:SetItem()
	local index = getIndex(currentOwner)
	if StarTip.anchors[index]:find("^CURSOR_")  then
		updateFrame:SetScript("OnUpdate", nil)
		positionTooltip()
	else
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint(StarTip.anchors[index], UIParent, StarTip.anchors[index], xoffset, yoffset)
	end
end

