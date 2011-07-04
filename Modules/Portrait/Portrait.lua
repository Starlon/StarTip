local mod = StarTip:NewModule("Portrait")
mod.name = "Portrait"
mod.toggled = true
local luaTexts = {}
LibStub("LibScriptablePluginLuaTexts-1.0"):New(luaTexts)
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local L = StarTip.L

local defaults = {
	profile = {
		size = 36,
		tooltipMain = true,
		tooltipUnit = false,
		tooltipItem = true,
		tooltipSpell = true,
		animated = false
	}
}

local options = {
	size = {
		name = L["Size"],
		desc = L["The square portrait's width and height"],
		type = "input",
		pattern = "%d",
		get = function() return tostring(mod.db.profile.size) end,
		set = function(info, val) 
			val = tonumber(val)
			mod.db.profile.size = val
			mod.texture:SetWidth(val)
			mod.texture:SetHeight(val)
			model:SetWidth(val)
			model:SetHeight(val)
		end,
		order = 5
	},
	animated = {
		name = L["3d Model"],
		desc = L["Whether to show the portrait as a 3d model (toggled true) or a 2d model (toggled false)"],
		type = "toggle",
		get = function() return mod.db.profile.animated end,
		set = function(info, val)
			mod.db.profile.animated = val
			if val then mod.model:Show() else mod.model:Hide() end
		end,
		order = 7
	},
	tooltipMain = {
		name = L["Tooltip Main"],
		desc = L["Whether to show a portrait on the main QTip tooltip."],
		type = "toggle",
		get = function() return mod.db.profile.tooltipMain end,
		set = function(info, val)
			mod.db.profile.tooltipMain = val
		end,
		order = 8
	},
	tooltipUnit = {
		name = L["Default Unit Tooltip"],
		desc = L["Whether to show a portrait on the default unit tooltip."],
		type = "toggle",
		get = function() return mod.db.profile.tooltipUnit end,
		set = function(info, val)
			mod.db.profile.tooltipUnit = val
		end,
		order = 9
	},
	tooltipItem = {
		name = L["Item Tooltip"],
		desc = L["Whether to show a portrait on the item tooltip."],
		type = "toggle",
		get = function() return mod.db.profile.tooltipItem end,
		set = function(info, val) mod.db.profile.tooltipItem = val end,
		order = 10,
	},
	tooltipSpell = {
		name = L["Spell Tooltip"],
		desc = L["Whether to show a portrait on the spell tooltip."],
		type = "toggle",
		get = function() return mod.db.profile.tooltipSpell end,
		set = function(info, val) mod.db.profile.tooltipSpell = val end,
		order = 11
	}
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)

	self.text = StarTip.leftLines[self.db.profile.line]
	self.texture = GameTooltip:CreateTexture()
	self.texture2 = StarTip.tooltipMain:CreateTexture()
	self.model = CreateFrame("PlayerModel", nil, GameTooltip)
	self.model2 = CreateFrame("PlayerModel", nil, StarTip.tooltipMain)

	self.model:ClearAllPoints()
	self.model:SetPoint("LEFT", self.text, "LEFT")
	self.model:SetWidth(self.db.profile.size)
	self.model:SetHeight(self.db.profile.size)

	self.model2:ClearAllPoints()
	self.model2:SetPoint("TOPLEFT", StarTip.tooltipMain, "TOPLEFT", 12, -12)
	self.model2:SetWidth(self.db.profile.size)
	self.model2:SetHeight(self.db.profile.size)
	
	self.texture:ClearAllPoints()
	self.texture:SetPoint("LEFT", self.text, "LEFT")
	self.texture:SetWidth(self.db.profile.size)
	self.texture:SetHeight(self.db.profile.size)

	self.texture2:ClearAllPoints()
	self.texture2:SetPoint("TOPLEFT", StarTip.tooltipMain, "TOPLEFT", 12, -12)
	self.texture2:SetWidth(self.db.profile.size)
	self.texture2:SetHeight(self.db.profile.size)
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
	self.texture:ClearAllPoints()
	self.texture:Hide()
	self.model:ClearAllPoints()
	self.model:Hide()
end

function mod:GetOptions()
	return options
end

function mod:SetUnit()
		
	SetPortraitTexture(self.texture, StarTip.unit or "mouseover")
	SetPortraitTexture(self.texture2, StarTip.unit or "mouseover")

	if not self.texture:GetTexture() then 
		self.model:Hide()
		self.model2:Hide()
		self.texture:Hide()
		self.texture2:Hide()
		return 
	end
	
	if self.db.profile.animated then
		self.model:SetUnit(StarTip.unit or "mouseover")
		self.model2:SetUnit(StarTip.unit or "mouseover")
		self.texture:Hide()
		self.texture2:Hide()
		self.model:Show()
		self.model:SetCamera(0)
		self.model2:Show()
		self.model2:SetCamera(0)
	else
		self.texture:Show()
		self.texture2:Show()
		self.model:Hide()
		self.model2:Hide()
	end
	if not self.db.profile.tooltipMain then
		self.texture2:Hide()
		self.model2:Hide()
	end
	if not self.db.profile.tooltipUnit then
		self.texture:Hide()
		self.model:Hide()
	else
		if self.text then
			self.text:SetFormattedText('|T%s:%d|t %s', "", self.db.profile.size, self.text:GetText() or "") -- we only need a blank space for the texture
		end
	end
end

local lasttxt = ""
function mod:SetItem()
	if not self.text or not self.db.profile.tooltipItem then return end

	local txt = self.text:GetText()
	if txt == lasttxt then return end
	
	local link = select(2, GameTooltip:GetItem())
	
	if link then
		--make sure the icon does not display twice on recipies, which fire OnTooltipSetItem twice
		self.text:SetFormattedText('|T%s:%d|t %s', GetItemIcon(link), 36, self.text:GetText())
	end
	lasttxt = self.text:GetText()
end

function mod:SetSpell()
	if not self.text or not self.db.profile.tooltipSpell then return end

	local txt = self.text:GetText()
	if txt == lasttxt then return end
	
	local id = select(3, GameTooltip:GetSpell())
	local icon = id and select(3, GetSpellInfo(id))
	if icon then
		self.text:SetFormattedText('|T%s:%d|t %s', icon, 36, self.text:GetText())
	end
	lasttxt = self.text:GetText()
end

function mod:OnHide()
	self.model:Hide()
	self.texture:Hide()
end
