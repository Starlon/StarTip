if not DBM and not BigWigs then return end
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

-- Borrowed from BosModTTS
function mod:InitializeDBM()
	local sound = nil
	local timer = nil
	local text = nil
   
	local function ShowAnnounce(t)
	
	end
   
	local function NewAnnounce(announce, _, spellId, ...)
	if announce == nil then
		local spellName = spellId
		text = self.localization.warnings[spellId]
	else
		local spellName = GetSpellInfo(spellId) or "unknown"
         
		if announce == "move" or announce == "you" or announce == "warningspell" then
			if announce == "warningspell" then
				announce = "spell"
			end
           
			text = DBM_CORE_AUTO_SPEC_WARN_TEXTS[announce]:format(spellName)
            
		else
            local spellHaste = select(7, GetSpellInfo(53142)) / 10000 -- 53142 = Dalaran Portal, should have 10000 ms cast time
            local timer = (select(7, GetSpellInfo(spellId)) or 1000) / spellHaste
         
            text = DBM_CORE_AUTO_ANNOUNCE_TEXTS[announce]:format(spellName, (timer / 1000))		
		end
	end
	
	tinsert(history, text)
	end
      
	local function HookAnnounce(boss)      
		local mod = DBM:GetModByName(boss)
		local announces = mod.announces
      
		for i=1, #announces do
			StarTip:Hook(announces[i], "Show", ShowAnnounce)
		end
	end
		
   
	local function NewMod(_, boss, ...)
		local mod = DBM:GetModByName(boss)
      
		self.localization = DBM:GetModLocalization(boss)
      
		StarTip:SecureHook(mod, "NewTargetAnnounce", function(...) NewAnnounce("target", ...) end)
		StarTip:SecureHook(mod, "NewSpellAnnounce", function(...) NewAnnounce("spell", ...) end)
		StarTip:SecureHook(mod, "NewCastAnnounce", function(...) NewAnnounce("cast", ...) end)
		StarTip:SecureHook(mod, "NewAnnounce", function(...) NewAnnounce(nil, ...) end)
		StarTip:SecureHook(mod, "NewSpecialWarningMove", function(...) NewAnnounce("move", ...) end)
		StarTip:SecureHook(mod, "NewSpecialWarningYou", function(...) NewAnnounce("you", ...) end)
		StarTip:SecureHook(mod, "NewSpecialWarningSpell", function(...) NewAnnounce("warningspell", ...) end)
      
		timer = StarTip:ScheduleTimer(function() HookAnnounce(boss) end, 1)
	end 

	StarTip:SecureHook(DBM, "NewMod", NewMod)
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
end

function mod:OnEnable()
	if DBM then
		self:InitializeDBM()
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