--if not DBM and not BigWigs then return end
local mod = StarTip:NewModule("DeadlyWhispers")
mod.name = "DeadlyWhispers"
mod.toggled = true
mod.desc = "Show last DBM messages, such as whispers, announces, etc... You can filter out unwanted messages."

local _G = _G
local StarTip = _G.StarTip
local GameTooltip = _G.GameTooltip
local ShoppingTooltip1 = _G.ShoppingTooltip1
local ShoppingTooltip2 = _G.ShoppingTooltip2
local self = mod

local defaults = {
	profile = {
		delay = 3
	}
}

local options = {
	delay = {
		name = "Hide Delay",
		desc = "Enter the time to delay before hiding DeadlyWhispers",
		type = "input",
		get = function()
			return mod.db.profile.delay
		end,
		set = function(info, v)
			mod.db.profile.delay = v
		end,
		pattern = "%d",
		order = 5
	}
}

local history = {}

local messageFlag

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
end

function mod:OnEnable()
	if DBM then
	
	elseif BigWigs then
		local mod = BigWigs:GetBossModule(module)
				
		local function NewBoss(module, ...)
			local mod = BigWigs:GetBossModule(module)         
			-StarTip:SecureHook(mod, "DelayedMessage", function(key, delay, text, ...) tinsert(history, text) end)         
		end
		
		StarTip:SecureHook(BigWigs, "NewBoss", NewBoss)
	end
	
	history[1] = "Test"
	history[2] = "foo"
end

function mod:OnDisable()
	local mod = BigWigs:GetBossModule(module)
	StarTip:RemoveHook(mod, "DelayMessage")
end

function mod:GetOptions()
	return options
end

local skip
local function hideDW()
	skip = true
	GameTooltip:SetUnit("mouseover")
	skip = nil
end

function mod:SetUnit()
	if #history == 0 or skip then return end
	
	if #history > 10 then
		tremove(history, #history)
	end
	GameTooltip:ClearLines()
	GameTooltip:AddLine("--- DeadlyWhispers ---")
	for i = 1, #history do
		GameTooltip:AddLine(history[i], 1, 1, 1)
	end
	
	StarTip:ScheduleTimer(hideDW, self.db.profile.delay)
end