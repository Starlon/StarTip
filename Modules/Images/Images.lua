local mod = StarTip:NewModule("Images")
mod.name = "IMages"
mod.toggled = true
mod.defaultOff = true
local LibBuffer = LibStub("LibScriptableBuffer-1.0")
local LibCore = LibStub("LibScriptableLCDCore-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0")
local PluginUtils = LibStub("LibScriptablePluginUtils-1.0"):New({})
local WidgetImage = LibStub("LibScriptableWidgetImage-1.0")
local PluginColor = LibStub("LibScriptablePluginColor-1.0"):New({})
local _G = _G
local GameTooltip = _G.GameTooltip
local StarTip = _G.StarTip
local UIParent = _G.UIParent
local textures = {[0] = "Interface\\Addons\\StarTip\\Media\\black.blp", [1] = "Interface\\Addons\\StarTip\\Media\\white.blp"}
local environment = {}
local draw
--[[
local frame = CreateFrame("Frame")
frame:SetParent(UIParent)
frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	tile = true,
	tileSize = 4,
	edgeSize=4, 
	insets = { left = 0, right = 0, top = 0, bottom = 0}})
frame:ClearAllPoints()
frame:SetAlpha(1)
frame:SetWidth(500)
frame:SetHeight(500)
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:Show()
]]

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
		update = 500,
		images = {
			[1] = {
				name = "Analyzer",
				prescript = [[
]],
				script = [[
self:Clear()
y_old = floor(self.height / 2);
for i = 0, self.width - 1 do
	y = (self.height / 2) + (noise[bit.rshift(i, 1) % #noise] * (self.height / 4));
	y = floor(y)
	if (y > y_old) then
		for j = y_old, y do
			self.image[self.index].buffer[j * self.width + i] = 0xffffffff;
		end
	else
		for j = y, y_old - 1 do
			self.image[self.index].buffer[j * self.width + i] = 0xffffffff;
		end
	end
end

]],
				update = 100,
				width = 64,
				height = 64,
				pixel = 4,
				--drawLayer = "UIParent",
				enabled = true,
				points = {{"CENTER", "UIParent", "CENTER"}},
			}
		}
	}
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
	StarTip:SetOptionsDisabled(options, true)
	
	self.core = LibCore:New(mod, StarTip.core.environment, "StarTip.Images", {["StarTip.Images"] = {}}, nil, StarTip.db.profile.errorLevel)
	self.core.lcd = {LCOLS=self.db.profile.cols, LROWS=self.db.profile.rows, LAYERS=self.db.profile.layers}
	
	self.buffer = LibBuffer:New("StarTip.Images", self.core.lcd.LCOLS * self.core.lcd.LROWS, 0, StarTip.db.profile.errorLevel)
	
	if self.db.profile.update > 0 then
		self.timer = LibTimer:New("Images", 100, true, update)
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

local function createImages()
	if type(mod.images) ~= "table" then mod.images = {} end

	for k, image in pairs(mod.db.profile.images) do
		if image.enabled then
			local image = WidgetImage:New(mod.core, "image", copy(image), image.row or 0, image.col or 0, image.layer or 0, StarTip.db.profile.errorLevel, draw)
			local frame = CreateFrame("Frame")
			frame:SetParent(UIParent)
			frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				tile = true,
				tileSize = 4,
				edgeSize=4, 
				insets = { left = 0, right = 0, top = 0, bottom = 0}})
			frame:ClearAllPoints()
			frame:SetAlpha(1)
			frame:SetWidth(image.width * image.pixel)
			frame:SetHeight(image.height * image.pixel)
			frame:SetPoint("CENTER", UIParent, "CENTER")
			image.frame = frame
			image.textures = {}
			for row = 0, image.height - 1 do
			for col = 0, image.width - 1 do
			--for n = 0, image.height * image.width - 1 do
				--local row, col = PluginUtils.GetCoords(n, image.width)
				local n = row * image.width + col
				image.textures[n] = frame:CreateTexture()
				image.textures[n]:SetHeight(image.pixel)
				image.textures[n]:SetWidth(image.pixel)
				image.textures[n]:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", col * image.pixel, (row + 1) * image.pixel)
				image.textures[n]:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
				image.textures[n]:Show()
			end
			end
			frame:ClearAllPoints()
			frame:SetPoint("CENTER")
			tinsert(mod.images, image)
		end
	end
end

function mod:OnEnable()
	StarTip:SetOptionsDisabled(options, false)
	createImages()
	for i, v in pairs(mod.images) do
		v:Start()
	end
	if self.timer then
		self.timer:Start()
	end
	for k, image in pairs(self.images or {}) do
		image:Start()
		image.frame:Show()
	end
end

function mod:OnDisable()
	StarTip:SetOptionsDisabled(options, true)
	if self.timer then 
		self.timer:Stop()
	end
	for k, image in pairs(self.images or {}) do
		image:Stop()
		image.frame:Hide()
	end
end

function mod:GetOptionsbleh()
	for i, image in ipairs(self.db.profile.images) do
		options.images.args["Icon"..i] = {
			enabled = {
				name = "Enabled",
				type = "toggle",
				get = function() return image.enabled end,
				set = function(info, val) image.enabled = val end,
				order = 1
			},
			speed = {
				name = "Speed",
				type = "input",
				pattern = "%d",
				get = function() return image.speed end,
				set = function(info, val) image.speed = val end,
				order = 2
			},
			bitmap = {
				name = "Bitmap",
				type = "input",
				multiline = true,
				width = "full",
				get = function() return image.bitmap end,
				set = function(info, val) image.bitmap = val end,
				order = 3
			}
		}
	end
	return options
end

function mod:ClearImages()
do return end
	for k, widget in pairs(mod.images) do
		widget:Del()
	end
	wipe(mod.images)
end

function draw(widget)	
	for n = 0, widget.height * widget.width - 1 do
		local color = widget.image[widget.index].buffer[n]
		if random(2) == 1 or true then
			widget.textures[n]:SetVertexColor(PluginColor.Color2RGBA(color, true))
		else
			widget.textures[n]:SetVertexColor(1, 1, 1, 1)
		end
	end
end
