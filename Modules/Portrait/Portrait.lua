local mod = StarTip:NewModule("Portrait")
mod.name = "Portrait"
mod.toggled = true
local luaTexts = {}
LibStub("LibScriptableDisplayPluginLuaTexts-1.0"):New(luaTexts)
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent

local defaults = {
	profile = {
		size = 36,
		line = 1,
		animated = false
	}
}

local options = {
	size = {
		name = "Size",
		desc = "The texture's width and height",
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
	line = {
		name = "Line",
		desc = "Which line to place the portrait on",
		type = "input",
		pattern = "%d",
		get = function() return tostring(mod.db.profile.line) end,
		set = function(info, val)
			val = tonumber(val)
			mod.db.profile.line = val
			mod.text = StarTip.leftLines[val]
			mod.texture:ClearAllPoints()
			mod.texture:SetPoint("LEFT", mod.text, "LEFT")
			model:ClearAllPoints()
			model:SetPoint("LEFT", mod.text, "LEFT")
		end,
		order = 6
	},
	animated = {
		name = "3d Model",
		desc = "Whether to show the portrait as a 3d model (toggled true) or a 2d model (toggled false)",
		type = "toggle",
		get = function() return mod.db.profile.animated end,
		set = function(info, val)
			mod.db.profile.animated = val
			if val then mod.model:Show() else mod.model:Hide() end
		end,
		order = 7
	}
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	self.text = StarTip.leftLines[self.db.profile.line]
	self.texture = GameTooltip:CreateTexture()
	self.model = CreateFrame("PlayerModel", nil, GameTooltip)
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
	
	self.model:ClearAllPoints()
	self.model:SetPoint("LEFT", self.text, "LEFT")
	self.model:SetWidth(self.db.profile.size)
	self.model:SetHeight(self.db.profile.size)
	
	self.texture:ClearAllPoints()
	self.texture:SetPoint("LEFT", self.text, "LEFT")
	self.texture:SetWidth(self.db.profile.size)
	self.texture:SetHeight(self.db.profile.size)
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
	if not self.text or not self.texture then return end
		
	SetPortraitTexture(self.texture, StarTip.unit or "mouseover")
	
	if not self.texture:GetTexture() then 
		self.model:Hide()
		self.texture:Hide()
		return 
	end
	
	if self.db.profile.animated then
		self.model:SetUnit(StarTip.unit)
		self.texture:Hide()
		self.model:Show()
		self.model:SetCamera(0)
	else
		self.texture:Show()
		self.model:Hide()
	end
	self.text:SetFormattedText('|T%s:%d|t %s', "", self.db.profile.size, self.text:GetText() or "") -- we only need a blank space for the texture
end

local lasttxt = ""
function mod:SetItem()
	if not self.text then return end

	local txt = self.text:GetText()
	if txt == lasttxt then return end
	
	local link = select(2, GameTooltip:GetItem())
	
	if link then
		--make sure the icon does not display twice on recipies, which fire OnTooltipSetItem twice
		self.text:SetFormattedText('|T%s:%d|t%s', GetItemIcon(link), 36, self.text:GetText())
	end
	lasttxt = self.text:GetGext()
end

function mod:SetSpell()
	if not self.text then return end

	local txt = self.text:GetText()
	if txt == lasttxt then return end
	
	local id = select(3, GameTooltip:GetSpell())
	local icon = id and select(3, GetSpellInfo(id))
	if icon then
		self.text:SetFormattedText('|T%s:%d|t%s', icon, 36, self.text:GetText())
	end
	lasttxt = self.text:GetText()
end

function mod:OnHide()
	self.model:Hide()
	self.texture:Hide()
end