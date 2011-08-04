local mod = StarTip:NewModule("Clamp", "AceHook-3.0")
mod.name = "Clamp"
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UnitExists = _G.UnitExists
local self = mod
local L = StarTip.L
local Evaluator = LibStub("LibScriptableUtilsEvaluator-1.0")

local defaults = {
	profile = {
		script = [[
local clampLeft, clampRight, clampTop, clampBottom = 0, 10, 10, 0
return clampLeft, clampRight, clampTop, clampBottom
]],
	}
}

local get = function(info)
	return self.db.profile[info[#info]]
end

local set = function(info, v)
	self.db.profile[info[#info]] = v
end

local options = {
	script = {
		name = L["Script"],
		desc = L["This will be ran when the tooltip shows."],
		type = "input",
		width = "half",
		multiline = true,
		get = get,
		set = set,
		order = 4
	},
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	self:SecureHook("GameTooltip_SetDefaultAnchor")
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
end

function mod:GetOptions()
	return options
end

function mod:GameTooltip_SetDefaultAnchor(this, owner)
	local cleft, cright, ctop, cbottom = Evaluator.ExecuteCode(StarTip.environment, "StarTip.Clamp", self.db.profile.script)
        StarTip.tooltipMain:SetClampRectInsets(cleft or 0, cright or 0, ctop or 0, cbottom or 0)
        StarTip.tooltipMain:SetClampedToScreen(true)
	GameTooltip:SetClampedToScreen(true)
end

