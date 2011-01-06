local mod = StarTip:NewModule("Nameplates", "AceTimer-3.0")
mod.name = "Hide Nameplates"
mod.toggled = true
mod.desc = "Toggle this module on to cause the tooltip to hide when mousing over nameplates and the control key is down."
mod.defaultOff = true
local _G = _G
local StarTip = _G.StarTip
local GameTooltip = _G.GameTooltip
local options = {}

local anchorsDict = {}

for i, v in ipairs(anchors) do
	anchorsDict[v] = i
end

local function copy(tbl)
	if type(tbl) ~= "table" then return tbl end
	local newTbl = {}
	for k, v in pairs(tbl) do
		newTbl[k] = copy(v)
	end
	return newTbl
end


local defaults = {
	profile = {
		layouts = {}
	}
}

local options = {}
local optionsDefaults = {
}

local update
function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
end

function mod:GetOptions()
	options = {
		layouts = {
			name = "Layouts",
			type = "group",
			args = {
			}
		},
		add = {
			name = L["Add Layout"],
			type = "execute",
			func = function()
				tinsert(self.db.profile.layouts, {UnitTooltip = {}, Bars = {}, Borders = {}})
			end,
		}
	}
	local UnitTooltip = StarTip:GetModule("UnitTooltip")
	local names = UnitTooltip:GetNames()
	local match = {}
	for i, v in ipairs(names) do
		match[v] = i
	end
	tinsert(match, L["Delete"])

	for i, layout in ipairs(self.db.profile.layouts) do
		options.layouts.args[tostring(i)] = {
			name = layout.name,
			type = "group",
			args = {
				UnitTooltip= {
					name = L["Unit Tooltip"],
					type = "group",
					args = {}
				}
			},
			order = i
		}
		for ii, vv in ipairs(layout.UnitTooltip) do
			options.layouts.args[tostring(i)].args.UnitTooltip.args[tostring(ii)] = {
				name = vv.name,
				type = "group",
				args = {
					selection = {
						name = L["Line Selection"],
						values = names,
						get = function()
							return match[vv]
						end,
						set = function(info, val)
							if ii == #names + 1 then
								tremove(v, ii)
								return
							end
							v[i][ii] = names[ii]
						end,
						order = 1
					},
					up = {
						name = L["Move Up"],
						type = "execute",
						func = function()
							if ii == 1 then return end
							v[ii] = v[ii - 1]
							v[ii - 1] = vv
						end,
						order = 2
					},
					down = {
						name = L["Move Down"],
						type = "execute",
						func = function()
							if ii == #match - 1 then return end
							v[ii] = v[ii + 1]
							v[ii + 1] = vv
						end,
						order = 3
					}
				},
				order = ii
			}
		end
	end
	return options
end
