local mod = StarTip:NewModule("LCDDisplay")
mod.name = "LCD Display"
mod.toggled = true
mod.defaultOff = true
local Evaluator = LibStub("StarLibEvaluator-1.0")
local LibCore = LibStub("StarLibCore-1.0")
local LibLCDText = LibStub("StarLibLCDText-1.0")
local LibDriverQTip = LibStub("StarLibDriverQTip-1.0")

local _G = _G
local GameTooltip = _G.GameTooltip
local cores = {}
local coresDict = {}
local config = {}
local defaults = {profile= {cores={}}}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	
	self.lcd = LibDriverQTip:New(self, "display_startip", StarTip.config, StarTip.db.profile.errorLevel)
	self.lcd.core:CFGSetup()
	self.lcd.core:BuildLayouts()
	
end

function mod:OnEnable()
	self.lcd.core:Start()
	self.lcd:Show()
end

function mod:OnDisable()
	self.lcd.core:Stop()
	self.lcd:Hide()
end

function mod:AddLCD(core)
	tinsert(coresList, core)
	coresDict[core.name] = {core=core, i = #coresList}
	self:RebuildOpts()
end