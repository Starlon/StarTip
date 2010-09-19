--@debug@
local mod = StarTip:NewModule("Debug", "AceEvent-3.0")
mod.name = "Debug"
mod.toggled = true
mod.defaultOff = true
local LibTimer = LibStub("StarLibTimer-1.0")
local LibBuffer = LibStub("StarLibBuffer-1.0")
local WidgetText = LibStub("StarLibWidgetText-1.0")
local LibProperty = LibStub("StarLibProperty-1.0")
local LibCore = LibStub("StarLibCore-1.0")

local environment = {}

local core = LibCore:New(mod, environment, "StarTip.Debug", {["StarTip.Debug"] = {}})		
local objects = {}
local defaults = {profile={debug=false}}
local timer
local cfg = {
		enabled = true,
		value = [[
if not UnitExists(unit) then return end
return '--' .. select(1, UnitName(unit)) .. '--'
]],
		color = [[
if not UnitExists(unit) then return end
return ClassColor(unit)
]],
		cols = 500,
		align = WidgetText.ALIGN_PINGPONG,
		update = 1000,
		speed = 100,
		direction = SCROLL_LEFT,
		dontRtrim = true,
		point = {"BOTTOMLEFT", "GameTooltip", "TOPLEFT", 0, 12},
		parent = "GameTooltip",
}

function mod:OnInitialize()
	self.db = StarTip.db:RegisterNamespace(self:GetName(), defaults)
end

local function new1()
	return LibBuffer:New("Debug buffer", 0, " ")
end

local function updateText(widget)

end

local function new2()
	return WidgetText:New(core, "Debug text", cfg, 0, 0, 0, StarTip.db.profile.errorLevel, updateText) 
end

local function new3()
	return LibProperty:New(nil, core,	"debug property", "", "")
end

local plugin = {}
LibStub("StarLibPluginString-1.0"):New(plugin)

local function update()
	for i, v in ipairs(objects) do
		v:Del()
	end
	wipe(objects)
	ResourceServer.Update()
	local mem1, percent1, memdiff1, totalMem1, totaldiff1 = ResourceServer.GetMemUsage("StarTip")
	for j = 1, random(50) do
		local object = new2()
		object.cols = random(50)
		object:Start()
		tinsert(objects, object)
	end
	ResourceServer.Update()
	local mem2, percent2, memdiff2, totalMem2, totaldiff2 = ResourceServer.GetMemUsage("StarTip")	
	StarTip:Print("Memory",  plugin.memshort(mem2 - mem1), plugin.memshort(memdiff2))
end

function mod:OnEnable()
	timer = timer or LibTimer:New("Debug timer", 1000, true, update)
	if false then
		timer:Start()
	end
end

function mod:OnDisable()
	timer:Stop()
end

function mod:SetUnit()
end

function mod:OnHide()
end
--@end-debug