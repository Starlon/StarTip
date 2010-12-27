local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("StarTip", "enUS", true, true)
if not L then return end

L["Welcome to "] = true
L[" Type /startip to open config. Alternatively you could press escape and choose the addons menu. Or you can choose to show a minimap icon. You can turn off this message under Settings."] = true
L["None"] = true
L["Ctrl"] = true
L["Alt"] = true
L["Shift"] = true
L["Modules"] = true
L["Timers"] = true
L["Add Timer"] = true
L["Add a timer widget"] = true
L["Restore Defaults"] = true
L["Use this to restore the defaults"] = true
L["Minimap"] = true
L["Toggle showing minimap button"] = true
L["Modifier"] = true
L["Whether to use a modifier key or not"] = true
L["Unit"] = true
L["Whether to show unit tooltips"] = true
L["Object"] = true
L["Whether to show object tooltips"] = true
L["Unit Frame"] = true
L["Whether to show unit frame tooltips"] = true
L["Other Frame"] = true
L["Whether to show other frame tooltips"] = true
L["Error Level"] = true
L["StarTip's error level"] = true
L["StarTip can throttle your mouseovers, so it doesn't show a tooltip if you mouse over units really fast. There are a few bugs here, which is why it's not enabled by default."] = true
L["Throttle Threshold"] = true
L["Intersect Checks Rate"] = true
L["The rate at which intersecting frames will be checked"] = true
L["Settings"] = true
L["Enable"] = true
L["Enable or disable this module"] = true
