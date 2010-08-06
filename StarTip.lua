StarTip = LibStub("AceAddon-3.0"):NewAddon("StarTip", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0") 
local LibQTip = LibStub('LibQTip-1.0')
local LibDBIcon = LibStub("LibDBIcon-1.0")
local LSM = _G.LibStub("LibSharedMedia-3.0")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _G = _G
local GameTooltip = _G.GameTooltip
local ipairs, pairs = _G.ipairs, _G.pairs

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("StarTip", {
	type = "data source",
	text = "StarTip",
	icon = "Interface\\Icons\\INV_Chest_Cloth_17",
	OnClick = function() StarTip:OpenConfig() end
})

local defaults = {
	profile = {
		modules = {},
		minimap = {hide=true}
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
		},
		settings = {
			name = "Settings",
			desc = "Settings",
			type = "group",
			args = {
				minimap = {
					name = "Minimap",
					desc = "Toggle showing minimap button",
					type = "toggle",
					get = function() 
						return not StarTip.db.profile.minimap.hide
					end,
					set = function(info, v)
						StarTip.db.profile.minimap.hide = not v
						if not v then 
							LibDBIcon:Hide("StarTipLDB") 
						else
							LibDBIcon:Show("StarTipLDB")
						end
					end,
					order = 1
				}
			}
		}
	}
}

do
	local pool = setmetatable({},{__mode='k'})
	
	function StarTip:new(...)
		local t = next(pool)
		if t then
			pool[t] = nil
			for i=1, select("#", ...) do
				t[i] = select(i, ...)
			end
		else
			t = {...}
		end
		t.__starref__ = true
		return t
	end
	function StarTip:newDict(...)
		local t = next(pool)
		if t then
			pool[t] = nil
		else
			t = {}			
		end
		for i=1, select("#", ...), 2 do
			t[select(i, ...)] = select(i+1, ...)
		end
		t.__starref__ = true
		return t
	end	
	function StarTip:del(...)
		for i=1, select("#", ...) do
			local t = select(i, ...)
			if (t and type(t) ~= table) or t == nil then break end
			for k, v in pairs(t) do
				if type(k) == "table" then
					if t.__starref__ then StarTip:del(k) end
					t.__starref__ = nil
				end
				t[k] = nil
			end
			pool[t] = true			
		end
	end
end
StarTip:SetDefaultModuleState(false)

function StarTip:OnInitialize()
	
	self.db = LibStub("AceDB-3.0"):New("StarTipDB", defaults, "Default")

	LibStub("AceConfig-3.0"):RegisterOptionsTable("StarTip", options)
	self:RegisterChatCommand("startip", "OpenConfig")
	AceConfigDialog:AddToBlizOptions("StarTip")
	LibDBIcon:Register("StarTipLDB", LDB, self.db.profile.minimap)
	
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
	if self.db.profile.minimap.hide then
		LibDBIcon:Hide("StarTipLDB")
	else
		LibDBIcon:Show("StarTipLDB")
	end

	GameTooltip:HookScript("OnTooltipSetUnit", self.OnTooltipSetUnit)
	GameTooltip:HookScript("OnTooltipSetItem", self.OnTooltipSetItem)
	GameTooltip:HookScript("OnTooltipSetSpell", self.OnTooltipSetSpell)
	self:RawHookScript(GameTooltip, "OnHide", "OnTooltipHide")
	self:RawHookScript(GameTooltip, "OnShow", "OnTooltipShow")
	
	for k,v in self:IterateModules() do
		if self.db.profile.modules[k]  == nil or self.db.profile.modules[k] then
			v:Enable()
		end
	end
		
	self:RebuildOpts()
end

function StarTip:OnDisable()
	LibDBIcon:Hide("StarTipLDB")
	self:Unhook(GameTooltip, "OnTooltipSetUnit")
	self:Unhook(GameTooltip, "OnTooltipSetItem")
	self:Unhook(GameTooltip, "OnTooltipSetSpell")
	self:Unhook(GameTooltip, "OnHide")
	self:Unhook(GameTooltip, "OnShow")
end

function StarTip:RebuildOpts()
	for k, v in self:IterateModules() do
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
			get = function() return self.db.profile.modules[k] == nil or self.db.profile.modules[k] end,
			order = 2
		}
		options.args.modules.args[v:GetName()].args = t
	end	
end

function StarTip:OpenConfig()
	AceConfigDialog:SetDefaultSize("StarTip", 800, 450)
	AceConfigDialog:Open("StarTip")	
end
	
local ff = CreateFrame("Frame")
function StarTip.OnTooltipSetUnit()
	if not StarTip.justSetUnit then
		if not UnitExists("mouseover") then
			if ff:GetScript("OnUpdate") then
				ff:SetScript("OnUpdate", nil)
			else
				ff:SetScript("OnUpdate", function() GameTooltip:SetUnit("mouseover") end)
			end
			return
		else
			if ff:GetScript("OnUpdate") then ff:SetScript("OnUpdate", nil) end
		end
		for k, v in StarTip:IterateModules() do
			if v.SetUnit and v:IsEnabled() then v:SetUnit() end
		end
	end
end

function StarTip.OnTooltipSetItem(self, ...)
	if not StarTip.justSetItem then
		for k, v in StarTip:IterateModules() do
			if v.SetItem and v:IsEnabled() then v:SetItem(...) end
		end
	end
end

function StarTip.OnTooltipSetSpell(...)
	if not StarTip.justSetSpell then
		for k, v in StarTip:IterateModules() do
			if v.SetSpell and v:IsEnabled() then v:SetSpell(...) end
		end
	end
end

function StarTip:OnTooltipHide(...)
	if not self.justHide then
		for k, v in self:IterateModules() do
			if v.OnHide and v:IsEnabled() then v:OnHide(...) end
		end
	end
	self.hooks[GameTooltip].OnHide(...)

	LibQTip:Release(self.tooltip)
	self.tooltip = nil
  	
end

function StarTip:OnTooltipShow(...)
	if not self.justShow then
		for k, v in self:IterateModules() do
			if v.OnShow and v:IsEnabled() then v:OnShow(...) end
		end
	end
   -- Acquire a tooltip with 3 columns, respectively aligned to left, center and right
   local tooltip = LibQTip:Acquire("GameTooltip", 3, "LEFT", "CENTER", "RIGHT")
   StarTip.tooltip = tooltip 
   
   -- Add an header filling only the first two columns
   tooltip:AddHeader('Anchor', 'Tooltip')
   
   -- Add an new line, using all columns
   tooltip:AddLine('Hello', 'World', '!')
   
   -- Use smart anchoring code to anchor the tooltip to our frame
   tooltip:SmartAnchorTo(_G.GameTooltip)
   
   -- Show it, et voil?
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