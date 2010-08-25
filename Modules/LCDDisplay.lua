local mod = StarTip:NewModule("LCDDisplay")
mod.name = "LCD Display"
mod.toggled = true
mod.defaultOff = true
local Evaluator = LibStub("StarLibEvaluator-1.0")
local LibCore = LibStub("StarLibCore-1.0")
local LibLCDText = LibStub("StarLibLCDText-1.0")
local LibDriverQTip = LibStub("StarLibDriverQTip-1.0")
local WidgetText = LibStub("StarLibWidgetText-1.0")
local WidgetBar = LibStub("StarLibWidgetBar-1.0")
local WidgetHistogram = LibStub("StarLibWidgetHistogram-1.0")
local LayoutOptions = LibStub("StarLibLayoutOptions-1.0")

local _G = _G
local GameTooltip = _G.GameTooltip

local function copy(tbl)
	local new = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			new[k] = copy(v)
		else
			new[k] = v
		end
	end
	return new
end

local defaults = {profile= {config=copy(StarTip.config)}}
local displays = {}

local options
local blankOptions = {
	restart = {
		name = "Restart Displays",
		type = "execute",
		func = function()
			mod:StopDisplays()
			mod:StartDisplays()
		end,
		order = 1
	},
	defaults = {
		name = "Restore Defaults",
		type = "execute",
		func = function()
			mod.db.profile.config = copy(StarTip.config)
			StarTip:RebuildOpts()
		end,
		order = 2
	},
	displays = {
		name = "Displays",
		type = "group",
		args = {},
		order = 3
	},
	layouts = {
		name = "Layouts",
		type = "group",
		args = {},
		order = 4
	},
	widgets = {
		name = "Widgets",
		type = "group",
		args = {},
		order = 5
	}
}

function mod:RebuildOpts()
	options = copy(blankOptions)
	StarTip:Print("rebuild opts")
	options.displays.args.add = {
		name = "Add Display",
		type = "input",
		set = function(info, v)
			self.db.profile.config["display_" .. v] = {name = v, layouts = {}, widgets = {}}
			StarTip:RebuildOpts()
		end,
		order = 1
	}
	options.layouts.args.add = {
		name = "Add Layout",
		type = "input",
		set = function(info, v)
			self.db.profile.config["layout_" .. v] = {name = v}
			StarTip:RebuildOpts()
		end,
		order = 1
	}
	options.widgets.args.text = {
		name = "Text Widgets",
		type = "group",
		args = {
			add = {
				name = "Add",
				desc = "Enter a name for your text widget",
				type = "input",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "text"}
					StarTip:RebuildOpts()
				end,
				order = 1
			},
		}
	}
	options.widgets.args.bar = {
		name = "Bars",
		type = "group",
		args = {
			add = {
				name = "Add",
				desc = "Enter a name for your bar widget",
				type = "input",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "bar"}
					StarTip:RebuildOpts()
				end,
				order = 1
			}
		}	
	}
	options.widgets.args.histogram = {
		name = "Histograms",
		type = "group",
		args = {
			add = {
				name = "Add",
				desc = "Enter a name for your histogram widget",
				type = "input",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "histogram"}
					StarTip:RebuildOpts()
				end,
				order = 1
			}
		}	
	}	
	options.widgets.args.icon = {
		name = "Icons",
		type = "group",
		args = {
			add = {
				name = "Add",
				desc = "Enter a name for your icon widget",
				type = "input",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "icon"}
					StarTip:RebuildOpts()
				end,
				order = 1
			}
		}
	}	
	options.widgets.args.key = {
		name = "Keys",
		type = "group",
		args = {
			add = {
				name = "Add",
				desc = "Enter a name for your key widget",
				type = "input",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "key"}
					StarTip:RebuildOpts()
				end,
				order = 1
			}
		}
	}
	for k, v in pairs(self.db.profile.config) do
		if k:match("^display_.*") then
			options.displays.args[k:gsub(" ", "_")] = {
				name = k:gsub("display_", ""),
				type = "group",
				args = { 
					enable = {
						name = "Enable",
						type = "toggle",
						get = function()
							return v.enabled
						end,
						set = function(info, val)
							v.enabled = val
						end,
						order = 1
					},
					driver = {
						name = "Driver",
						desc = "This display's driver type",
						type = "select",
						values = LibCore.driverList,
						get = function() return LibCore.driverDict[v.driver] end,
						set = function(info, val)
							v.driver = LibCore.driverList[val]
							StarTip:RebuildOpts()
						end,
						order = 2
				
					},
					delete = {
						name = "Delete",
						type = "execute",
						func = function()
							StarTip:Print("delete")
							self.db.profile.config[k] = nil
							StarTip:RebuildOpts()
						end,
						order = 100
					}
				}
			}
			local driverOptions = {}
			if v.driver == "QTip" then
				driverOptions = LibDriverQTip:RebuildOpts(StarTip, v, k)
			end
			
			for kk, vv in pairs(driverOptions) do
				options.displays.args[k:gsub(" ", "_")].args[kk] = vv
			end
		end
		if k:match("^layout_") then
			options.layouts.args[k:gsub(" ", "_")] = {
				name = k,
				type = "group",
				args = {}
			}
			options.layouts.args[k:gsub(" ", "_")].args = LayoutOptions:RebuildOpts(StarTip, v, k)
			options.layouts.args[k:gsub(" ", "_")].args.delete = {
				name = "Delete",
				type = "execute",
				func = function()
					self.db.profile.config[k] = nil
					StarTip:RebuildOpts()
				end
			}
			
		end
		if k:match("^widget_") then
			if v.type == "text" then
				options.widgets.args.text.args[k:gsub(" ", "_")] = {
					name = k:gsub("widget_", ""),
					type = "group",
					args = WidgetText:GetOptions(StarTip, v, k),
					order = 1
				}
				options.widgets.args.text.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						StarTip:RebuildOpts()
					end,
					order = 100
				}
			elseif v.type == "bar" then
				options.widgets.args.bar.args[k:gsub(" ", "_")] = {
					name = k,
					type = "group",
					args = WidgetBar:GetOptions(StarTip, v, k),
					order = 1
				}						
				options.widgets.args.bar.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						StarTip:RebuildOpts()
					end,
					order = 100
				}				
			elseif v.type == "histogram" then
				options.widgets.args.histogram.args[k:gsub(" ", "_")] = {
					name = k,
					type = "group",
					args = WidgetHistogram:GetOptions(StarTip, v, k),
					order = 1
				}						
				options.widgets.args.histogram.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						StarTip:RebuildOpts()
					end,
					order = 100
				}				
			elseif v.type == "icon" then
				options.widgets.args.icon.args[k:gsub(" ", "_")] = {
					name = k,
					type = "group",
					args = {}, --WidgetIcon:GetOptions(StarTip, v, k)},
					order = 2
				}
				options.widgets.args.icon.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						StarTip:RebuildOpts()
					end,
					order = 100
				}				
			elseif v.type == "key" then
				options.widgets.args.key.args[k:gsub(" ", "_")] = {
					name = k,
					type = "group",
					args = {}, --WidgetKey:GetOptions(StarTip, v, k)}
					order = 3
				}			
				options.widgets.args.key.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						StarTip:RebuildOpts()
					end,
					order = 100
				}			
			end
		end
	end
end

function mod:GetOptions()
	self:RebuildOpts()
	return options
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
		
end

function mod:OnEnable()
	self:StartDisplays()
end

function mod:OnDisable()
	self:StopDisplays()
end

function mod:StartDisplays()
	for k, v in pairs(self.db.profile.config) do
		if k:match("^display_") then
			if v.driver == "QTip" then
				local display = LibDriverQTip:New(self, k, self.db.profile.config, StarTip.db.profile.errorLevel) 
				display.core:CFGSetup()
				display.core:BuildLayouts()
				display.core:Start()
				display:Show()
				tinsert(displays, display)
			end
		end
	end
end

function mod:StopDisplays()
	for i, v in ipairs(displays) do
		v:Hide()
		v:Del()
	end
	table.wipe(displays)
end