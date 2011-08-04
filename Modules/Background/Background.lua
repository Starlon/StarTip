local mod = StarTip:NewModule("Background", "AceHook-3.0")
mod.name = "Background"
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UnitExists = _G.UnitExists
local self = mod
local L = StarTip.L
local Evaluator = LibStub("LibScriptableUtilsEvaluator-1.0")

local defaults = {
	profile = {
		guild = [[
local mod = StarTip:GetModule("Appearance")
local db = mod.db.profile
return unpack(db.guild)
]],
		hostilePC = [[
local mod = StarTip:GetModule("Appearance")
local db = mod.db.profile
return unpack(db.hostilePC)
]],
		hostileNPC = [[
local mod = StarTip:GetModule("Appearance")
local db = mod.db.profile
return unpack(db.hostileNPC)
]],
		neutralNPC = [[
local mod = StarTip:GetModule("Appearance")
local db = mod.db.profile
return unpack(db.neutralNPC)
]],
		friendlyNPC = [[
local mod = StarTip:GetModule("Appearance")
local db = mod.db.profile
return unpack(db.friendlyNPC)
]],
		other = [[
local mod = StarTip:GetModule("Appearance")
local db = mod.db.profile
return unpack(db.other)
]],
		dead = [[
local mod = StarTip:GetModule("Appearance")
local db = mod.db.profile
return unpack(db.dead)
]],
		tapped = [[
local mod = StarTip:GetModule("Appearance")
local db = mod.db.profile
return unpack(db.tapped)
]]

}

local get = function(info)
	return self.db.profile[info[#info]]
end

local set = function(info, v)
	self.db.profile[info[#info]] = v
end

local options = {
	background = {
		name = L["Background"],
		desc = L["One of these scripts will be ran when the tooltip shows."],
		type = "group",
		width = "full",
		multiline = true,
		get = get,
		set = set,
		order = 4
		args = {
			header = {
				name = L["Background Color"],
				type = "header",
				order = 1
			},
			guild = {
				name = L["Guild and friends"],
				desc = L["Background color for your guildmates and friends."],
				type = "input",
				width = "full",
				multiline = true,
				order = 2
			},
			hostilePC = {
				name = L["Hostile players"],
				desc = L["Background color for hostile players."],
				type = "input",
				width = "full",
				multiline = true,
				order = 3
			},
			hostileNPC = {
				name = L["Hostile non-player characters"],
				desc = L["Background color for hostile non-player characters."],
				type = "input",
				width = "full",
				multiline = true,
				order = 4
			},
			neutralNPC = {
				name = L["Neutral non-player characters"],
				desc = L["Background color for neutral non-player characters."],
				type = "input",
				width = "full",
				multiline = true,
				order = 5
			},
			friendlyPC = {
				name = L["Friendly players"],
				desc = L["Background color for friendly players."],
				type = "input",
				width = "full",
				multiline = true,
				order = 6
			},
			friendlyNPC = {
				name = L["Friendly non-player characters"],
				desc = L["Background color for friendly non-player characters."],
				type = "input",
				width = "full",
				multiline = true,
				order = 7
			}
		}
	},
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	self:SecureHook("GameTooltip_SetDefaultAnchor")
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
end

function mod:GetOptions()
	return options
end

function mod:GameTooltip_SetDefaultAnchor(this, owner)
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
	local r, g, b, a = Evaluator.ExecuteCode(StarTip.environment, "StarTip.Background", self.db.profile[kind])
        StarTip.tooltipMain:SetBackdropColor(r, g, b, a)
end

