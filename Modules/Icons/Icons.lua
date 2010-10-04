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
local textures = {[0] = "Interface\\Addons\\StarTip\\Media\\blank.tga", [1] = "Interface\\Addons\\StarTip\\Media\\white.blp"}
local environment = {}
local update

local options = {
}

local foo = 200
local defaults = {
	profile = {
		cols = 2,
		rows = 2,
		yres = 8,
		xres = 7,
		size = 15,
		update = 0,
		icons = {
			[1] = {
				["name"] = "Blob",
				["enabled"] = true,
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
				["enabled"] = true,
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
			},
			[9] = {
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

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	
	self.core = LibCore:New(mod, environment, "StarTip.Icons", {["StarTip.Icons"] = {}}, nil, StarTip.db.profile.errorLevel)
	self.core.lcd = {LCOLS=self.db.profile.cols, LROWS=self.db.profile.rows, XRES=self.db.profile.xres, YRES=self.db.profile.yres, specialChars = {}}
	
	self.buffer = LibBuffer:New("Icons", self.core.lcd.LCOLS * self.core.lcd.LROWS, 0, StarTip.db.profile.errorLevel)
	
	if self.db.profile.update > 0 then
		self.timer = LibTimer:New("Icons", 100, true, update)
	end
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
			StarTip:Print(icon.row)
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
			local n = (row + y) * lcd.LCOLS * lcd.XRES + col + x
			mask = bit.rshift(mask, 1)
			if bit.band(chr[y + 1], mask) == 0 then
				mod.buffer.buffer[n] = 1
			else
				mod.buffer.buffer[n] = 0
			end
		end
	end
	
	update()
end

function update()
	local lcd = mod.core.lcd
	local text = format('|T%s:%d|t', textures[0], mod.db.profile.size or 10)
	local buffers = {}
	for row = 0, lcd.LROWS do
		for col = 0, lcd.LCOLS do
			for y = 0, lcd.YRES - 1 do
				for x = 0, lcd.XRES - 1 do
					local n = (row * lcd.YRES + y) * lcd.LCOLS * lcd.XRES + col * lcd.XRES + x
					local n = (row + y) * lcd.LCOLS * lcd.XRES + col + x
					local color = mod.buffer.buffer[n] or 0
					local text = format('|T%s:%d|t', textures[color], mod.db.profile.size or 10)
					if not buffers[row + y] then
						buffers[row + y] = LibBuffer:New("tmp.icon", 0, text)
					end
					buffers[row + y]:Replace(col * lcd.XRES + x, text)
				end
			end
		end
	end
	
	for row = 0, lcd.LROWS - 1 do
		for col = 0, lcd.LCOLS - 1 do		
			for y = 0, lcd.YRES - 1 do
				for x = 0, lcd.XRES - 1 do
					local n = (row * lcd.YRES + y) * lcd.LCOLS * lcd.XRES + col * lcd.XRES + x
					local n = (row + y) * lcd.LCOLS * lcd.XRES + col + x
					if StarTip.leftLines[row + y + 2] and buffers[row + y] then 
						StarTip.leftLines[row + y + 2]:SetText(buffers[row + y]:AsString())
					end			
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
end

function mod:OnHide()
	for k, icon in pairs(self.icons or {}) do
		icon:Stop()
	end
	if self.timer then
		self.timer:Stop()
	end
end
