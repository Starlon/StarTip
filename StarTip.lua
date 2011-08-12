
local addonName, addon = ...

_G["StarTip"] = LibStub("AceAddon-3.0"):NewAddon("StarTip", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0") 
StarTip.version = GetAddOnMetadata("StarTip", "Version") or addonName
StarTip.notes = GetAddOnMetadata("StarTip", "Notes")

local LibDBIcon = LibStub("LibDBIcon-1.0")
local LSM = _G.LibStub("LibSharedMedia-3.0")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("StarTip")
StarTip.L = L
local LQT = LibStub:GetLibrary("LibQTip-1.0-fix")
StarTip.LQT = LQT
local LibFlash = LibStub("LibFlash")


local LibCore = LibStub("LibScriptableLCDCoreLite-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0")
local PluginTalents = LibStub("LibScriptablePluginTalents-1.0")
local WidgetTimer = LibStub("LibScriptableWidgetTimer-1.0")
local WidgetKey = LibStub("LibScriptableWidgetKey-1.0")
local LibWidget = LibStub("LibScriptableWidget-1.0")

local _G = _G
local GameTooltip = _G.GameTooltip
local ipairs, pairs = _G.ipairs, _G.pairs
local timers = {}
local keys = {}
local timerWidgets = {}
local keyWidgets = {}

local environment = {}
StarTip.environment = environment
environment.StarTip = StarTip
environment._G = _G
environment.L = L

local BugGrabber = BugGrabber

local function disableUT(name, side)
	local UT = StarTip:GetModule("UnitTooltip")
	for k, v in pairs(UT.db.profile.lines) do
		if(v.name == name) then
			UT.db.profile.lines[k].enabled = false
			UT:CreateLines()
			error(format(L["StarTip disabled a tooltip line named %s due to an error in the line's %s segment."], v.name, side))
		end
	end
end

local onError
do
	local lastError = nil
	function onError(event, errorObject)
		for k, v in pairs(addon:GetErrors(BugGrabber:GetSessionId())) do
			if type(v.message) == "string" then
				v.message:gsub('t.*StarTip\.UnitTooltip:(.-):left:.*', function(name)
					disableUT(name, "left")
				end)
				v.message:gsub('t.*StarTip\.UnitTooltip:(.-):right:.*', function(name)
					disableUT(name, "right")
				end)
			end
		end
	end
end


-- Borrowed from BugSack
do
        local errors = {}
        function addon:GetErrors(sessionId)
                -- XXX I've never liked this function, maybe a BugGrabber redesign is in order,
                -- XXX where we have one subtable in the DB per session ID.
                if sessionId then
                        wipe(errors)
                        local db = BugGrabber:GetDB()
                        for i, e in next, db do
                                if sessionId == e.session then
                                        errors[#errors + 1] = e
                                end
                        end
                        return errors
                else
                        return BugGrabber:GetDB()
                end
        end
end

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
		keys = {},
		minimap = {hide=true},
		tooltipMain = {frameName="StarTipTooltipMain", intersectFrameName="ChatFrame1", strata=1, level=1, alwaysShown=false, intersect=false, intersectxPad1 = 0, intersectyPad1 = 0, intersectxPad2 = 0, intersectyPad2 = 0, insersectPad = 0, minStrata=5, scriptFrame, hideScript = "self.frame:Hide()", showScript = "self.frame:Show()", hiddenScript = "return not self.frame:IsShown()", shownScript = "return self.frame:IsShown()"},
		modifier = 1,
		unitShow = 1,
		objectShow = 1,
		unitFrameShow = 1,
		otherFrameShow = 1,
		errorLevel = 2,
		throttleVal = 0,
		intersectRate = 300,
		modifierInverse = false,
		message = true,
		backup = true
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
		return t
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
		local localCopy = dst or {}
		wipe(localCopy)
		for k, v in pairs(src) do
			if type(v) == "table" then
				localCopy[k] = copy(v)
			elseif type(v) == "string" or type(v) == "number"then
				localCopy[k] = v
			end
		end
		localCopy.__starref__ = nil
		return localCopy
	end
end

environment.new = StarTip.new
environment.newDict = StarTip.newDict
environment.del = StarTip.del
environment.copy = StarTip.copy
local new = StarTip.new
local newDict = StarTip.newDict
local del = StarTip.del
local copy = StarTip.copy

local function makeNewTooltip()
	local self = StarTip
	--if self.intersectTimer then self.intersectTimer:Del() end
	self.intersectTimer = LibTimer:New("IntersectTimer", self.db.profile.intersectRate, true, LibWidget.IntersectUpdate, nil, self.db.profile.errorLevel)
	--if self.tooltipMain.widget then self.tooltipMain.widget:Del() end
	self.tooltipMain.widget = LibWidget:New(StarTip.tooltipMain, StarTip, "tooltipMain", StarTip.copy(self.db.profile.tooltipMain), 0, 0, 0, {"generic"}, self.db.profile.errorLevel, StarTip.tooltipMain)
	self.intersectTimer.data = self.tooltipMain.widget

end
			
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
			args = {},
			order = 1
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
						tinsert(StarTip.db.profile.timers, {name = v, expression = "return noop", repeating = false, update = 0})
						StarTip:RebuildOpts()
					end, 
					order = 1
				},
				restart = {
					name = L["Restart Timers"],
					desc = L["Would you like to restart your timers? Note that this will restart all timers."],
					type = "execute",
					func = function()
						StarTip:RestartTimers()
					end,
					order = 2
				},
				stop = {
					name = L["Stop Keys"],
					desc = L["Would you like to stop your key widgets?"],
					type = "execute",
					func = function()
						StarTip:StopKeys()
					end,
					order = 3
				},
				reset = {
					name = L["Restore Defaults"],
					desc = L["Use this to restore the defaults"],
					type = "execute",
					func = function()
						StarTip.db.profile.timers = {}
						StarTip:RestartTimers()
						StarTip:RebuildOpts()					
					end,
					order = 3
				}
			},
			order = 2
		},
		keys = {
			name = L["Keys"],
			desc = L["Keys"],
			type = "group",
			args = {
				add = {
					name = L["Add Key"],
					desc = L["Add a key widget."],
					type = "input",
					set = function(info, v)
						table.insert(StarTip.db.profile.keys, {name = v, expression = "return noop"})
						StarTip:RebuildOpts()
					end,
					order = 1
				},
				reset = {
					name = L["Restore Defaults"],
					desc = L["Use this to restore the defaults"],
					type = "execute",
					func = function()
						StarTip.db.profile.keys = {}
						StarTip:RestartKeys()
						StarTip:RebuildOpts()
					end,
					order = 2
				},
			},
			order = 3
		},
		settings = {
			name = L["Settings"],
			desc = L["Settings"],
			type = "group",
			order = 4,
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
					order = 5
				},
				modifierInverse = {
					name = L["Inverted Modifier"],
					desc = L["Whether to invert what happens when a key is pressed or not, i.e. show and hide."],
					type = "toggle",
					get = function() return StarTip.db.profile.modifierInverse end,
					set = function(info, v) StarTip.db.profile.modifierInverse = v end,
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
					values = LibStub("LibScriptableUtilsError-1.0").defaultTexts,
					get = function() return StarTip.db.profile.errorLevel end,
					set = function(info, v) StarTip.db.profile.errorLevel = v; StarTip:Print("Note that changing error verbosity requires a UI reload.") end,
					order = 11
				},
				throttleVal = {
					name = L["Throttle Threshold"],
					desc = L["StarTip can throttle your mouseovers, so it doesn't show a tooltip if you mouse over units really fast. There are a few bugs, which is why it's not enabled by default."],
					type = "input",
					pattern = "%d",
					get = function() return tostring(StarTip.db.profile.throttleVal) end,
					set = function(info, v) StarTip.db.profile.throttleVal = tonumber(v) end,
					order = 12
				},
				message = {
					name = L["Greetings"],
					desc = L["Whether the greetings message should be shown or not"],
					type = "toggle",
					get = function() return StarTip.db.profile.message end,
					set = function(info, v) StarTip.db.profile.message = v end,
					order = 13
				},
				intersectRate = {
					name = L["Intersect Check Rate"],
					desc = L["The rate at which intersecting frames will be checked"],
					type = "input",
					pattern = "%d",
					get = function() return tostring(StarTip.db.profile.intersectRate) end,
					set = function(info, v) StarTip.db.profile.intersectRate = tonumber(v); makeNewTooltip() end,
					order = 14
				},
			}
		}
	}
}

local function errorhandler(err)
    return geterrorhandler()(err)
end


StarTip:SetDefaultModuleState(false)

local defaultTimers = {
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

	if BugGrabber then
		BugGrabber.RegisterCallback(addon, "BugGrabber_BugGrabbed", onError)
		BugGrabber.RegisterCallback(addon, "BugGraabber_EventGrabbed", onError)
	end

	self.db = LibStub("AceDB-3.0"):New("StarTipDB", defaults, "Default")
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

--[[
	options.args.settings.args.backup = {
		name = L["Backup"],
		desc = L["Click to generate a backup."],
		type = "execute",
		func = function()
			local tbl = {}
			tbl["StarTip"] = self:Serialize(copy(self.db.profile))
			for k, v in self:IterateModules() do
				if v.db then tbl[k] = self:Serialize(copy(v.db.profile)) end
			end
			self.db.profile.backupText = self:Serialize(tbl)
			self:RebuildOpts()
		end,
		order = 50
	}
	options.args.settings.args.revert = {
		name = L["Revert"],
		desc = L["Click this to revert to the text in the input field labeled \"Replace Database\"."],
		type = "execute",
		func = function()
			local db = self:Unserialize(self.db.profile.replaceDatabase or "")
			self.db.profile.replaceDatabase = nil
			setmetatable(self.db.profile, {__mode="v"})
			self.db.profile = nil
			collectgarbage()
			self.db.profile = self:Unserialize(db["StarTip"] or "")
			db.StarTip = nil
			for k, v in pairs(db) do
				local mod = self:GetModule(k)
				setmetatable(mod.db.profile, {__mode="v"})
				mod.db.profile = self:Unserialize(v)
			end
			StarTip:Print("It is recommended that you /restart the UI.")
		end,
		order = 51
	}
	options.args.settings.args.backupText = {
		name = L["Current Backup"],
		desc = L["Here's your currently stored backup."],
		type = "input",
		get = function() return self.db.profile.backupText end,
		set = function() self.db.profile.backupText = v end,
		order = 52
	}
	options.args.settings.args.replaceDatabase = {
		name = L["Replace Dtatabase"],
		desc = L["Enter serialized databasae string."],
		type = "input",
		get = function() return "" end,
		set = function(info, val) 
			self.db.profile.replaceDatabase = val
		end,
		order = 53
	}
	]]

	options.args.settings.args.tooltipMain = LibWidget:GetOptions(StarTip.db.profile.tooltipMain, makeNewTooltip)
	options.args.settings.args.tooltipMain.args.add = nil

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
	
	self.leftLines = {}
	self.rightLines = {}
	--self.qtipLines = {}
	for i = 1, 70 do
		GameTooltip:AddDoubleLine(' ', ' ')
		self.leftLines[i] = _G["GameTooltipTextLeft" .. i]
		self.rightLines[i] = _G["GameTooltipTextRight" .. i]
	end
	GameTooltip:ClearLines()
	
	self.core = LibCore:New(environment, "StarTip", self.db.profile.errorLevel)
	GameTooltip:Show()
	GameTooltip:Hide()

	makeNewTooltip()
end

StarTip.cellProvider, StarTip.cellPrototype = LQT:CreateCellProvider()

function StarTip.cellPrototype:InitializeCell()
	self.fontString = self:CreateFontString()
	self.fontString:SetAllPoints(self)
	self.fontString:SetFontObject(GameTooltipText)
	self.r, self.g, self.b = 1, 1, 1
	local y, x = self:GetPosition()
	if not StarTip.qtipLines[y] then
		StarTip.qtipLines[y] = {}
	end 
	StarTip.qtipLines[y][x] = self.fontString
end

function StarTip.cellPrototype:SetupCell(tooltip, value, justification, font, r, g, b)
	local fs = self.fontString
	fs:SetFontObject(font or tooltip:GetFont())
	fs:SetJustifyH(justification)
	fs:SetText(tostring(value))
	self.r, self.g, self.b = r or self.r, g or self.g, b or self.b
	fs:SetTextColor(self.r, self.g, self.b)
	fs:Show()
	return fs:GetStringWidth(), fs:GetStringHeight()
end

function StarTip.cellPrototype:ReleaseCell()
	self.r, self.g, self.b = 1, 1, 1
end

StarTip.tooltipMain = LQT:Acquire("StarTipTooltipMain", 2)
--StarTip.tooltipMain:SetDefaultProvider(StarTip.cellProvider)
_G["StarTipTooltipMain"] = StarTip.tooltipMain
StarTip.tooltipMain:SetParent(UIParent)
StarTip.tooltipMain:ClearAllPoints()
StarTip.tooltipMain:SetPoint("CENTER")
StarTip.tooltipMain.flash = LibFlash:New(StarTip.tooltipMain)
StarTip.tooltipMain.ShowReal = StarTip.tooltipMain.Show
StarTip.tooltipMain.Show = function()
	StarTip.tooltipMain.flash:Stop()
	StarTip.tooltipMain:ShowReal()
	StarTip.tooltipMain:SetAlpha(1)
	if StarTip.tooltipMain.widget.intersect then StarTip.intersectTimer:Start() end
end
StarTip.tooltipMain.HideReal = StarTip.tooltipMain.Hide
StarTip.tooltipMain.Hide = function()
	StarTip.tooltipMain.flash:Stop()
	StarTip.tooltipMain:HideReal()
	StarTip.intersectTimer:Stop()
end
StarTip.tooltipMain.FadeOut = function()
	if StarTip.tooltipMain:IsShown() and StarTip.tooltipMain:GetAlpha() > 0 then
		StarTip.tooltipMain.flash:FadeOut(1, StarTip.tooltipMain:GetAlpha(), 0, StarTip.tooltipMain.Hide)
	end
end

local trunk = {}
local trunkLines = 1
local function trunkUpdate()
	if GameTooltip:NumLines() > trunkLines then
		for i = trunkLines, GameTooltip:NumLines() do
			local r1, g1, b1 = StarTip.leftLines[i]:GetTextColor();
			local r2, g2, b2 = StarTip.rightLines[i]:GetTextColor();
			local txt1 = StarTip.leftLines[i]:GetText()
			local txt2 = StarTip.rightLines[i]:GetText()
			tinsert(trunk, {txt1, r1, g1, b1, txt2, r2, g2, b2})
		end
		trunkLines = GameTooltip:NumLines()
	end	
end

function StarTip:TrunkAdd(...)
	tinsert(trunk, StarTip.new(...))
end

function StarTip:TrunkClear()
	for i, v in ipairs(trunk) do
		StarTip.del(v)
	end
	wipe(trunk)
end

StarTip.trunk = trunk
StarTip.trunkTimer = LibTimer:New("Trunk Timer", 300, false, trunkUpdate)

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
	--self:RawHook(GameTooltip, "GetUnit", "GameTooltipGetUnit", true)
	
	for k,v in self:IterateModules() do
		if (self.db.profile.modules[k]  == nil and not v.defaultOff) or self.db.profile.modules[k] then
			v:Enable()
		end
	end

	
	self:RestartTimers()
	self:RestartKeys()

	--self:RebuildOpts()
	
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	
	local plugin = {}
	LibStub("LibScriptablePluginColor-1.0"):New(plugin)
	if self.db.profile.message then
		ChatFrame1:AddMessage("|cff751f82" .. L["Welcome to "] .. "|r" .. StarTip.notes .. plugin.Colorize(L[" Type /startip to open config. Alternatively you could press escape and choose the addons menu. Or you can choose to show a minimap icon. You can turn off this message under Settings."], 1, 1, 0))
	end
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
	for i, v in ipairs(timerWidgets) do
		v:Stop()
		v:Del()
	end
	table.wipe(timerWidgets)
	self:StopTimers()
	self:StopKeys()
end

function StarTip:RestartTimers()
	for k, v in ipairs(timerWidgets) do
		v:Stop()
		v:Del()
	end
	table.wipe(timerWidgets)
	for k, v in ipairs(self.db.profile.timers) do
		if v.enabled then
			tinsert(timerWidgets, WidgetTimer:New(self.core, "StarTip.timer." .. k, v, self.db.profile.errorLevel))
			timerWidgets[#timerWidgets]:Start()
		end
	end
end

function StarTip:RestartKeys()
	for k, v in ipairs(keyWidgets) do
		v:Stop()
		v:Del()
	end
	table.wipe(keyWidgets)
	for k, v in ipairs(self.db.profile.keys) do
		if v.enabled then
			local key = WidgetKey:New(self.core, "StarTip.key." .. k, copy(v), self.db.profile.errorLevel)
			table.insert(keyWidgets, key)
			key:Start()
		end
	end
end

function StarTip:StopTimers()
	for k, v in ipairs(timerWidgets) do
		v:Stop()
	end
end

function StarTip:StopKeys()
	for k, v in ipairs(keyWidgets) do
		v:Stop()
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
			if v.desc then
				t.desc = {
					name = "Description",
					type = "input",
					multiline = true,
					get = function() return v.desc end,
					order = 3
				}
			end
		end
		options.args.modules.args[v:GetName()].args = t
	end
	for k, v in pairs(self.db.profile.timers) do
		options.args.timers.args[v.name or "Timer" .. k] = {
			name = v.name or "Timer" .. k,
			type = "group",
			args = WidgetTimer:GetOptions(v, StarTip.RebuildOpts, StarTip)
		}
		options.args.timers.args[v.name or "Timer" .. k].args.delete = {
			name = L["Delete"],
			desc = L["Delete this timer."],
			type = "execute",
			func = function()
				self.db.profile.timers[k] = nil
				self:RebuildOpts()
			end,
			order = 101
		}
		options.args.timers.args[v.name or "Timer" .. k].args.restart = {
			name = L["Restart Timer"],
			desc = L["Would you like to restart this timer?"],
			type = "execute",
			func = function()
				for i, widget in ipairs(timerWidgets) do
					if v.name == widget.config.name then
						widget:Stop()
						widget:Del()
						wipe(widget)
						timerWidgets[i] = WidgetTimer:New(self.core, "StarTip.timer." .. v.name, copy(v), self.db.profile.errorLevel)
						timerWidgets[i]:Start()
					end
				end
			end,
			order = 100
		}
	end
	for k, v in pairs(self.db.profile.keys) do
		options.args.keys.args[v.name or "Key" .. k] = {
			name = v.name or "Timer" .. k,
			type = "group",
			args = WidgetKey:GetOptions(v, StarTip.RebuildOpts, StarTip)
		}
		options.args.keys.args[v.name or "Key" .. k].args.restart = {
			name = L["Restart Key"],
			desc = L["Would you like to restart this key widget?"],
			type = "execute",
			func = function()
				for i, widget in pairs(keyWidgets) do
					if v.name == widget.config.name then
						widget:Stop()
						widget:Del()
						keyWidgets[i] = WidgetKey:New(self.core, "StarTip.key." .. v.name, copy(v), self.db.profile.errorLevel)
						keyWidgets[i]:Start()
					end
				end
			end,
			order = 100
		}
		options.args.keys.args[v.name or "Key" .. k].args.delete = {
			name = L["Delete"],
			desc = L["Delete this key widget."],
			type = "execute",
			func = function()
				self.db.profile.keys[k] = nil
				self:RebuildOpts()
			end,
			order = 101
		}
	end
	collectgarbage()
end

function StarTip:OpenConfig()
	self:RebuildOpts()
	AceConfigDialog:Open("StarTip-Addon")	
end

--[[
function StarTip:HideTooltip()
	GameTooltip:Hide()
	self.tooltipHidden = true
end
--]]

function StarTip:ShowTooltip(unit)
	self.tooltipHidden = false
	unit = unit or StarTip.unit or "mouseover"
	GameTooltip:Hide()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetUnit(unit)
	GameTooltip:Show()
end


function StarTip.GameTooltipAddLine(...)
end

local hideTimer
local function hideTooltip()
	if StarTip.unit ~= "mouseover" and GetMouseFocus() == WorldFrame then StarTip.unit = "mouseover"; return end
	hideTimer:Start()
end

--[[
local throttleTimer
local lastTime = GetTime()
local function endThrottle()
	if UnitExists(StarTip.unit or "mouseover") then
		StarTip.OnTooltipSetUnit()
	end
end
]]

function StarTip.OnTooltipSetUnit(...)

	local _, unit = GameTooltip:GetUnit()
	
	if not unit then return end

	StarTip:TrunkClear()
	trunkLines = GameTooltip:NumLines()

--[[
	hideTimer = hideTimer or LibTimer:New("StarTip.Hide", 100, false, hideTooltip, nil, StarTip.db.profile.errorLevel)
	hideTimer:Start()
	
	throttleTimer = throttleTimer or LibTimer:New("StarTip.Throttle", StarTip.db.profile.throttleVal, false, endThrottle, nil, StarTip.db.profile.errorLevel)
	if GetTime() < lastTime + StarTip.db.profile.throttleVal and UnitIsPlayer("mouseover") and StarTip.db.profile.throttleVal > 0 then 
		throttleTimer:Start(); 
		GameTooltip:Hide() 
		return
	end
	lastTime = GetTime()
]]
	if unit ~= "mouseover" and UnitIsUnit(unit, "mouseover") then
		unit = "mouseover"
	end

	StarTip.owner = GameTooltip:GetOwner()
	StarTip.unit = unit
	environment.unit = unit
		
	if not StarTip.justSetUnit then
		for k, v in StarTip:IterateModules() do
			if v.SetUnit and v:IsEnabled() then v:SetUnit() end
		end
	end

	StarTip.justSetUnit = false

	StarTip.tooltipMain:Show()
	StarTip.trunkTimer:Start()
end

function StarTip.OnTooltipSetItem(self, ...)	
	if StarTip.tooltipHidden then return end
	if not StarTip.justSetItem then
		for k, v in StarTip:IterateModules() do
			if v.SetItem and v:IsEnabled() then v:SetItem(...) end
		end
	end
	StarTip.justSetItem = nil
end

function StarTip.OnTooltipSetSpell(...)	
	if StarTip.tooltipHidden then return end
	if not StarTip.justSetSpell then
		for k, v in StarTip:IterateModules() do
			if v.SetSpell and v:IsEnabled() then v:SetSpell(...) end
		end
	end
	StarTip.justSetSpell = nil
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
	
	--[[
	for k, v in StarTip:IterateModules() do
		if v.GameTooltipHide and v:IsEnabled() then 
			hide = hide and v:GameTooltipHide(...)
		end
	end
	]]
	
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

	if self.db.profile.modifierInverse then
		--show = not show
	end
			
	if not show or StarTip.tooltipHidden then GameTooltip:Hide(); return end

	for k, v in StarTip:IterateModules() do
		if v.GameTooltipShow and v:IsEnabled() then 
			show = show and v:GameTooltipShow(...)
		end
	end
	
	if show then
		StarTip.hooks[GameTooltip].Show(...)
	end
end

--[[
function StarTip:GameTooltipGetUnit()
	local name, unit = self.hooks[GameTooltip].GetUnit(GameTooltip)
	if name then
		return name, unit
	end
	if StarTip.unit and UnitExists(StarTip.unit) then
		local name = UnitName(StarTip.unit)
		return name, StarTip.unit
	end
end
]]

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
		if v.OnFadeOut and v:IsEnabled() then 
			fadeOut = fadeOut and v:OnFadeOut(...)
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
--[[
function StarTip:GetMouseoverUnit()
	local _, tooltipUnit = GameTooltip:GetUnit()
	if not tooltipUnit or not UnitExists(tooltipUnit) or UnitIsUnit(tooltipUnit, "mouseover") then
		return "mouseover"
	else
		return tooltipUnit
	end
end
]]

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
	elseif self.db.profile.modifier == 4 then
		mod = (modifier == "LSHIFT" or modifier == "RSHIFT") and "LSHIFT"
		modifier = "LSHIFT"
	end
		
	if mod ~= modifier then
		return
	end
	
	if up == 0 then
		if not self.db.profile.modifierInverse then
			StarTip:HideTooltip()
		else
			StarTip:ShowTooltip()
		end
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
		if not self.db.profile.modifierInverse then
			StarTip:ShowTooltip()
		end
	else
		-- TODO: Translate that into 4.0 standards.
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


