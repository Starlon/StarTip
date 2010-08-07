if not DBM then return end
local mod = StarTip:NewModule("DeadlyWhispers")
mod.name = "Who"
mod.desc = "Show last DBM messages, such as whispers, announces, etc... You can filter out unwanted messages."

local _G = _G
local StarTip = _G.StarTip
local GameTooltip = _G.GameTooltip
local ShoppingTooltip1 = _G.ShoppingTooltip1
local ShoppingTooltip2 = _G.ShoppingTooltip2
local self = mod

local defaults = {
	profile = {
		watchList = {},
		modifier = 1
	}
}

local options = {}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
end

function mod:OnEnable()
	--StarTip:SecureHook(FriendsFrame, "Show", mod.FriendFrameShow)
end

function mod:OnDisable()
end

function mod:GetOptions()
	return options
end

function mod:SetUnit()
	
end