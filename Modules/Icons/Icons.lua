local mod = StarTip:NewModule("Icons")
mod.name = "Icons"
mod.toggled = true
mod.defaultOff = true
local LibBuffer = LibStub("LibScriptableDisplayBuffer-1.0")
local LibCore = LibStub("LibScriptableDisplayCore-1.0")
local LibTimer = LibStub("LibScriptableDisplayTimer-1.0")
local PluginUtils = LibStub("LibScriptableDisplayPluginUtils-1.0")
local WidgetIcon = LibStub("LibScriptableDisplayWidgetIcon-1.0")
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local textures = {}
local textures = {
[0] = "Interface\\Addons\\StarTip\\Media\\black.blp", 
[1] = "Interface\\Addons\\StarTip\\Media\\white.blp",
[2] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-0.blp',
[3] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-1.blp',
[4] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-2.blp',
[5] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-3.blp',
[6] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-4.blp',
[7] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-5.blp',
[8] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-6.blp',
[9] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-7.blp',
[10] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-8.blp',
[11] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-9.blp',
[12] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-10.blp',
[13] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-11.blp',
[14] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-12.blp',
[15] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-13.blp',
[16] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-14.blp',
[17] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-15.blp',
[18] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-16.blp',
[19] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-17.blp',
[20] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-18.blp',
[21] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-19.blp',
[22] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-20.blp',
[23] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-21.blp',
[24] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-22.blp',
[25] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-23.blp',
[26] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-24.blp',
[27] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-25.blp',
[28] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-26.blp',
[29] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-27.blp',
[30] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-28.blp',
[31] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-29.blp',
[32] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-30.blp',
[33] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-31.blp',
[34] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-32.blp',
[35] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-33.blp',
[36] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-34.blp',
[37] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-35.blp',
[38] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-36.blp',
[39] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-37.blp',
[40] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-38.blp',
[41] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-39.blp',
[42] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-40.blp',
[43] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-41.blp',
[44] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-42.blp',
[45] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-43.blp',
[46] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-44.blp',
[47] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-45.blp',
[48] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-46.blp',
[49] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-47.blp',
[50] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-48.blp',
[51] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-49.blp',
[52] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-50.blp',
[53] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-51.blp',
[54] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-52.blp',
[55] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-53.blp',
[56] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-54.blp',
[57] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-55.blp',
[58] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-56.blp',
[59] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-57.blp',
[60] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-58.blp',
[61] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-59.blp',
[62] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-60.blp',
[63] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-61.blp',
[64] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-62.blp',
[65] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-63.blp',
[66] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-64.blp',
[67] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-65.blp',
[68] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-66.blp',
[69] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-67.blp',
[70] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-68.blp',
[71] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-69.blp',
[72] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-70.blp',
[73] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-71.blp',
[74] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-72.blp',
[75] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-73.blp',
[76] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-74.blp',
[77] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-75.blp',
[78] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-76.blp',
[79] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-77.blp',
[80] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-78.blp',
[81] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-79.blp',
[82] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-80.blp',
[83] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-81.blp',
[84] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-82.blp',
[85] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-83.blp',
[86] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-84.blp',
[87] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-85.blp',
[88] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-86.blp',
[89] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-87.blp',
[90] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-88.blp',
[91] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-89.blp',
[92] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-90.blp',
[93] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-91.blp',
[94] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-92.blp',
[95] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-93.blp',
[96] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-94.blp',
[97] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-95.blp',
[98] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-96.blp',
[99] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-97.blp',
[100] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-98.blp',
[101] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-99.blp',
[102] = 'Interface\\Addons\\StarTip\\Media\\gradient\\gradient-100.blp',
}

local environment = {}
local update

local options = {
}

local foo = 200
local defaults = {
	profile = {
		cols = 2,
		rows = 1,
		yres = 8,
		xres = 7,
		size = 15,
		update = 0,
		icons = {
			[1] = {
				["name"] = "Blob",
				["enabled"] = false,
				["bitmap"] = {
					["row1"] = ".....|.....|.....",
					["row2"] = ".....|.....|.***.",
					["row3"] = ".....|.***.|*...*",
					["row4"] = "..*..|.*.*.|*...*",
					["row5"] = ".....|.***.|*...*",
					["row6"] = ".....|.....|.***.",
					["row7"] = ".....|.....|.....",
					["row8"] = ".....|.....|....."
				},
				["speed"] = foo,
				["row"] = 1,
				["col"] = 1
			},
			[2] = {
				["enabled"] = false,
				["name"] = "EKG",
				["bitmap"] = {
					["row1"] = ".....|.....|.....|.....|.....|.....|.....|.....",
					["row2"] = ".....|....*|...*.|..*..|.*...|*....|.....|.....",
					["row3"] = ".....|....*|...*.|..*..|.*...|*....|.....|.....",
					["row4"] = ".....|....*|...**|..**.|.**..|**...|*....|.....",
					["row5"] = ".....|....*|...**|..**.|.**..|**...|*....|.....",
					["row6"] = ".....|....*|...*.|..*.*|.*.*.|*.*..|.*...|*....",
					["row7"] = "*****|*****|****.|***..|**..*|*..**|..***|.****",
					["row8"] = ".....|.....|.....|.....|.....|.....|.....|....."
				},
				["speed"] = foo,
				["row"] = 1,
				["col"] = 0
			},
			[3] = {
				["name"] = "Hearts",
				["enabled"] = false,
				["bitmap"] = {
					["row1"] = ".....|.....|.....|.....|.....|.....",
					["row2"] = ".*.*.|.....|.*.*.|.....|.....|.....",
					["row3"] = "*****|.*.*.|*****|.*.*.|.*.*.|.*.*.",
					["row4"] = "*****|.***.|*****|.***.|.***.|.***.",
					["row5"] = ".***.|.***.|.***.|.***.|.***.|.***.",
					["row6"] = ".***.|..*..|.***.|..*..|..*..|..*..",
					["row7"] = "..*..|.....|..*..|.....|.....|.....",
					["row8"] = ".....|.....|.....|.....|.....|....."
				},
				["speed"] = foo,
				["row"] = 0,
				["col"] = 1
			},
			[4] = {
				["name"] = "Heartbeat",
				["bitmap"] = {
					["row1"] = ".....|.....",
					["row2"] = ".*.*.|.*.*.",
					["row3"] = "*****|*.*.*",
					["row4"] = "*****|*...*",
					["row5"] = ".***.|.*.*.",
					["row6"] = ".***.|.*.*.",
					["row7"] = "..*..|..*..",
					["row8"] = ".....|....."
				},
				["speed"] = foo,
			},
			[5] = {
				["name"] = "Diamonds",
				["bitmap"] = {
					["row1"] = ".....|.....|.....|.....|..*..|.....|.....|.....",
					["row2"] = ".....|.....|.....|..*..|.*.*.|..*..|.....|.....",
					["row3"] = ".....|.....|..*..|.*.*.|*...*|.*.*.|..*..|.....",
					["row4"] = ".....|..*..|.*.*.|*...*|.....|*...*|.*.*.|..*..",
					["row5"] = ".....|.....|..*..|.*.*.|*...*|.*.*.|..*..|.....",
					["row6"] = ".....|.....|.....|..*..|.*.*.|..*..|.....|.....",
					["row7"] = ".....|.....|.....|.....|..*..|.....|.....|.....",
					["row8"] = ".....|.....|.....|.....|.....|.....|.....|....."
				},
				["speed"] = foo,
			},
			[6] = {
				["name"] = "Rain",
				["bitmap"] = {
					["row1"] = "...*.|.....|.....|.*...|....*|..*..|.....|*....",
					["row2"] = "*....|...*.|.....|.....|.*...|....*|..*..|.....",
					["row3"] = ".....|*....|...*.|.....|.....|.*...|....*|..*..",
					["row4"] = "..*..|.....|*....|...*.|.....|.....|.*...|....*",
					["row5"] = "....*|..*..|.....|*....|...*.|.....|.....|.*...",
					["row6"] = ".*...|....*|..*..|.....|*....|...*.|.....|.....",
					["row7"] = ".....|.*...|....*|..*..|.....|*....|...*.|.....",
					["row8"] = ".....|.....|.*...|....*|..*..|.....|*....|...*."
				},
				["speed"] = foo,
				["row"] = 0,
				["col"] = 0
			},
			[7] = {
				["name"] = "Squirrel",
				["bitmap"] = {
					["row1"] = ".....|.....|.....|.....|.....|.....",
					["row2"] = ".....|.....|.....|.....|.....|.....",
					["row3"] = ".....|.....|.....|.....|.....|.....",
					["row4"] = "**...|.**..|..**.|...**|....*|.....",
					["row5"] = "*****|*****|*****|*****|*****|*****",
					["row6"] = "...**|..**.|.**..|**...|*....|.....",
					["row7"] = ".....|.....|.....|.....|.....|.....",
					["row8"] = ".....|.....|.....|.....|.....|....."
				},
				["speed"] = foo,
			},
			[8] = {
				["enabled"] = true,
				["name"] = "Health",
				["bitmap"] = {
					["row1"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|}",
					["row2"] = ".+++.|.+*+.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.***.|",
					["row3"] = "+++++|++*++|++**+|++***|++**.|++**.|++***|++***|++***|++***|++***|*****|*****|",
					["row4"] = "+++++|++*++|++*++|++*++|++***|++***|++***|++***|++***|++***|*****|*****|*****|",
					["row5"] = "+++++|+++++|+++++|+++++|+++++|+++**|+++**|++***|+****|*****|*****|*****|*****|",
					["row6"] = ".+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.++*.|.+**.|.***.|.***.|.***.|.***.|.***.|",
					["row7"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|",
					["row8"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|"
				},
				["speed"] = 500,
				["script"] = [[
return Health(unit)
]],				
				["max"] = [[
return MaxHealth(unit)
]],
				["min"] = [[
return 0			
]],
				["fg_color"] = [[
return MaxHealth(unit) / Health(unit)				
]],
				["row"] = 0,
				["col"] = 0
			},			
			[9] = {
				["enabled"] = true,
				["name"] = "Power",
				["bitmap"] = {
					["row1"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|}",
					["row2"] = ".+++.|.+*+.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.***.|",
					["row3"] = "+++++|++*++|++**+|++***|++**.|++**.|++***|++***|++***|++***|++***|*****|*****|",
					["row4"] = "+++++|++*++|++*++|++*++|++***|++***|++***|++***|++***|++***|*****|*****|*****|",
					["row5"] = "+++++|+++++|+++++|+++++|+++++|+++**|+++**|++***|+****|*****|*****|*****|*****|",
					["row6"] = ".+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.++*.|.+**.|.***.|.***.|.***.|.***.|.***.|",
					["row7"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|",
					["row8"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|"
				},
				["speed"] = 500,
				["script"] = [[
return Power(unit)
]],				
				["max"] = [[
return MaxPower(unit)
]],
				["min"] = [[
return 0			
]],
				["fg_color"] = [[
return MaxPower(unit) / Power(unit)			
]],
				["row"] = 0,
				["col"] = 1
			},			
			
			[10] = {
				["enabled"] = false,
				["name"] = "Clock",
				["bitmap"] = {
					["row1"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|",
					["row2"] = ".***.|.*+*.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.+++.|.+*+.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|",
					["row3"] = "*****|**+**|**++*|**+++|**++.|**++.|**+++|**+++|**+++|**+++|**+++|+++++|+++++|++*++|++**+|++***|++**.|++**.|++***|++***|++***|++***|++***|*****|",
					["row4"] = "*****|**+**|**+**|**+**|**+++|**+++|**+++|**+++|**+++|**+++|+++++|+++++|+++++|++*++|++*++|++*++|++***|++***|++***|++***|++***|++***|*****|*****|",
					["row5"] = "*****|*****|*****|*****|*****|***++|***++|**+++|*++++|+++++|+++++|+++++|+++++|+++++|+++++|+++++|+++++|+++**|+++**|++***|+****|*****|*****|*****|",
					["row6"] = ".***.|.***.|.***.|.***.|.***.|.***.|.**+.|.*++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.++*.|.+**.|.***.|.***.|.***.|.***.|",
					["row7"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|",
					["row8"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|"
				},
				["speed"] = foo,
				["row"] = 0,
				["col"] = 0
			},
			[11] = {
				["name"] = "Wave",
				["bitmap"] = {
					["row1"] = "..**.|.**..|**...|*....|.....|.....|.....|.....|....*|...**",
					["row2"] = ".*..*|*..*.|..*..|.*...|*....|.....|.....|....*|...*.|..*..",
					["row3"] = "*....|....*|...*.|..*..|.*...|*....|....*|...*.|..*..|.*...",
					["row4"] = "*....|....*|...*.|..*..|.*...|*....|....*|...*.|..*..|.*...",
					["row5"] = "*....|....*|...*.|..*..|.*...|*....|....*|...*.|..*..|.*...",
					["row6"] = ".....|.....|....*|...*.|..*..|.*..*|*..*.|..*..|.*...|*....",
					["row7"] = ".....|.....|.....|....*|...**|..**.|.**..|**...|*....|.....",
					["row8"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|....."
				},
				["speed"] = foo,
			},
		}
	}
}

local function checkUnit()
	if not UnitExists(StarTip.unit) then
		
	end
end

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	
	self.core = LibCore:New(mod, environment, "StarTip.Icons", {["StarTip.Icons"] = {}}, nil, StarTip.db.profile.errorLevel)
	self.core.lcd = {LCOLS=self.db.profile.cols, LROWS=self.db.profile.rows, XRES=self.db.profile.xres, YRES=self.db.profile.yres, specialChars = {}}
	
	self.buffer = LibBuffer:New("Icons", self.core.lcd.LCOLS * self.core.lcd.LROWS * self.core.lcd.YRES * self.core.lcd.XRES, 0, StarTip.db.profile.errorLevel)
	
	if self.db.profile.update > 0 then
		self.timer = LibTimer:New("Icons", 100, true, update)
	end
	
	self.unitTimer = LibTimer:New("Icons.unitTimer", 100, true, checkUnit)
end

local function copy(tbl)
	local newTbl = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			v = copy(v)
		end
		newTbl[k] = v
	end
	return newTbl
end

local draw
local function createIcons()
	if type(mod.icons) ~= "table" then mod.icons = {} end

	for k, icon in pairs(mod.db.profile.icons) do
		if icon.enabled then
			local icon = WidgetIcon:New(mod.core, "icon", copy(icon), icon.row or 0, icon.col or 0, icon.layer or 0, StarTip.db.profile.errorLevel, draw)
			icon:SetupChars()
			tinsert(mod.icons, icon)
		end
	end
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
	createIcons()
	-- no need to start the timer
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
	if self.timer then 
		self.timer:Stop()
	end
end

function mod:GetOptionsbleh()
	for i, icon in ipairs(self.db.profile.icons) do
		options.icons.args["Icon"..i] = {
			enabled = {
				name = "Enabled",
				type = "toggle",
				get = function() return icon.enabled end,
				set = function(info, val) icon.enabled = val end,
				order = 1
			},
			speed = {
				name = "Speed",
				type = "input",
				pattern = "%d",
				get = function() return icon.speed end,
				set = function(info, val) icon.speed = val end,
				order = 2
			},
			bitmap = {
				name = "Bitmap",
				type = "input",
				multiline = true,
				width = "full",
				get = function() return icon.bitmap end,
				set = function(info, val) icon.bitmap = val end,
				order = 3
			}
		}
	end
	return options
end

function mod:ClearIcons()
	for k, widget in pairs(mod.icons) do
		widget:Del()
	end
	wipe(mod.icons)
end

function draw(widget)
	local lcd = widget.visitor.lcd
	
	local row = widget.row
	local col = widget.col
	local layer = widget.layer
	local n = row * lcd.YRES * lcd.LCOLS + col * lcd.XRES
	
	local icon = widget.icon
			
	
	local chr = lcd.specialChars[widget.start + widget.index]
		
	for y = 0 , lcd.YRES - 1 do
		local mask = bit.lshift(1, lcd.XRES)
		for x = 0, lcd.XRES - 1 do
			local n = (row * lcd.YRES + y) * lcd.LCOLS * lcd.XRES + col * lcd.XRES + x
			--local n = (row + y) * lcd.LCOLS * lcd.XRES + col + x
			mask = bit.rshift(mask, 1)
			if bit.band(chr[y + 1], mask) == 0 then
				if widget.bg_color then
					mod.buffer.buffer[n] = floor(widget.bg.r * 100) + 2
				else
					mod.buffer.buffer[n] = 0
				end
			else
				if widget.fg_color then
					mod.buffer.buffer[n] = floor(widget.fg.r * 100) + 2
				else
					mod.buffer.buffer[n] = 1
				end
			end
		end
	end
	
	update()
end

function update()
	local lcd = mod.core.lcd
	local text1 = format('|T%s:%d|t', textures[0], mod.db.profile.size or 10)
	local buffers = {}
	for row = 0, lcd.LROWS - 1 do
		for col = 0, lcd.LCOLS - 1 do
			for y = 0, lcd.YRES - 1 do
				for x = 0, lcd.XRES - 1 do
					local n = (row * lcd.YRES + y) * lcd.LCOLS * lcd.XRES + col * lcd.XRES + x
					--local n = (row + y) * lcd.LCOLS * lcd.XRES + col + x
					local color = mod.buffer.buffer[n] or 0
					local text = format('|T%s:%d|t', textures[color] or textures[0], mod.db.profile.size or 10)
					if not buffers[row * lcd.YRES + y] then
						buffers[row * lcd.YRES + y] = LibBuffer:New("tmp.icon", lcd.LCOLS * lcd.XRES, text1)
					end
					buffers[row * lcd.YRES + y]:Replace(col * lcd.XRES + x, text)
					--StarTip.leftLines[row * lcd.YRES + y]:SetText(mod.lines[row * lcd.YRES])
				end
			end
		end
	end
	
	for row = 0, lcd.LROWS * lcd.YRES - 1 do
		--buffers[row]:Replace(lcd.LCOLS, StarTip.leftLines[row + 2]:GetText() or "")
	end
	
	for row = 0, lcd.LROWS - 1 do
		for col = 0, lcd.LCOLS do		
			for y = 0, lcd.YRES - 1 do
				for x = 0, lcd.XRES - 1 do
					local n = (row * lcd.YRES + y) * lcd.LCOLS * lcd.XRES + col * lcd.XRES + x
					--local n = (row + y) * lcd.LCOLS * lcd.XRES + col + x
					if row * lcd.YRES + y + 2 > GameTooltip:NumLines() then
						GameTooltip:AddDoubleLine(' ', ' ')
					end
					
					StarTip.leftLines[row * lcd.YRES + y + 2]:SetText(buffers[row * lcd.YRES + y]:AsString())
				end
			end
		end
	end
			
	if UnitExists(StarTip.unit) then
		GameTooltip:Show()
	end
	
	for k, buffer in pairs(buffers) do
		buffer:Del()
	end
end

function mod:SetUnit()
	first = true
	for k, icon in pairs(self.icons or {}) do
		icon:Start()
	end
	if self.timer then
		self.timer:Start()
	end
	mod.lines = mod.lines or {}
	wipe(mod.lines)
	for i = 0, mod.core.lcd.LCOLS * mod.core.lcd.YRES do
		mod.lines[i] = StarTip.leftLines[i + 1]:GetText()
	end
	self.unitTimer:Start()
end

function mod:OnHide()
	for k, icon in pairs(self.icons or {}) do
		icon:Stop()
	end
	if self.timer then
		self.timer:Stop()
	end
	
	self.unitTimer:Stop()
end
