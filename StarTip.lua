﻿StarTip = LibStub("AceAddon-3.0"):NewAddon("StarTip", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0") 
--local LibQTip = LibStub('LibQTip-1.0')
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
		minimap = {hide=true},
		modifier = 1,
		unitShow = 1,
		objectShow = 1,
		unitFrameShow = 1,
		otherFrameShow = 1
	}
}
			
local modNames = {"None", "Ctrl", "Alt", "Shift"}
local modFuncs = {function() return true end, IsControlKeyDown, IsAltKeyDown, IsShiftKeyDown}

local showChoices = {"Always", "Out of Combat", "Never"}

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
				},
				modifier = {
					name = "Modifier",
					desc = "Whether to use a modifier key or not",
					type = "select",
					values = {"None", "Ctrl", "Alt", "Shift"},
					get = function() return StarTip.db.profile.modifier end,
					set = function(info, v) StarTip.db.profile.modifier = v end,
					order = 6
				},
				unitShow = {
					name = "Unit",
					desc = "Whether to show unit tooltips",
					type = "select",
					values = showChoices,
					get = function() return StarTip.db.profile.unitShow end,
					set = function(info, v) StarTip.db.profile.unitShow = v end,
					order = 7
				},
				objectShow = {
					name = "Object",
					desc = "Whether to show object tooltips",
					type = "select",
					values = showChoices,
					get = function() return StarTip.db.profile.objectShow end,
					set = function(info, v) StarTip.db.profile.objectShow = v end,
					order = 8				
				},
				unitFrameShow = {
					name = "Unit Frame",
					desc = "Whether to show unit frame tooltips",
					type = "select",
					values = showChoices,
					get = function() return StarTip.db.profile.unitFrameShow end,
					set = function(info, v) StarTip.db.profile.unitFrameShow = v end,
					order = 9				
				},
				otherFrameShow = {
					name = "Other Frame",
					desc = "Whether to show other frame tooltips",
					type = "select",
					values = showChoices,
					get = function() return StarTip.db.profile.otherFrameShow end,
					set = function(info, v) StarTip.db.profile.otherFrameShow = v end,
					order = 10				
				},
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

local function errorhandler(err)
    return geterrorhandler()(err)
end

do 
	local pool = setmetatable({},{__mode='v'})
	StarTip.executeCode = function(tag, code, data)
		if not code then return end

		local runnable = pool[code]
		local err
				
		if not runnable then
			runnable, err = loadstring(code, tag)
			if runnable then
				pool[code] = runnable
			end
		end
	
		if not runnable then 
			StarTip:Print(err)
			return "" 
		end
		
		local table = {self = StarTip:GetModule("Text"), _G = _G, StarTip = StarTip, select = select, format = format}
		_G.self = table.self
		
		setfenv(runnable, table)
		
		return runnable(xpcall, errorhandler)
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
	self:SecureHook(GameTooltip, "Show", self.GameTooltipShow)
	
	for k,v in self:IterateModules() do
		if (self.db.profile.modules[k]  == nil and not v.defaultOff) or self.db.profile.modules[k] then
			v:Enable()
		end
	end
		
	self:RebuildOpts()
	
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
end

function StarTip:OnDisable()
	LibDBIcon:Hide("StarTipLDB")
	self:Unhook(GameTooltip, "OnTooltipSetUnit")
	self:Unhook(GameTooltip, "OnTooltipSetItem")
	self:Unhook(GameTooltip, "OnTooltipSetSpell")
	self:Unhook(GameTooltip, "OnHide")
	self:Unhook(GameTooltip, "OnShow")
	self:UnRegisterEvent("MODIFIER_STATE_CHANGED")
end

function StarTip:RebuildOpts()
	for k, v in self:IterateModules() do
		local t = {}
		options.args.modules.args[v:GetName()] = {
			name = v.name,
			type = "group",
			args = nil
		}

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

		if v.toggled then
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
				get = function() return (self.db.profile.modules[k]  == nil and not v.defaultOff) or self.db.profile.modules[k] end,
				order = 2
			}
		end
		options.args.modules.args[v:GetName()].args = t
	end	
end

function StarTip:OpenConfig()
	AceConfigDialog:SetDefaultSize("StarTip", 800, 450)
	AceConfigDialog:Open("StarTip")	
end
	
function StarTip.OnTooltipSetUnit()	
	if not StarTip.justSetUnit then
		for k, v in StarTip:IterateModules() do
			if v.SetUnit and v:IsEnabled() then v:SetUnit() end
		end
	end
	StarTip.justSetUnit = nil
end

function StarTip.OnTooltipSetItem(self, ...)	
	if not StarTip.justSetItem then
		for k, v in StarTip:IterateModules() do
			if v.SetItem and v:IsEnabled() then v:SetItem(...) end
		end
	end
	StarTip.justSetItem = nil
end

function StarTip.OnTooltipSetSpell(...)	
	if not StarTip.justSetSpell then
		for k, v in StarTip:IterateModules() do
			if v.SetSpell and v:IsEnabled() then v:SetSpell(...) end
		end
	end
	StarTip.justSetSpell = nil
end

function StarTip:OnTooltipHide(...)
	if not self.justHide then
		for k, v in self:IterateModules() do
			if v.OnHide and v:IsEnabled() then v:OnHide(...) end
		end
	end
	self.justHide = nil
	self.hooks[GameTooltip].OnHide(...)  	
end


function StarTip:GameTooltipShow(...)
	local show = true
	if StarTip.db.profile.modifier > 1 and type(modFuncs[StarTip.db.profile.modifier]) == "function" then
		if not modFuncs[StarTip.db.profile.modifier]() then	
			show = false
		end
	end
	if show ~= false then
			if GameTooltip:IsOwned(UIParent) then
				if GameTooltip:GetUnit() then
					-- world unit
					show = StarTip.db.profile.unitShow
				else
					-- world object
					show = StarTip.db.profile.objectShow
				end
			else
				if GameTooltip:GetUnit() then
					-- unit frame
					show = StarTip.db.profile.unitFrameShow
				else
					-- non-unit frame
					show = StarTip.db.profile.otherFrameShow
				end
			end

			if show == 1 then -- always shown
				show = true
			elseif show == 2 then -- only show out of combat
				if InCombatLockdown() then
					show = false
				else
					show = true
				end
			elseif show == 3 then -- never show
				show = false
			end
	end
	
	if not show then GameTooltip:Hide() end
end

function StarTip:OnTooltipShow(this, ...)
	if not self.justShow then
		for k, v in self:IterateModules() do
			if v.OnShow and v:IsEnabled() then v:OnShow(this, ...) end
		end
	end
	
	self.justShow = false
	
	self.hooks[GameTooltip].OnShow(this, ...)
	
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

-- Taken from CowTip
function StarTip:GetMouseoverUnit()
	local _, tooltipUnit = GameTooltip:GetUnit()
	if not tooltipUnit or not UnitExists(tooltipUnit) or UnitIsUnit(tooltipUnit, "mouseover") then
		return "mouseover"
	else
		return tooltipUnit
	end
end

-- Taken from CowTip and modified a bit
function StarTip:MODIFIER_STATE_CHANGED(ev, modifier, up)
	local mod
	if self.db.profile.modifier == 2 then
		mod = (modifier == "LCTRL" or modifier == "RCTRL") and "LCTRL"
		modifier = "LCTRL"
	elseif self.db.profile.modifier == 3 then
		mod = (modifier == "LALT" or modifier == "RALT") and "LALT"
		modifier = "LALT"
	elseif self.db.profilemodifier == 4 then
		mod = (modifier == "LSHIFT" or modifier == "RSHIFT") and "LSHIFT"
		modifier = "LSHIFT"
	end
		
	if mod ~= modifier then
		return
	end
	
	if up == 0 then
		GameTooltip:Hide()
		return
	end
	
	local mouseover_unit = StarTip:GetMouseoverUnit()

	local frame = GetMouseFocus()
	if frame == WorldFrame or frame == UIParent then
		if not UnitExists(mouseover_unit) then
			GameTooltip:Hide()
			return
		end
		GameTooltip:Hide()
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetUnit(mouseover_unit)
		GameTooltip:Show()
	else
		local OnLeave, OnEnter = frame:GetScript("OnLeave"), frame:GetScript("OnEnter")
		if OnLeave then
			_G.this = frame
			OnLeave(frame)
			_G.this = nil
		end
		if OnEnter then
			_G.this = frame
			OnEnter(frame)
			_G.this = nil
		end
	end
end
