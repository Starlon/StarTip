local mod = StarTip:NewModule("Portrait")
mod.name = "Portrait"
mod.toggled = true
local luaTexts = {}
LibStub("LibScriptableDisplayPluginLuaTexts-1.0"):New(luaTexts)
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local model = CreateFrame("PlayerModel", nil, GameTooltip)

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
			if val then model:Show() else model:Hide() end
		end,
		order = 7
	}
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	self.text = StarTip.leftLines[self.db.profile.line]
	self.texture = GameTooltip:CreateTexture()
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
	
	model:ClearAllPoints()
	model:SetPoint("LEFT", self.text, "LEFT")
	model:SetWidth(self.db.profile.size)
	model:SetHeight(self.db.profile.size)
	
	self.texture:ClearAllPoints()
	self.texture:SetPoint("LEFT", self.text, "LEFT")
	self.texture:SetWidth(self.db.profile.size)
	self.texture:SetHeight(self.db.profile.size)
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
	self.texture:ClearAllPoints()
	self.texture:Hide()
	model:ClearAllPoints()
	model:Hide()
end

function mod:GetOptions()
	return options
end

function mod:SetUnit()
	if not self.text then return end
	
	SetPortraitTexture(self.texture, StarTip.unit)
	
	if not self.texture:GetTexture() then return end
	
	if self.db.profile.animated then
		model:SetUnit(StarTip.unit)
		self.texture:Hide()
		model:Show()
		model:SetCamera(0)
	else
		self.texture:Show()
		model:Hide()
	end
	self.text:SetFormattedText('|T%s:%d|t %s', "", self.db.profile.size, self.text:GetText()) -- we only need a blank space for the texture
end

function mod:OnHide()
	model:Hide()
	self.texture:Hide()
end