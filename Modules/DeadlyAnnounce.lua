--if not DBM and not BigWigs then return end
local mod = StarTip:NewModule("DeadlyAnnounce")
mod.name = "DeadlyAnnounce"
mod.toggled = true
mod.desc = "Show the last DBM announcements."
mod.defaultOff = true
local LibQTip = LibStub('LibQTip-1.0')
local _G = _G
local StarTip = _G.StarTip
local GameTooltip = _G.GameTooltip
local ShoppingTooltip1 = _G.ShoppingTooltip1
local ShoppingTooltip2 = _G.ShoppingTooltip2
local self = mod
local begin = GetTime()

local anchorText = {
	"Top",
	"Top-right",
	"Top-left",
	"Bottom",
	"Bottom-right",
	"Bottom-left",
	"Left",
	"Right",
	"Single Tooltip"
}

local defaults = {
	profile = {
		delay = 3,
		hide = true,
		position = #anchorText,
		onctrl = true
	},
}

local options = {
	hide = {
		name = "Hide DeadlyAnnounce",
		desc = "Toggle whether to hide DeadlyAnnounce after a delay",
		type = "toggle",
		get = function()
			return mod.db.profile.hide
		end,
		set = function(info, v)
			mod.db.profile.hide = v
		end,
		order = 5
	},
	delay = {
		name = "Hide Delay",
		desc = "Enter the time to delay before hiding DeadlyAnnounce",
		type = "input",
		get = function()
			return mod.db.profile.delay
		end,
		set = function(info, v)
			mod.db.profile.delay = v
		end,
		pattern = "%d",
		order = 6
	},
	position = {
		name = "Position",
		desc = "Select where to place tooltip.",
		type = "select",
		values = anchorText,
		get = function() return mod.db.profile.position end,
		set = function(info, v) mod.db.profile.position = v end,
		order = 7
	},
	onctrl = {
		name = "Hide On Ctrl",
		desc = "Whether to hide DeadlyAnnounce when you press the CTRL key.",
		type = "toggle",
		get = function() return mod.db.profile.onctrl end,
		set = function(info, v) mod.db.profile.onctrl = true end,
		order = 8
	}
}

local history = {}

-- Borrowed from BosModTTS
function mod:InitializeDBM()
	local sound = nil
	local timer = nil
	local text = nil
   
	local function ShowAnnounce(t)
		local new = StarTip.new()
		new.text = t.text
		new.time = _G.GetTime()
		tinsert(history, new)
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
			StarTip:SecureHook(mod, "DelayedMessage", function(key, delay, text, ...) tinsert(history, {text = text, time = GetTime()}) end)         
		end
		
		StarTip:SecureHook(BigWigs, "NewBoss", NewBoss)
	end
	
	--tinsert(history, {text = "Test", time = GetTime() - 5})
	--tinsert(history, {text = "Fobar", time = GetTime()})
end

function mod:OnDisable()
	if BigWigs then
		local mod = BigWigs:GetBossModule(module)
		StarTip:RemoveHook(mod, "DelayMessage")
	end
end

function mod:GetOptions()
	return options
end

local newFont, delFont
do
	local pool = {}
	newFont = function()
		local font = next(pool)
		if not font then
			font = CreateFont("DA")
		end
		pool[font] = nil
	end
	
	delFont = function(font)
		pool[font] = true
	end


end

local line = 1
function mod:AddLine(text1, text2, r, g, b)
	
	if not text1 then return end
	
	if not r then
		r = 1
		g = 1
		b = 1
	end
	
	if mod.db.profile.position == #anchorText then
		if text2 then
			GameTooltip:AddDoubleLine(text1, text2)
			StarTip.leftLines[line]:SetVertexColor(r, g, b)
			StarTip.rightLines[line]:SetVertexColor(r, g, b)
		else
			GameTooltip:AddLine(text1)
			StarTip.leftLines[line]:SetVertexColor(r, g, b)
		end
	else
		local font = newFont()
		font:CopyFontObject(StarTip.leftLines[1]:GetFontObject())
		font:SetTextColor(r, g, b)
		self.tooltip:SetFont(font)
		delFont(font)
		self.tooltip:AddLine(text1, text2)
	end
	
	line = line + 1
end

local function hideAll()
	StarTip.HideAll()
	mod.hideTimer = nil
end

local skip
function hideDW()
	skip = true
	GameTooltip:SetUnit("mouseover")
	skip = false
	mod.shown = false
	mod.hideDWTimer = nil
	mod.count = 0
end

local lastGuid
function mod:SetUnit()

	if self.modifier then return end
	
	line = 1

	if mod.shown and (mod.count or 0) > 3 then
		mod.count = 0
		return
	end
	
	if self.hideDWTimer and mod.shown then
		StarTip:CancelTimer(self.hideDWTimer)
		mod.shown = false
	end
	
	if skip or mod.shown then return end
	
	if mod.db.profile.position == #anchorText then
		GameTooltip:ClearLines()
	else	
		self.tooltip = LibQTip:Acquire("DeadlyAnnounce", 2, "LEFT", "CENTER", "CENTER", "CENTER","RIGHT")
	end

	self:AddLine("--- Deadly Announce ---")
	
	if #history == 0 then 
		self:AddLine("Nothing to show", nil, 1, 0, 0)
		StarTip:ScheduleTimer(hideDW, self.db.profile.delay)
		return
	end
	
	if #history > 10 then
		local tmp = history[#history]
		StarTip.del(tmp)
		tremove(history, #history)
	end
		
	local length = 0
	
	for i = #history - 1, 1, -1 do
		local time = history[i].time - history[i + 1].time
		length = length + time
	end
	
	for i = #history, 1, -1 do
		local time = GetTime()
		time = time - history[i].time
		self:AddLine(history[i].text, nil, 1, 0, 0)
	end

	self.hideTimer = StarTip:ScheduleTimer(hideAll, .1)
	
	self.hideDWTimer = StarTip:ScheduleTimer(hideDW, self.db.profile.delay)
	
	self.shown = true
	
	self.count = (self.count or 0) + 1
end

function mod:MODIFIER_STATE_CHANGED(ev, modifier, up, ...)
	local mod = (modifier == "LCTRL" or modifier == "RCTRL") and "LCTRL"
	
	if mod ~= "LCTRL" or not self:IsEnabled() then
		return
	end
	
	if self.db.profile.onctrl then
		if self.hideTimer and StarTip.TimeLeft and StarTip:TimeLeft(self.hideTimer) > 0 then
			StarTip:CancelTimer(self.hideTimer)
		end
		if self.hideDWTimer and StarTip.TimeLeft and StarTip:TimeLeft(self.hideDWTimer) > 0 then
			StarTip:CancelTimer(self.hideDWTimer)
		end
		hideDW()
	end
end