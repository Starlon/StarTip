local mod = StarTip:NewModule("LCDDisplay")
mod.name = "LCDDisplay"
mod.toggled = true
mod.defaultOff = true
local Evaluator = LibStub("StarLibEvaluator-1.0")
local LibCore = LibStub("StarLibCore-1.0")
local LibLCDText = LibStub("StarLibLCDText-1.0")
local LibDriverQTip = LibStub("StarLibDriverQTip-1.0")

mod.name = "LCDDisplay"
mod.toggled = true
local _G = _G
local GameTooltip = _G.GameTooltip
local cores = {}
local coresDict = {}
local config = {}
local defaults = {profile= {cores={}}}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	
	self.config = Evaluator.ExecuteCode({}, mod:GetName(), StarTip.config)
		
	self.lcd = LibDriverQTip:New(self, "display_startip", self.config, StarTip.db.profile.errorLevel)
	self.lcd.core:CFGSetup()
	self.lcd.core:BuildLayouts()
	
end

function mod:OnEnable()
	self.lcd.core:StartLayout()
	self.lcd:Show()
end

function mod:OnDisable()
	self.lcd.core:StopLayout()
	self.lcd:Hide()
end

function mod:AddLCD(core)
	tinsert(coresList, core)
	coresDict[core.name] = {core=core, i = #coresList}
	self:RebuildOpts()
end