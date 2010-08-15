local mod = StarTip:NewModule("Appearance")
mod.name = "Appearance"
mod.noToggle = true
local _G = _G
local StarTip = _G.StarTip
local GameTooltip = _G.GameTooltip
local ShoppingTooltip1 = _G.ShoppingTooltip1
local ShoppingTooltip2 = _G.ShoppingTooltip2
local self = mod
local LSM = _G.LibStub("LibSharedMedia-3.0")

local defaults = {
	profile = {
		scale = 1,
		font = StarTip:GetLSMIndexByName("font", LSM:GetDefault("font")),
		fontSizeNormal = 12,
		fontSizeBold = 14,		
		edgeFile = StarTip:GetLSMIndexByName("border", "Blizzard Tooltip"),
		background = StarTip:GetLSMIndexByName("background", "Blizzard Tooltip"),
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
		borderColor = { 1, 1, 1, 1 },
		padding = 4,
		edgeSize = 16
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
		name = "Scale Slider",
		desc = "Adjust tooltip scale",
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
		name = "Tooltip Font",
		desc = "Set the tooltip's font",
		type = "select",
		values = LSM:List("font"),
		get = get,
		set = set,
		order = 5
	},
	fontSizeNormal = {
		name = "Normal font size",
		desc = "Set the normal font size",
		type = "input",
		pattern = "%d",
		get = function() return tostring(mod.db.profile.fontSizeNormal) end,
		set = function(info, v) mod.db.profile.fontSizeNormal = tonumber(v) end,
		order = 6
	},
	fontSizeBold = {
		name = "Bold font size",
		desc = "Set the bold font size",
		type = "input",
		pattern = "%d",
		get = function() return tostring(mod.db.profile.fontSizeBold) end,
		set = function(info, v) mod.db.profile.fontSizeBold = tonumber(v) end,
		pattern = "%d",
		order = 7
	},
	edgeFile = {
		name = "Tooltip Border",
		desc = "Set the tooltip's border style",
		type = "select",
		values = LSM:List("border"),
		get = get,
		set = set,
		order = 8
	},
	background = {
		name = "Tooltip Background",
		desc = "Set the tooltip's background style",
		type = "select",
		values = LSM:List("background"),
		get = get,
		set = set,
		order = 9
	},
	borderColor = {
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
	},
	padding = {
		name = "Tooltip Padding",
		desc = "Set the tooltip's padding",
		type = "range",
		min = 0,
		max = 20,
		step = 1,
		get = get,
		set = set,
		order = 11
	},
	edgeSize = {
		name = "Tooltip Edge Size",
		desc = "Set the tooltip's edge size",
		type = "range",
		min = 0,
		max = 20,
		step = 1,
		get = get,
		set = set,
		order = 12
	},
	bgColor = {
		name = "Background Color",
		desc = "Set options for background color",
		type = "group",
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
				name = "Background Color",
				type = "header",
				order = 1
			},
			guild = {
				name = "Guild and friends",
				desc = "Background color for your guildmates and friends.",
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 2
			},
			hostilePC = {
				name = "Hostile players",
				desc = "Background color for hostile players.",
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 3
			},
			hostileNPC = {
				name = "Hostile non-player characters",
				desc = "Background color for hostile non-player characters.",
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 4
			},
			neutralNPC = {
				name = "Neutral non-player characters",
				desc = "Background color for neutral non-player characters.",
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 5
			},
			friendlyPC = {
				name = "Friendly players",
				desc = "Background color for friendly players.",
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 6
			},
			friendlyNPC = {
				name = "Friendly non-player characters",
				desc = "Background color for friendly non-player characters.",
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 7
			},
			dead = {
				name = "Dead",
				desc = "Background color for dead units.",
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 8
			},
			tapped = {
				name = "Tapped",
				desc = "Background color for when a unit is tapped by another.",
				type = "color",
				hasAlpha = true,
				width = "full",
				order = 9
			},
			other = {
				name = "Other Tooltips",
				desc = "Background color for other tooltips.",
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
end

function mod:OnEnable()
	self:SetScale()
	self:SetFont()
	self:SetBackdrop()
	self:SetBorderColor()
	self:SetBackdropColor(true)
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	self:SetScale(true)
	self:SetFont(true)
	self:SetBorderColor(true)
	self:SetBackdrop(true)
	self:SetBackdropColor(true)
	StarTip:SetOptionsDisabled(options, true)
end

function mod:GetOptions()
	return options
end

function mod:SetUnit()
	self.origBackdrop = self.origBackdrop or GameTooltip:GetBackdrop()
	self.origBackdropColor = self.origBackdropColor or {GameTooltip:GetBackdropColor()}
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
		GameTooltip:SetScale(1)
		ShoppingTooltip1:SetScale(1)
		ShoppingTooltip2:SetScale(1)

	else
		GameTooltip:SetScale(self.db.profile.scale)
		ShoppingTooltip1:SetScale(self.db.profile.scale)
		ShoppingTooltip2:SetScale(self.db.profile.scale)

	end
end

function mod:SetFont(reset)
	local font
	if reset then 
		font = "Friz Quadrata TT"
	else
		font = LSM:Fetch('font', LSM:List("font")[self.db.profile.font])
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
		GameTooltip:SetBackdrop(self.origBackdrop)
		ShoppingTooltip1:SetBackdrop(self.origBackdrop)
		ShoppingTooltip2:SetBackdrop(self.origBackdrop)
	else
		local bd = GameTooltip:GetBackdrop()
		local changed = false
		local bgFile = LSM:Fetch('background', LSM:List('background')[self.db.profile.background])
		local edgeFile = LSM:Fetch('border', LSM:List('border')[self.db.profile.edgeFile])

		if bd.bgFile ~= bgFile or bd.edgeFile ~= edgeFile or bd.edgeSize ~= self.db.profile.edgeSize or bd.insets.left ~= self.db.profile.padding then
			changed = true
		end

		if changed then
			tmp.bgFile = bgFile
			tmp.edgeFile = edgeFile
			tmp.tile = false
			tmp.edgeSize = self.db.profile.edgeSize
			tmp.insets = tmp2
			tmp2.left = self.db.profile.padding
			tmp2.right = self.db.profile.padding
			tmp2.top = self.db.profile.padding
			tmp2.bottom = self.db.profile.padding
			GameTooltip:SetBackdrop(tmp)
			ShoppingTooltip1:SetBackdrop(tmp)
			ShoppingTooltip2:SetBackdrop(tmp)
		end
	end
end

function mod:SetBackdropColor(reset)
	if reset then
		if self.origBackdropColor then 
			GameTooltip:SetBackdropColor(unpack(self.origBackdropColor))
			ShoppingTooltip1:SetBackdropColor(unpack(self.origBackdropColor))
			ShoppingTooltip2:SetBackdropColor(unpack(self.origBackdropColor))
		else
			GameTooltip:SetBackdropColor(0,0,0,1)
			ShoppingTooltip1:SetBackdropColor(0,0,0,1)
			ShoppingTooltip2:SetBackdropColor(0,0,0,1)
		end		
	else -- Snagged from CowTip
		local kind
		if UnitExists("mouseover") then
			if UnitIsDeadOrGhost("mouseover") then
				kind = 'dead'
			elseif UnitIsTapped("mouseover") and not UnitIsTappedByPlayer("mouseover") then
				kind = 'tapped'
			elseif UnitIsPlayer("mouseover") then
				if UnitIsFriend("player", "mouseover") then
					local playerGuild = GetGuildInfo("player")
					if playerGuild and playerGuild == GetGuildInfo("mouseover") or UnitIsUnit("player", "mouseover") then
						kind = 'guild'
					else
						local friend = false
						local name = UnitName("mouseover")
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
				if UnitIsFriend("player", "mouseover") then
					kind = 'friendlyNPC'
				else
					local reaction = UnitReaction("mouseover", "player")
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
		GameTooltip:SetBackdropColor(unpack(self.db.profile.bgColor[kind]))
		if kind == 'other' then
			ShoppingTooltip1:SetBackdropColor(unpack(self.db.profile.bgColor[kind]))
			ShoppingTooltip2:SetBackdropColor(unpack(self.db.profile.bgColor[kind]))
		end
	end
end

function mod:SetBorderColor(reset)
	if reset then
		GameTooltip:SetBackdropBorderColor(1,1,1,1)
		ShoppingTooltip1:SetBackdropBorderColor(1,1,1,1)
		ShoppingTooltip2:SetBackdropBorderColor(1,1,1,1)
	else
		GameTooltip:SetBackdropBorderColor(unpack(self.db.profile.borderColor))
		ShoppingTooltip1:SetBackdropBorderColor(unpack(self.db.profile.borderColor))
		ShoppingTooltip2:SetBackdropBorderColor(unpack(self.db.profile.borderColor))
	end
end



