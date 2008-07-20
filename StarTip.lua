StarTip = LibStub("AceAddon-3.0"):NewAddon("StarTip", "AceConsole-3.0", "AceHook-3.0") 
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _G = _G
local GameTooltip = _G.GameTooltip
local ipairs, pairs = _G.ipairs, _G.pairs
local LSM = _G.LibStub("LibSharedMedia-3.0")

local defaults = {
	profile = {
		modules = {}
	}
}

local options = {
	type = "group",
	args = {
		modules = {
			name = "Modules",
			desc = "Modules",
			type = "group",
			args = {}
		}
	}
}

StarTip:SetDefaultModuleState(false)

function StarTip:OnInitialize()

	for k, v in self:IterateModules() do
		defaults.profile.modules[k] = true
		options.args.modules.args[v:GetName()] = {
			name = v.name,
			type = "group",
			args = nil
		}
		local t
		if v.GetOptions then
			t = v:GetOptions()
			t.optionsHeader = {
				name = "Settings",
				type = "header",
				order = 3
			}
			if v:GetName() == "Bars" then
				options.args.modules.args[v:GetName()].childGroups = "tab"
			end
		else
			t = {}
		end
		t.header = {
			name = v.name,
			type = "header",
			order = 1
		}
		t.toggle = {
			name = "Enable",
			desc = "Enable or disable this module",
			type = "toggle",
			set = function(info,v)
				self.db.profile.modules[k] = v
				if v then
					self:EnableModule(k)
				else
					self:DisableModule(k)
				end
			end,
			get = function() return self.db.profile.modules[k] end,
			order = 2
		}
		options.args.modules.args[v:GetName()].args = t
	end

	self.db = LibStub("AceDB-3.0"):New("StarTipDB", defaults, "Default")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("StarTip", options)
	self:RegisterChatCommand("startip", "OpenConfig")

	self.leftLines = {}
	self.rightLines = {}
	for i = 1, 50 do
		GameTooltip:AddDoubleLine(' ', ' ')
		self.leftLines[i] = _G["GameTooltipTextLeft" .. i]
		self.rightLines[i] = _G["GameTooltipTextRight" .. i]
	end
	GameTooltip:Show()
	GameTooltip:Hide()
end

function StarTip:OnEnable()
	self:RawHookScript(GameTooltip, "OnTooltipSetUnit")
	self:RawHookScript(GameTooltip, "OnTooltipSetItem")
	self:RawHookScript(GameTooltip, "OnTooltipSetSpell")
	self:RawHookScript(GameTooltip, "OnHide", "OnTooltipHide")
	self:RawHookScript(GameTooltip, "OnShow", "OnTooltipShow")
	
	for k,v in self:IterateModules() do
		if self.db.profile.modules[k] then
			v:Enable()
		end
	end
end

function StarTip:OnDisable()
	self:Unhook(GameTooltip, "OnTooltipSetUnit")
	self:Unhook(GameTooltip, "OnTooltipSetItem")
	self:Unhook(GameTooltip, "OnTooltipSetSpell")
	self:Unhook(GameTooltip, "OnHide")
	self:Unhook(GameTooltip, "OnShow")
end

function StarTip:OpenConfig()
	AceConfigDialog:SetDefaultSize("StarTip", 500, 450)
	AceConfigDialog:Open("StarTip")	
end

function StarTip:OnTooltipSetUnit(...)
	self.hooks[GameTooltip].OnTooltipSetUnit(...)
	if not self.justSetUnit then
		for k, v in self:IterateModules() do
			if v.SetUnit and v:IsEnabled() then v:SetUnit() end
		end
	end
end

function StarTip:OnTooltipSetItem(...)
	if not self.justSetItem then
		for k, v in self:IterateModules() do
			if v.SetItem and v:IsEnabled() then v:SetItem() end
		end
	end
	self.hooks[GameTooltip].OnTooltipSetItem(...)
end

function StarTip:OnTooltipSetSpell(...)
	if not self.justSetSpell then
		for k, v in self:IterateModules() do
			if v.SetSpell and v:IsEnabled() then v:SetSpell() end
		end
	end
	self.hooks[GameTooltip].OnTooltipSetSpell(...)
end

function StarTip:OnTooltipHide(...)
	if not self.justHide then
		for k, v in self:IterateModules() do
			if v.OnHide and v:IsEnabled() then v:OnHide() end
		end
	end
	self.hooks[GameTooltip].OnHide(...)
end

function StarTip:OnTooltipShow(...)
	if not self.justShow then
		for k, v in self:IterateModules() do
			if v.OnShow and v:IsEnabled() then v:OnShow() end
		end
	end
	self.hooks[GameTooltip].OnShow(...)
end

function StarTip:GetLSMIndexByName(category, name)
	for i, v in ipairs(LSM:List(category)) do
		if v == name then
			return i
		end
	end
end

function StarTip:SetOptionsDisabled(t, bool)
	for k, v in pairs(t) do
		if not v.args then
			if k ~= "toggle" then v.disabled = bool end
		else
			self:SetOptionsDisabled(v.args, bool)
		end
	end
end
