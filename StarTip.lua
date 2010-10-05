StarTip = LibStub("AceAddon-3.0"):NewAddon("StarTip: @project-version@", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0") 
StarTip.version = GetAddOnMetadata("StarTip", "X-StarTip-Version") or ""
StarTip.name = GetAddOnMetadata("StarTip", "Notes")
StarTip.name = "StarTip " .. StarTip.version
MAJOR = StarTip.version

local LibDBIcon = LibStub("LibDBIcon-1.0")
local LSM = _G.LibStub("LibSharedMedia-3.0")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("StarTip")

local LibCore = LibStub("LibScriptableDisplayCore-1.0")
local LibTimer = LibStub("LibScriptableDisplayTimer-1.0")
local PluginTalents = LibStub("LibScriptableDisplayPluginTalents-1.0")
local WidgetTimer = LibStub("LibScriptableDisplayWidgetTimer-1.0")

local _G = _G
local GameTooltip = _G.GameTooltip
local ipairs, pairs = _G.ipairs, _G.pairs
local timers = {}
local widgets = {}

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("StarTip", {
	type = "data source",
	text = "StarTip",
	icon = "Interface\\Icons\\INV_Chest_Cloth_17",
	OnClick = function() StarTip:OpenConfig() end
})

StarTip.anchors = {
	"CURSOR_TOP",
	"CURSOR_TOPRIGHT",
	"CURSOR_TOPLEFT",
	"CURSOR_BOTTOM",
	"CURSOR_BOTTOMRIGHT",
	"CURSOR_BOTTOMLEFT",
	"CURSOR_LEFT",
	"CURSOR_RIGHT",
	"TOP",
	"TOPRIGHT",
	"TOPLEFT",
	"BOTTOM",
	"BOTTOMRIGHT",
	"BOTTOMLEFT",
	"RIGHT",
	"LEFT",
	"CENTER"
}

StarTip.anchorText = {
	"Cursor Top",
	"Cursor Top-right",
	"Cursor Top-left",
	"Cursor Bottom",
	"Cursor Bottom-right",
	"Cursor Bottom-left",
	"Cursor Left",
	"Cursor Right",
	"Screen Top",
	"Screen Top-right",
	"Screen Top-left",
	"Screen Bottom",
	"Screen Bottom-right",
	"Screen Bottom-left",
	"Screen Right",
	"Screen Left",
	"Screen Center"
}

StarTip.opposites = {
	TOP = "BOTTOM",
	TOPRIGHT = "BOTTOMLEFT",
	TOPLEFT = "BOTTOMRIGHT",
	BOTTOM = "TOP",
	BOTTOMRIGHT = "TOPLEFT",
	BOTTOMLEFT = "TOPRIGHT",
	LEFT = "RIGHT",
	RIGHT = "LEFT",
}

local SINGLETON_CLASSIFICATIONS = {
	"player",
	"pet",
	"pettarget",
	"target",
	"targettarget",
	"targettargettarget",
	"focus",
	"focustarget",
	"focustargettarget"
}
StarTip.SINGLETON_CLASSIFICATIONS = SINGLETON_CLASSIFICATIONS

local UNIT_PARTY_GROUPS = {
	"party",
	"partytarget",
	"partytargettarget",
	"partypet",
	"partypettarget",
	"partypettargettarget"
}
StarTip.UNIT_PARTY_GROUPS = UNIT_PARTY_GROUPS

local UNIT_RAID_GROUPS = {
	"raid",
	"raidtarget",
	"raidtargettarget",
	"raidpet",
	"raidpettarget",
	"raidpettargettarget",
}
StarTip.UNIT_RAID_GROUPS = UNIT_RAID_GROUPS

local defaults = {
	profile = {
		modules = {},
		timers = {},
		minimap = {hide=true},
		modifier = 1,
		unitShow = 1,
		objectShow = 1,
		unitFrameShow = 1,
		otherFrameShow = 1,
		errorLevel = 1,
		throttleVal = 0,
		intersectRate = 200
	}
}
			
local modNames = {L["None"], L["Ctrl"], L["Alt"], L["Shift"]}
local modFuncs = {function() return true end, IsControlKeyDown, IsAltKeyDown, IsShiftKeyDown}

local showChoices = {"Always", "Out of Combat", "Never"}

local options = {
	type = "group",
	args = {
		modules = {
			name = L["Modules"],
			desc = L["Modules"],
			type = "group",
			args = {}
		},
		timers = {
			name = "Timers",
			desc = "Timers",
			type = "group",
			args = {
				add = {
					name = L["Add Timer"],
					desc = L["Add a timer widget"],
					type = "input",
					set = function(info, v)
						tinsert(timers, v)
						StarTip:RebuildOptsions()
						StarTip:OnDisable()
						StarTip:OnEnable()
						StarTip:SetupTimers()						
					end, 
					order = 1
				},
				reset = {
					name = L["Restore Defaults"],
					desc = L["Use this to restore the defaults"],
					type = "execute",
					func = function()
						StarTip.db.profile.timers = nil						
						StarTip:SetupTimers()											
						StarTip:RebuildOpts()
						StarTip:OnDisable()
						StarTip:OnEnable()						
					end,
					order = 2
				}
			}
		},
		settings = {
			name = L["Settings"],
			desc = L["Settings"],
			type = "group",
			args = {
				minimap = {
					name = L["Minimap"],
					desc = L["Toggle showing minimap button"],
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
					name = L["Modifier"],
					desc = L["Whether to use a modifier key or not"],
					type = "select",
					values = {L["None"], L["Ctrl"], L["Alt"], L["Shift"]},
					get = function() return StarTip.db.profile.modifier end,
					set = function(info, v) StarTip.db.profile.modifier = v end,
					order = 6
				},
				unitShow = {
					name = L["Unit"],
					desc = L["Whether to show unit tooltips"],
					type = "select",
					values = showChoices,
					get = function() return StarTip.db.profile.unitShow end,
					set = function(info, v) StarTip.db.profile.unitShow = v end,
					order = 7
				},
				objectShow = {
					name = L["Object"],
					desc = L["Whether to show object tooltips"],
					type = "select",
					values = showChoices,
					get = function() return StarTip.db.profile.objectShow end,
					set = function(info, v) StarTip.db.profile.objectShow = v end,
					order = 8				
				},
				unitFrameShow = {
					name = L["Unit Frame"],
					desc = L["Whether to show unit frame tooltips"],
					type = "select",
					values = showChoices,
					get = function() return StarTip.db.profile.unitFrameShow end,
					set = function(info, v) StarTip.db.profile.unitFrameShow = v end,
					order = 9				
				},
				otherFrameShow = {
					name = L["Other Frame"],
					desc = L["Whether to show other frame tooltips"],
					type = "select",
					values = showChoices,
					get = function() return StarTip.db.profile.otherFrameShow end,
					set = function(info, v) StarTip.db.profile.otherFrameShow = v end,
					order = 10				
				},
				errorLevel = {
					name = L["Error Level"],
					desc = L["StarTip's error level"],
					type = "select",
					values = LibStub("LibScriptableDisplayError-1.0").defaultTexts,
					get = function() return StarTip.db.profile.errorLevel end,
					set = function(info, v) StarTip.db.profile.errorLevel = v; StarTip:Print("Note that changing error verbosity requires a UI reload.") end,
					order = 11
				},
				throttleVal = {
					name = L["Throttle Threshold"],
					desc = L["StarTip can throttle your mouseovers, so it doesn't show a tooltip if you mouse over units really fast. There's a few bugs here, which is why it's not enabled by default."],
					type = "input",
					pattern = "%d",
					get = function() return tostring(StarTip.db.profile.throttleVal) end,
					set = function(info, v) StarTip.db.profile.throttleVal = tonumber(v) end,
					order = 12
				},
				intersectRate = {
					name = L["Intersect Checks Rate"],
					desc = L["The rate at which intersecting frames will be checked"],
					type = "input",
					pattern = "%d",
					get = function() return tostring(StarTip.db.profile.intersectRate) end,
					set = function(info, v) StarTip.db.profile.intersectRate = tonumber(v) end,
					order = 13
				}
			}
		}
	}
}

do
	local pool = setmetatable({},{__mode='k'})
	local newCount, delCount = 0, 0
	function StarTip.new(...)
		local t = next(pool)
		local newtbl
		if t then
			pool[t] = nil
			table.wipe(t)
			for i=1, select("#", ...) do
				t[i] = select(i, ...)
			end	
		else
			newtbl = true
			t = {...}
		end
		if newtbl then
			--StarTip:Print("new table " .. GetTime(), "new " .. newCount, "del " .. delCount)		
		end
		t.__starref__ = true
		newCount = newCount + 1
		return t, newtbl
	end
	function StarTip.del(...)
		local t = select(1, ...)
		
		if type(t) ~= "table" or not t.__starref__ then return end
		
		for i=2, select("#", ...) do
			local t = select(i, ...)
			if type(t) ~= table or t == nil then break end
			StarTip.del(t)
		end
		t.__starref__ = nil
		pool[t] = true	
		delCount = delCount + 1
	end
	function StarTip.copy(src, dst)
		if type(src) ~= "table" then return nil end
		if type(dst) ~= "table" then dst = StarTip.new() end
		for k, v in pairs(src) do
			if type(v) == "table" then
				v = StarTip.copy(v)
			end
			dst[k] = v
		end
		return dst
	end
end

local environment = {}
StarTip.environment = environment
environment.new = StarTip.new
environment.newDict = StarTip.newDict
environment.del = StarTip.del
environment._G = _G

--[[
PluginRangeCheck:New(environment)
PluginUnit:New(environment)
PluginWidgetText:New(environment)
PluginBit:New(environment)
PluginLua:New(environment)
PluginMath:New(environment)
PluginString:New(environment)
PluginTable:New(environment)
PluginResourceTools:New(environment)
PluginLocation:New(environment)
PluginUnitTooltipStats:New(environment)
if PluginDBM then PluginDBM:New(environment) end
--PluginLinq:New(environment)
--]]

local function errorhandler(err)
    return geterrorhandler()(err)
end

local function copy(tbl)
	local localCopy = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			localCopy[k] = copy(v)
		elseif type(v) ~= "function" then
			localCopy[k] = v
		end
	end
	return localCopy
end

StarTip:SetDefaultModuleState(false)

local defaultTimers = {
	["widget_resources_timer"] = {
        type = "timer",
		update = 0,
		repeating = true,
		expression = [[
if ResourceServer then self.timer:Stop() return end
Update()
]]
	},	
}

function StarTip:RefreshConfig()
	for k, v in self:IterateModules() do
		if v.ReInit then
			v:ReInit()
		end
	end
	self:RebuildOpts()
	self:Print(L["You may need to reload your UI."])
end

local checkTooltipAlphaFrame
local checkTooltipAlpha = function()
	if GameTooltip:GetAlpha() < 1 then
		StarTip.fading = true
		checkTooltipAlphaFrame:SetScript("OnUpdate", nil)
	end
end

checkTooltipAlphaFrame = CreateFrame("Frame")

local menuoptions = {
	name = "StarTip",
	type = "group",
	args = {
		open = {
			name = "Open Configuration",
			type = "execute",
			func = function() StarTip:OpenConfig() end
		}
	}
}
function StarTip:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("StarTipDB", defaults, "Default")
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("StarTip-Addon", options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("StarTip", menuoptions)
	AceConfigDialog:SetDefaultSize("StarTip-Addon", 800, 450)
	self:RegisterChatCommand("startip", "OpenConfig")
	AceConfigDialog:AddToBlizOptions("StarTip")
	LibDBIcon:Register("StarTipLDB", LDB, self.db.profile.minimap)

	if not options.args.Profiles then
 		options.args.Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
		self.lastConfig = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("StarTip-Addon", "Profiles", "StarTip-Addon", "Profiles")
	end
	
	local leftGameTooltipStrings, rightGameTooltipStrings = {}, {}
	--[[self.leftLines = {}
	self.rightLines = {}
	setmetatable(self.leftLines, {__index=function(self, key)
		if type(key) ~= "number" then return self[key] end
		assert(type(key) == "number")
		for i = #self, key + 1 do
			if i > GameTooltip:NumLines() then
				GameTooltip:AddDoubleLine(' ', ' ')
				rawset(self.leftLines, key, _G["GameTooltipTextLeft" .. i])
				--rawset(self.rightLines, key, _G["GameTooltipTextRight" .. i])
				StarTip:Print("add line")
			end
		end
		return self[key]
	end})
	setmetatable(self.rightLines, getmetatable(self.leftLines))
	]]
	self.leftLines = {}
	self.rightLines = {}
	for i = 1, 50 do
		GameTooltip:AddDoubleLine(' ', ' ')
		self.leftLines[i] = _G["GameTooltipTextLeft" .. i]
		self.rightLines[i] = _G["GameTooltipTextRight" .. i]
	end
	GameTooltip:ClearLines()
	
	self.core = LibCore:New(StarTip, environment, "StarTip", {["StarTip"] = {}}, "text", self.db.profile.errorLevel)		
	GameTooltip:Show()
	GameTooltip:Hide()
end

function StarTip:SetupTimers()
	if not self.db.profile.timers then
		self.db.profile.timers = {}
		for k, v in pairs(defaultTimers) do
			self.db.profile.timers[k] = v
		end
	end
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
	self:RawHook(GameTooltip, "FadeOut", "GameTooltipFadeOut", true)
	self:RawHook(GameTooltip, "Hide", "GameTooltipHide", true)
	self:RawHook(GameTooltip, "Show", "GameTooltipShow", true)
	self:SecureHook(GameTooltip, "AddDoubleLine", self.GameTooltipAddLine)
	self:SecureHook(GameTooltip, "AddLine", self.GameTooltipAddLine)
	
	for k,v in self:IterateModules() do
		if (self.db.profile.modules[k]  == nil and not v.defaultOff) or self.db.profile.modules[k] then
			v:Enable()
		end
	end

	
	self:RestartTimers()

	--self:RebuildOpts()
	
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	
	local plugin = {}
	LibStub("LibScriptableDisplayPluginColor-1.0"):New(plugin)
	ChatFrame1:AddMessage(plugin.Colorize(L["Welcome to "] .. StarTip.name, 0, 1, 1) .. plugin.Colorize(L[" Type /startip to open config. Alternatively you could press escape and choose the addons menu. Or you can choose to show a minimap icon."], 1, 1, 0))
end

function StarTip:OnDisable()
	LibDBIcon:Hide("StarTipLDB")
	self:Unhook(GameTooltip, "OnTooltipSetUnit")
	self:Unhook(GameTooltip, "OnTooltipSetItem")
	self:Unhook(GameTooltip, "OnTooltipSetSpell")
	self:Unhook(GameTooltip, "OnHide")
	self:Unhook(GameTooltip, "OnShow")
	self:Unhook(GameTooltip, "Show")
	self:Unhook(GameTooltip, "FadeOut")
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	for k,v in self:IterateModules() do
		if (self.db.profile.modules[k]  == nil and not v.defaultOff) or self.db.profile.modules[k] then
			v:Disable()
		end
	end
	for i, v in ipairs(widgets) do
		v:Del()
	end
	table.wipe(widgets)
end

function StarTip:RestartTimers()
	self:SetupTimers()
	for i, v in ipairs(widgets) do
		v:Del()
	end
	table.wipe(widgets)
	for k, v in pairs(self.db.profile.timers) do
		tinsert(widgets, WidgetTimer:New(self, "StarTip.timer." .. k, v, self.db.profile.errorLevel))
		widgets[#widgets]:Start()
	end
end

function StarTip:RebuildOpts()
	for k, v in self:IterateModules() do
		local t = {}
		if type(v.RebuildOpts) == "function" then v:RebuildOpts() end
		options.args.modules.args[v:GetName()] = {
			name = v.name,
			type = "group",
			args = nil
		}

		if v.GetOptions then
			t = v:GetOptions()
			t.optionsHeader = {
				name = L["Settings"],
				type = "header",
				order = 3
			}
			if v.childGroup then
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
				name = L["Enable"],
				desc = L["Enable or disable this module"],
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
	for k, v in pairs(self.db.profile.timers) do
		options.args.timers.args[k:gsub(" ", "_")] = {
			name = k,
			type = "group",
		}
		options.args.timers.args[k:gsub(" ", "_")].args = WidgetTimer:GetOptions(self, v)
	end
end

function StarTip:OpenConfig()
	self:RebuildOpts()
	AceConfigDialog:Open("StarTip-Addon")	
end

function StarTip.GameTooltipAddLine(...)
	do return end
	if StarTip.addingLine then return ... end
	local mod = StarTip:GetModule("UnitTooltip")
	mod.NUM_LINES = mod.NUM_LINES + 1
	return ...
end

local hideTimer
local function hideTooltip()
	if StarTip.unit ~= "mouseover" and GetMouseFocus() == WorldFrame then StarTip.unit = nil; return end
	hideTimer:Start()
end

local throttleTimer
local lastTime = GetTime()
local function endThrottle()
	if UnitExists(StarTip.unit or "mouseover") then
		StarTip.OnTooltipSetUnit()
	end
end

function StarTip.OnTooltipSetUnit(...)

	local _, unit = GameTooltip:GetUnit()

	hideTimer = hideTimer or LibTimer:New("StarTip.Hide", 100, false, hideTooltip, nil, StarTip.db.profile.errorLevel)
	hideTimer:Start()
	
	throttleTimer = throttleTimer or LibTimer:New("StarTip.Throttle", StarTip.db.profile.throttleVal, false, endThrottle, nil, StarTip.db.profile.errorLevel)
	if GetTime() < lastTime + StarTip.db.profile.throttleVal and UnitIsPlayer("mouseover") and StarTip.db.profile.throttleVal > 0 then 
		throttleTimer:Start(); 
		GameTooltip:Hide() 
		return
	end
	lastTime = GetTime()
	
	--StarTip.fading = false
	StarTip.unit = unit
			
	if not StarTip.justSetUnit then
		for k, v in StarTip:IterateModules() do
			if v.SetUnit and v:IsEnabled() then v:SetUnit() end
		end
	end
	StarTip.justSetUnit = nil
	--checkTooltipAlphaFrame:SetScript("OnUpdate", checkTooltipAlpha)
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
	return ...
end

function StarTip:HideAll()
	for k, v in StarTip:IterateModules() do
		if v.OnHide then
			v:OnHide()
		end
	end
end

function StarTip:GameTooltipHide(...)
	local hide = true
	
	for k, v in StarTip:IterateModules() do
		if v.GameTooltipHide and v:IsEnabled() then 
			hide = hide and v:GameTooltipHide(...)
		end
	end
	
	if hide then
		StarTip.hooks[GameTooltip].Hide(...)
	end
end

function StarTip:OnTooltipHide(...)
	if not self.justHide then
		for k, v in self:IterateModules() do
			if v.OnHide and v:IsEnabled() then v:OnHide(...) end
		end
	end
	self.justHide = nil
	self.unit = false
	if hideTimer then hideTimer:Stop() end
	if throttleTimer then throttleTimer:Stop() end
	return self.hooks[GameTooltip].OnHide(...)  	
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
	
	if not show then GameTooltip:Hide(); return end

	--[[
	for k, v in StarTip:IterateModules() do
		if v.GameTooltipShow and v:IsEnabled() then 
			show = show and v:GameTooltipShow(...)
		end
	end]]
	
	if show then
		StarTip.hooks[GameTooltip].Show(...)
	end
end

function StarTip.OnTooltipShow(...)
	if not StarTip.justShow then
		for k, v in StarTip:IterateModules() do
			if v.OnShow and v:IsEnabled() then v:OnShow(...) end
		end
	end
	
	StarTip.justShow = false
	
	return StarTip.hooks[GameTooltip].OnShow(...)
end

function StarTip:GameTooltipFadeOut(...) 
	local fadeOut = true
	for k, v in StarTip:IterateModules() do
		if v.GameTooltipFadeOut and v:IsEnabled() then 
			fadeOut = fadeOut and v:GameTooltipFadeOut(...)
		end
	end
	if fadeOut then
		StarTip.hooks[GameTooltip].FadeOut(...)
	end
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
function StarTip:MODIFIER_STATE_CHANGED(ev, modifier, up, ...)
	for i, v in self:IterateModules() do
		if v.MODIFIER_STATE_CHANGED then
			v:MODIFIER_STATE_CHANGED(ev, modifier, up, ...)
		end
	end
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
