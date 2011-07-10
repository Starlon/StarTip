local mod = StarTip:NewModule("RaidIcon", "AceEvent-3.0")
mod.name = "RaidIcon"
mod.toggled = true
local _G = _G
local GameTooltip = _G.GameTooltip
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local SetRaidTargetIconTexture = _G.SetRaidTargetIconTexture
local self = mod
local L = StarTip.L

local defaults = {
	profile = {
		width = 16,
		height = 16,
		points = {{"TOP", "StarTipQTipMain", "TOP", 0, 4}}
	}
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	local frame = CreateFrame("Frame", nil, StarTip.tooltipMain)
	local icon = frame:CreateTexture(nil, "OVERLAY")
	icon:SetHeight(self.db.profile.height)
	icon:SetWidth(self.db.profile.width)
	icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	icon:Hide()
	self.icon = icon
	self:ReAnchor()
end

function mod:OnEnable()
	self:RegisterEvent("RAID_TARGET_UPDATE")
end

function mod:OnDisable()
	self:UnregisterEvent("RAID_TARGET_UPDATE")
end

function mod:SetUnit()
	self:RAID_TARGET_UPDATE()
end

function mod:OnHide()
	if self.icon:IsShown() then self.icon:Hide() end
end

function mod:ReAnchor()
	self.icon:ClearAllPoints()
	for i, v in ipairs(self.db.profile.points) do
		self.icon:SetPoint(unpack(v))
	end
end

function mod:RAID_TARGET_UPDATE(event)
	local index = _G.GetRaidTargetIndex("mouseover")

	if(index) then
		_G.SetRaidTargetIconTexture(self.icon, index)
		self.icon:Show()
	else
		self.icon:Hide()
	end
end

function mod:GetOptions()
	local options = {
		icon = {
			name = L["Raid Icon"],
			type = "group",
			args = {

				add = {
					name = L["Add Point"],
					desc = L["Add a new point"],
					type = "input",
					set = function(info, v)
						tinsert(db.points, {"TOP", "StarTipQTip", "TOP", 0, 0})
					end,
					order = 1
				}
			}
		},
		width = {
			name = L["Icon Width"],
			desc = L["How wide to make the raid icon."],
			type = "input",
			pattern = "%d",
			get = function() return tostring(self.db.profile.width or 16) end,
			set = function(info, v) 
				self.db.profile.width = tonumber(v) 
				self.icon:SetWidth(self.db.profile.width)
			end,
			order = 1
		},
		height = {
			name = L["Icon Height"],
			desc = L["How tall to make the raid icon."],
			type = "input",
			pattern = "%d",
			get = function() return tostring(self.db.profile.height or 16) end,
			set = function(info, v) 
				self.db.profile.height = tonumber(v) 
				self.icon:SetHeight(self.db.profile.height)
			end,
			order = 1
		}
	}
	
	for i, point in ipairs(self.db.profile.points) do
		options.icon.args["point" .. i] = {
			name = "Point #" .. i,
			type = "group",
			order = i + 1,
			args = {
				point = {
					name = L["Icon Point"],
					desc = L["Which point of the PvP icon is attached at the relative point."],
					type = "select",
					values = LibWidget.anchors,
					get = function() return LibWidget.anchorsDict[point[1] or 1] end,
					set = function(info, v) 
						point[1] = LibWidget.anchors[v]
						self:ReAnchor()
					end,
					order = 1
				},
--[[
				relativeFrame = {
					name = L["Relative Frame"],
					type = "input",
					get = function() return point[2] end,
					set = function(info, v)
						points[2] = v
					end,
					order = 2
				},
]]
				relativePoint = {
					name = L["Relative Point"],
					desc = L["Which point of StarTip's tooltip should the PvP icon be attached."],
					type = "select",
					values = LibWidget.anchors,
					get = function() return LibWidget.anchorsDict[point[3] or 1] end,
					set = function(info, v)
						point[3] = LibWidget.anchors[v]
						self:ReAnchor()
					end,
					order = 3
				},
				xOfs = {
					name = L["X Offset"],
					desc = L["X axis offset from attached point."],
					type = "input",
					pattern = "%d",
					get = function() return tostring(point[4] or 0) end,
					set = function(info, v) 
						point[4] = tonumber(v) 
						self:ReAnchor()
					end,
					order = 5
				},
				yOfs = {
					name = L["Y Offset"],
					desc = L["Y axis offset from attached point."],
					type = "input",
					pattern = "%d",
					get = function() return tostring(point[5] or 0) end,
					set = function(info, v) 
						point[5] = tonumber(v) 
						self:ReAnchor()
					end,
					order = 5
				},
				delete = {
					name = L["Delete"],
					desc = L["Delete this point"],
					type = "execute",
					func = function()
						tremove(self.db.profile.points, i)
					end,
					order = 6
				}
			}
		}
	end

	return options
	
end
