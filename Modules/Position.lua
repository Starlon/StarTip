local mod = StarTip:NewModule("Position", "AceEvent-3.0", "AceHook-3.0")
mod.name = "Positioning"
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local self = mod

local defaults = {
	profile = {
		inCombat = 1,
		anchor = 1,
		unitFrames = 13,
		other = 1,
		inCombatXOffset = 0,
		inCombatYOffset = 0,
		anchorXOffset = 0,
		anchorYOffset = 0,
		unitFramesXOffset = 0,
		unitFramesYOffset = 0,
		otherXOffset = 0,
		otherYOffset = 0
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

local minX = -math.floor(GetScreenWidth()/5 + 0.5) * 5
local minY = -math.floor(GetScreenHeight()/5 + 0.5) * 5
local maxX = math.floor(GetScreenWidth()/5 + 0.5) * 5
local maxY = math.floor(GetScreenHeight()/5 + 0.5) * 5
local options = {
	anchor = {
		name = "World Units",
		desc = "Where to anchor the tooltip when mousing over world characters",
		type = "select",
		values = selections,
		get = get,
		set = set,
		order = 4
	},
	anchorXOffset = {
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
	
	},
	inCombatHeader = {
		name = "",
		type = "header",
		order = 7
	},
	inCombat = {
		name = "In Combat",
		desc = "Where to anchor the world unit tooltip while in combat",
		type = "select",
		values = selections,
		get = get,
		set = set,
		order = 8
	},
	inCombatXOffset = {
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
	},
	unitFramesHeader = {
		name = "",
		type = "header",
		order = 11
	},
	unitFrames = {
		name = "Unit Frames",
		desc = "Where to anchor the tooltip when mousing over a unit frame",
		type = "select",
		values = selections,
		get = get,
		set = set,
		order = 12
	},
	unitFramesXOffset = {
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
	},
	otherHeader = {
		name = "",
		type = "header",
		order = 15
	},
	other = {
		name = "Other tooltips",
		desc = "Where to anchor tooltips that are not unit tooltips",
		type = "select",
		values = selections,
		get = get,
		set = set,
		order = 16
	},
	otherXOffset = {
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
	}
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
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

local updateFrame = CreateFrame("Frame")
local oldX, oldY
local currentAnchor
local xoffset, yoffset
local positionTooltip = function()
	local x, y = GetCursorPosition()
	
	local effScale = GameTooltip:GetEffectiveScale()
	
	if x ~= oldX or y ~= oldY then
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint(currentAnchor, UIParent, "BOTTOMLEFT", (x + xoffset) / effScale, (y + yoffset) / effScale)
	end
	oldX, oldY = x, y
end

local getIndex = function(owner)
	local index
	if UnitExists("mouseover") then
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

local setOffsets = function(owner)
	if owner == UIParent then
		if UnitExists("mouseover") then
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
		if UnitExists("mouseover") then
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
	local this = currentThis
	local owner = currentOwner
	this:ClearAllPoints()
	setOffsets(owner)
	local index = getIndex(owner)
	if index == #selections then
		this:Hide()
		return
	elseif StarTip.anchors[index]:find("^CURSOR_")  then
		oldX, oldY = 0, 0
		currentAnchor = StarTip.opposites[StarTip.anchors[index]:sub(8)]
		updateFrame:SetScript("OnUpdate", positionTooltip)
		positionTooltip()
	else
		if updateFrame:GetScript("OnUpdate") then updateFrame:SetScript("OnUpdate", nil) end
		this:SetPoint(StarTip.anchors[index], UIParent, StarTip.anchors[index], xoffset, yoffset)
	end
	delayFrame:SetScript("OnUpdate", nil)
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
end
