local mod = StarTip:NewModule("PvP", "AceEvent-3.0")
mod.name = "PvP"
mod.toggled = true
local _G = _G
local GameTooltip = _G.GameTooltip
local UnitFactionGroup = _G.UnitFactionGroup
local self = mod
local L = StarTip.L
local LibWidget = LibStub("LibScriptableWidget-1.0")

local defaults = {
	profile = {
		width = 30,
		height = 30,
		points = {{"TOP", "StarTipTooltipMain", "TOPRIGHT", 0, 0}}
	}
}
mod.defaults = defaults

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)

	local frame = _G.CreateFrame("Frame", nil, StarTip.tooltipMain)
	local pvp = frame:CreateTexture(nil, "TOOLTIP")

	pvp:SetHeight(self.db.profile.height or 30)
	pvp:SetWidth(self.db.profile.width or 30)

	for i, v in pairs(self.db.profile.points) do
		pvp:SetPoint(unpack(v))
	end

	self.PvP = pvp
end

function mod:OnEnable()

	--self:RegisterEvent("UNIT_FACTION")
end

function mod:OnDisable()
	--self:UnregisterEvent("UNIT_FACTION")
end

function mod:UNIT_FACTION(event, unit)

	unit = unit or "mouseover"

	if not UnitExists(unit) then return end

	local factionGroup = UnitFactionGroup(unit)

	if(UnitIsPVPFreeForAll(unit)) then
		self.PvP:SetTexture[[Interface\TargetingFrame\UI-PVP-FFA]]
		self.PvP:Show()
	elseif(factionGroup and UnitIsPVP(unit)) then
		self.PvP:SetTexture([[Interface\TargetingFrame\UI-PVP-]]..factionGroup)
		self.PvP:Show()
	else
		self.PvP:Hide()
	end
end

function mod:SetUnit()
	self:UNIT_FACTION(nil, StarTip.unit or "mouseover")
end

function mod:OnHide()
	self.PvP:Hide()
end

function mod:GetOptions()
	local options = {
		pvp = {
			name = L["PvP Icon"],
			type = "group",
			args = {

				add = {
					name = L["Add Point"],
					desc = L["Add a new point"],
					type = "input",
					set = function(info, v)
						tinsert(db.points, {"TOP", "StarTipTooltipMain", "TOPRIGHT", 0, 0})
					end,
					order = 1
				}
			}
		}
	}
	
	for i, point in ipairs(self.db.profile.points) do
		options.pvp.args["point" .. i] = {
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
					end,
					order = 3
				},
				xOfs = {
					name = L["X Offset"],
					desc = L["X axis offset from attached point."],
					type = "input",
					pattern = "%d",
					get = function() return tostring(point[4] or 0) end,
					set = function(info, v) point[4] = tonumber(v) end,
					order = 5
				},
				yOfs = {
					name = L["Y Offset"],
					desc = L["Y axis offset from attached point."],
					type = "input",
					pattern = "%d",
					get = function() return tostring(point[5] or 0) end,
					set = function(info, v) point[5] = tonumber(v) end,
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
