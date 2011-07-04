local mod = StarTip:NewModule("Appearance")
mod.name = "Appearance"
mod.noToggle = true
local _G = _G
local StarTip = _G.StarTip
local ShoppingTooltip1 = _G.ShoppingTooltip1
local ShoppingTooltip2 = _G.ShoppingTooltip2
local self = mod
local LSM = _G.LibStub("LibSharedMedia-3.0")
local L = StarTip.L

local defaults = {
	profile = {
		scale = 1,
		font = "Friz Quadrata TT",
		fontSizeNormal = 12,
		fontSizeBold = 14,		
		edgeFile = "Blizzard Tooltip",
		background = "Blizzard Tooltip",
		bgColor = { -- Default colors from CowTip
			guild = {0, 0.15, 0, 1},
			hostilePC = {0.25, 0, 0, 1},
			hostileNPC = {0.15, 0, 0, 1},
			neutralNPC = {0.15, 0.15, 0, 1},
			friendlyPC = {0, 0, 0.25, 1},
			friendlyNPC = {0, 0, 0.15, 1},
			other = {0, 0, 0, 1},
			dead = {0.15, 0.15, 0.15, 1},
			tapped = {0.25, 0.25, 0.25, 1},
		},
		paddingTop = 4,
		paddingBottom = 4,
		paddingLeft = 4,
		paddinRight = 4,
		edgeSize = 16,
		clampLeft = 0,
		clampRight = 10,
		clampTop = 10,
		clampBottom = 10
	}
}

local backdropParts = {bgFile = true, edgeFile = true, edgeSize = true, background = true}
local otherParts = {scale = "SetScale", font = "SetFont"}

local get = function(info)
	return self.db.profile[info[#info]]
end

local set = function(info, v)
	self.db.profile[info[#info]] = v
	if info[#info] == "bgColor" then return end
	if backdropParts[info[#info]] then 
		self:SetBackdrop() 
	elseif info[#info] == "scale" then
		self:SetScale()
	else
		self:SetFont()
	end
end

local options = {
	scale = {
		name = L["Scale Slider"],
		desc = L["Adjust tooltip scale"],
		type = "range",
		min = 0.25,
		max = 4,
		step = 0.01,
		bigStep = 0.05,
		isPercent = true,
		get = get,
		set = set,
		order = 4
	},
	font = {
		name = L["Tooltip Font"],
		desc = L["Set the tooltip's font"],
		type = "select",
		values = LSM:List("font"),
		get = function() 
			return StarTip:GetLSMIndexByName("font", mod.db.profile.font)
		end,
		set = function(info, val)
			local list = LSM:List("font")
			mod.db.profile.font = list[val]
		end,
		order = 5
	},
	fontSizeNormal = {
		name = L["Normal font size"],
		desc = L["Set the normal font size"],
		type = "input",
		pattern = "%d",
		get = function() return tostring(mod.db.profile.fontSizeNormal) end,
		set = function(info, v) mod.db.profile.fontSizeNormal = tonumber(v) end,
		order = 6
	},
	fontSizeBold = {
		name = L["Bold font size"],
		desc = L["Set the bold font size"],
		type = "input",
		pattern = "%d",
		get = function() return tostring(mod.db.profile.fontSizeBold) end,
		set = function(info, v) mod.db.profile.fontSizeBold = tonumber(v) end,
		pattern = "%d",
		order = 7
	},
	edgeFile = {
		name = L["Tooltip Border"],
		desc = L["Set the tooltip's border style"],
		type = "select",
		values = LSM:List("border"),
		get = function()
			return StarTip:GetLSMIndexByName("border", mod.db.profile.edgeFile)
		end,
		set = function(info, val)
			local list = LSM:List("border")
			mod.db.profile.edgeFile = list[val]
		end,
		order = 8
	},
	background = {
		name = L["Tooltip Background"],
		desc = L["Set the tooltip's background style"],
		type = "select",
		values = LSM:List("background"),
		get = function() 
			return StarTip:GetLSMIndexByName("background", mod.db.profile.background)
		end,
		set = function(info, val)
			local list = LSM:List("background")
			mod.db.profile.background = list[val]
		end,
		order = 9
	},
	--[[borderColor = {
		name = "Tooltip Border Color",
		desc = "Set the color of the tooltip's border",
		type = "color",
		hasAlpha = true,
		get = function() return unpack(self.db.profile.borderColor) end,
		set = function(info, r, g, b, a)
			self.db.profile.borderColor[1] = r
			self.db.profile.borderColor[2] = g
			self.db.profile.borderColor[3] = b
			self.db.profile.borderColor[4] = a
		end,
		order = 10
	},]]
	paddingTop = {
		name = L["Tooltip Top Padding"],
		desc = L["Set the tooltip's top side padding"],
		type = "range",
		min = -20,
		max = 20,
		step = 1,
		get = get,
		set = set,
		order = 11
	},
	paddingBottom = {
		name = L["Tooltip Bottom Padding"],
		desc = L["Set the tooltip's bottom side padding"],
		type = "range",
		min = -20,
		max = 20,
		step = 1,
		get = get,
		set = set,
		order = 12
	},
	paddingLeft = {
		name = L["Tooltip Left Padding"],
		desc = L["Set the tooltip's left side padding"],
		type = "range",
		min = -20,
		max = 20,
		step = 1,
		get = get,
		set = set,
		order = 13
	},
	paddingRight = {
		name = L["Tooltip Right Padding"],
		desc = L["Set the tooltip's right side padding"],
		type = "range",
		min = -20,
		max = 20,
		step = 1,
		get = get,
		set = set,
		order = 14
	},
	edgeSize = {
		name = L["Tooltip Edge Size"],
		desc = L["Set the tooltip's edge size"],
		type = "range",
		min = 0,
		max = 20,
		step = 1,
		get = get,
		set = set,
		order = 15
	},
	clampLeft = {
		name = L["Clamp Left"],
		type = "range",
		min = -200,
		max = 200,
		step = 5,
		get = get,
		set = set,
		order = 16
	},
	clampRight = {
		name = L["Clamp Right"],
		type = "range",
		min = -200,
		max = 200,
		step = 5,
		get = get,
		set = set,
		order = 17	
	},
	clampTop = {
		name = L["Clamp Top"],
		type = "range",
		min = -200,
		max = 200,
		step = 5,
		get = get,
		set = set,
		order = 18	
	},
	clampBottom = {
		name = L["Clamp Bottom"],
		type = "range",
		min = -200,
		max = 200,
		step = 5,
		get = get,
		set = set,
		order = 19	
	},
	bgColor = {
		name = L["Background Color"],
		desc = L["Set options for background color"],
		type = "group",
		order = 100,
		get = function(info) 
			return unpack(self.db.profile.bgColor[info[#info]]) 
		end,
		set = function(info, r, g, b, a) 
			self.db.profile.bgColor[info[#info]][1] = r
			self.db.profile.bgColor[info[#info]][2] = g
			self.db.profile.bgColor[info[#info]][3] = b
			self.db.profile.bgColor[info[#info]][4] = a
			self:SetBackdropColor(true)
		end,
		args = {
			header = {
				name = L["Background Color"],
				type = "header",
				order = 1
			},
			guild = {
				name = L["Guild and friends"],
				desc = L["Background color for your guildmates and friends."],
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 2
			},
			hostilePC = {
				name = L["Hostile players"],
				desc = L["Background color for hostile players."],
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 3
			},
			hostileNPC = {
				name = L["Hostile non-player characters"],
				desc = L["Background color for hostile non-player characters."],
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 4
			},
			neutralNPC = {
				name = L["Neutral non-player characters"],
				desc = L["Background color for neutral non-player characters."],
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 5
			},
			friendlyPC = {
				name = L["Friendly players"],
				desc = L["Background color for friendly players."],
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 6
			},
			friendlyNPC = {
				name = L["Friendly non-player characters"],
				desc = L["Background color for friendly non-player characters."],
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 7
			},
			dead = {
				name = L["Dead"],
				desc = L["Background color for dead units."],
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 8
			},
			tapped = {
				name = L["Tapped"],
				desc = L["Background color for when a unit is tapped by another."],
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 9
			},
			other = {
				name = L["Other Tooltips"],
				desc = L["Background color for other tooltips."],
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 10
			}
		}
	}
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)

	StarTip:SetOptionsDisabled(options, true)
	self.st1left, self.st1right, self.st2left, self.st2right = {}, {}, {}, {}
	for i = 1, 50 do
		ShoppingTooltip1:AddDoubleLine(' ', ' ')
		ShoppingTooltip2:AddDoubleLine(' ', ' ')
		self.st1left[i] = _G["ShoppingTooltip1TextLeft" .. i]
		self.st1right[i] = _G["ShoppingTooltip1TextLeft" .. i]
		self.st2left[i] = _G["ShoppingTooltip2TextRight" .. i]
		self.st2right[i] = _G["ShoppingTooltip2TextRight" .. i]
	end
	ShoppingTooltip1:Show()
	ShoppingTooltip1:Hide()
	ShoppingTooltip2:Show()
	ShoppingTooltip2:Hide()

	if type(self.db.profile.edgeFile) == "number" then
		local list = LSM:List("border")
		if list[self.db.profile.edgeFile] then
			self.db.profile.edgeFile = list[self.db.profile.edgeFile]
		else
			self.db.profile.edgeFile = LSM:GetDefault("border")
		end
	end
	
	if type(self.db.profile.background) == "number" then
		local list = LSM:List("background")
		if list[self.db.profile.background] then
			self.db.profile.background = list[self.db.profile.background]
		else
			self.db.profile.background = LSM:GetDefault("background")
		end
	end
	
	if type(self.db.profile.font) == "number" then
		local list = LSM:List("font")
		if list[self.db.profile.font] then
			self.db.profile.font = list[self.db.profile.font]
		else
			self.db.profile.font = LSM:GetDefault("font")
		end
	end
end

function mod:OnEnable()
	self:SetScale()
	self:SetFont()
	self:SetBackdrop()
	self:SetBackdropColor(true)
	StarTip:SetOptionsDisabled(options, false)
	local cleft = self.db.profile.clampLeft
	local cright = self.db.profile.clampRight
	local ctop = self.db.profile.clampTop
	local cbottom = self.db.profile.clampBottom
	StarTip.tooltipMain:SetClampRectInsets(cleft, cright, ctop, cbottom)
end

function mod:OnDisable()
	self:SetScale(true)
	self:SetFont(true)
	self:SetBorderColor(true)
	self:SetBackdrop(true)
	self:SetBackdropColor(true)
	StarTip:SetOptionsDisabled(options, true)
	StarTip.tooltipMain:SetClampRectInsets(0, 0, 0, 0)
end

function mod:GetOptions()
	return options
end

function mod:SetUnit()
	self.origBackdrop = self.origBackdrop or _G["StarTipQTipMain"]:GetBackdrop()
	self.origBackdropColor = self.origBackdropColor or {_G["StarTipQTipMain"]:GetBackdropColor()}
	self:SetBackdropColor()
end

function mod:OnHide()
	self:SetBackdropColor(true)
end

function mod:OnShow()
	self:SetBackdropColor()
end

function mod:SetScale(reset)
	if reset then
		_G["StarTipQTipMain"]:SetScale(1)
		ShoppingTooltip1:SetScale(1)
		ShoppingTooltip2:SetScale(1)

	else
		_G["StarTipQTipMain"]:SetScale(self.db.profile.scale)
		ShoppingTooltip1:SetScale(self.db.profile.scale)
		ShoppingTooltip2:SetScale(self.db.profile.scale)

	end
end

function mod:SetFont(reset)
	local font
	if reset then 
		font = "Friz Quadrata TT"
	else
		font = LSM:Fetch('font', self.db.profile.font)
	end

	if StarTip.leftLines[1]:GetFont() == font then
		return
	end
	for i = 1, 50 do
		local left = StarTip.leftLines[i]
		local right = StarTip.rightLines[i]
		local _, size, style = left:GetFont()
		left:SetFont(font, size, style)
		_, size, style = right:GetFont()
		right:SetFont(font, size, style)

		left = self.st1left[i]
		right = self.st1right[i]
		_, size, style = left:GetFont()
		left:SetFont(font, size, style)
		_, size, style = right:GetFont()
		right:SetFont(font, size, style)

		left = self.st2left[i]
		right = self.st2right[i]
		_, size, style = left:GetFont()
		left:SetFont(font, size, style)
		_, size, style = right:GetFont()
		right:SetFont(font, size, style)		
	end	
end


local tmp, tmp2 = {}, {}
function mod:SetBackdrop()
	if reset then
		_G["StarTipQTipMain"]:SetBackdrop(self.origBackdrop)
		ShoppingTooltip1:SetBackdrop(self.origBackdrop)
		ShoppingTooltip2:SetBackdrop(self.origBackdrop)
	else
		local bd = _G["StarTipQTipMain"]:GetBackdrop()
		local changed = false
		local bgFile = LSM:Fetch('background', self.db.profile.background)
		local edgeFile = LSM:Fetch('border', self.db.profile.edgeFile)

		if bd and (bd.bgFile ~= bgFile or bd.edgeFile ~= edgeFile or bd.edgeSize ~= self.db.profile.edgeSize or bd.insets.left ~= self.db.profile.padding) then
			changed = true
		end

		if changed then
			tmp.bgFile = bgFile
			tmp.edgeFile = edgeFile
			tmp.tile = false
			tmp.edgeSize = self.db.profile.edgeSize
			tmp.insets = tmp2
			tmp2.left = self.db.profile.paddingLeft
			tmp2.right = self.db.profile.paddingRight
			tmp2.top = self.db.profile.paddingTop
			tmp2.bottom = self.db.profile.paddingBottom
			_G["StarTipQTipMain"]:SetBackdrop(tmp)
			ShoppingTooltip1:SetBackdrop(tmp)
			ShoppingTooltip2:SetBackdrop(tmp)
		end
	end
end

function mod:SetBackdropColor(reset)
	if reset then
		if self.origBackdropColor then 
			_G["StarTipQTipMain"]:SetBackdropColor(unpack(self.origBackdropColor))
			ShoppingTooltip1:SetBackdropColor(unpack(self.origBackdropColor))
			ShoppingTooltip2:SetBackdropColor(unpack(self.origBackdropColor))
		else
			_G["StarTipQTipMain"]:SetBackdropColor(0,0,0,1)
			ShoppingTooltip1:SetBackdropColor(0,0,0,1)
			ShoppingTooltip2:SetBackdropColor(0,0,0,1)
		end		
	else -- Snagged from CowTip
		local kind
		if UnitExists(StarTip.unit or "mouseover") then
			if UnitIsDeadOrGhost(StarTip.unit or "mouseover") then
				kind = 'dead'
			elseif UnitIsTapped(StarTip.unit or "mouseover") and not UnitIsTappedByPlayer(StarTip.unit or "mouseover") then
				kind = 'tapped'
			elseif UnitIsPlayer(StarTip.unit or "mouseover") then
				if UnitIsFriend("player", StarTip.unit or "mouseover") then
					local playerGuild = GetGuildInfo("player")
					if playerGuild and playerGuild == GetGuildInfo(StarTip.unit or "mouseover") or UnitIsUnit("player", StarTip.unit or "mouseover") then
						kind = 'guild'
					else
						local friend = false
						local name = UnitName(StarTip.unit or "mouseover")
						for i = 1, GetNumFriends() do
							if GetFriendInfo(i) == name then
								friend = true
								break
							end
						end
						if friend then
							kind = 'guild'
						else
							kind = 'friendlyPC'
						end
					end
				else
					kind = 'hostilePC'
				end
			else
				if UnitIsFriend("player", StarTip.unit or "mouseover") then
					kind = 'friendlyNPC'
				else
					local reaction = UnitReaction(StarTip.unit or "mouseover", "player")
					if not reaction or reaction <= 2 then
						kind = 'hostileNPC'
					else
						kind = 'neutralNPC'
					end
				end
			end
		else
			kind = 'other'
		end
		_G["StarTipQTipMain"]:SetBackdropColor(unpack(self.db.profile.bgColor[kind]))
		if kind == 'other' then
			ShoppingTooltip1:SetBackdropColor(unpack(self.db.profile.bgColor[kind]))
			ShoppingTooltip2:SetBackdropColor(unpack(self.db.profile.bgColor[kind]))
		end
	end
end



