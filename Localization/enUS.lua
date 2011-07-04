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
L["StarTip can throttle your mouseovers, so it doesn't show a tooltip if you mouse over units really fast. There are a few bugs, which is why it's not enabled by default."] = true
L["Throttle Threshold"] = true
L["Intersect Checks Rate"] = true
L["The rate at which intersecting frames will be checked"] = true
L["Settings"] = true
L["Enable"] = true
L["Enable or disable this module"] = true
L["Inverted Modifier"] = true
L["Whether to invert what happens when a key is pressed or not, i.e. show and hide."] = true
L["Greetings"] = true
L["Whether the greetings message should be shown or not"] = true


-- UnitTooltip
L["Unit Name"] = true
L["Target"] = true
L["Target:"] = true
L["Guild"] = true
L["Guild:"] = true
L["Rank"] = true
L["Rank:"] = true
L["Realm"] = true
L["Realm:"] = true
L["Level"] = true
L["Level:"] = true
L["Gender"] = true
L["Gender:"] = true
L["Male"] = true
L["Female"] = true
L["Race"] = true
L["Race:"] = true
L["Class"] = true
L["Class:"] = true
L["Druid Form"] = true
L["Form:"] = true
L["Faction"] = true
L["Faction:"] = true
L["Status"] = true
L["Status:"] = true
L["Offline"] = true
L["Divine Intervention"] = true
L["Feigned Death"] = true
L["Ghost"] = true
L["Soulstoned"] = true
L["Dead"] = true
L["Alive"] = true
L["Health"] = true
L["Health:"] = true
L["Unknown"] = true
L["Mana"] = true
L["Unknown"] = true
L["Effects"] = true
L["Effects:"] = true
L["Banished"] = true
L["Charmed"] = true
L["Confused"] = true
L["Disoriented"] = true
L["Feared"] = true
L["Frozen"] = true
L["Horrified"] = true
L["Incapacitated"] = true
L["Polymorphed"] = true
L["Sapped"] = true
L["Shackled"] = true
L["Asleep"] = true
L["Stunned"] = true
L["Turned"] = true
L["Disarmed"] = true
L["Pacified"] = true
L["Rooted"] = true
L["Silenced"] = true
L["Ensnared"] = true
L["Enraged"] = true
L["Wounded"] = true
L["Has Control"] = true
L["Marquee"] = true
L["Memory Usage"] = true
L['Memory Usage:'] = true
L["CPU Usage"] = true
L["Note that you must turn on CPU profiling"] = true
L["CPU Usage:"] = true
L["Talents"] = true
L['Talents:'] = true
L["Current Role"] = true
L["Old Role"] = true
L["Avg Item Level"] = true
L["Zone"] = true
L["Zone:"] = true
L["Location"] = true
L["Location:"] = true
L["Range"] = true
L["Target is over %d yards"] = true
L["Between %s and %s yards"] = true
L["Movement"] = true
L["Pitch: %.1f"] = true
L["Speed: %.1f"] = true
L["Guild Note"] = true
L["Guild Note:"] = true
L["Main"] = true
L["Main:"] = true
L["Spell Cast"] = true
L["Channeling:"] = true
L["Casting:"] = true
L["Fails"] = true
L["Fails: %d"] = true
L["Threat"] = true
-- UnitTooltip options
L["Add Line"] = true
L["Give the line a name"] = true
L["Refresh Rate"] = true
L["The rate at which the tooltip will be refreshed"] = true
L["Default Color"] = true
L["The default color for tooltip lines"] = true
L["Restore Defaults"] = true
L["Roll back to defaults."] = true
L["Enabled"] = true
L["Whether to show this line or not"] = true
L["Left Updating"] = true
L["Whether this line's left segment refreshes"] = true
L["Right Updating"] = true
L["Whether this line's right segment refreshes"] = true
L["Move Up"] = true
L["Move this line up by one"] = true
L["Move Down"] = true
L["Move this line down by one"] = true
L["Left Outlined"] = true
L["Whether the left widget is outlined or not"] = true
L["None"] = true 
L["Outlined"] = true 
L["Thick Outlilned"] = true
L["Right Outlined"] = true
L["Whether the right widget is outlined or not"] = true
L["Word Wrap"] = true
L["Whether this line should word wrap lengthy text"] = true
L["Delete"] = true
L["Delete this line"] = true
L["Lines"] = true
L["Left Segment"] = true
L["Enter code for this line's left segment."] = true
L["Right Segment"] = true
L["Enter code for this line's right segment."] = true
L["Marquee Settings"] = true
L["Note that only the left line script is used for marquee text"] = true
L["Prefix"] = true
L["The prefix for this marquee"] = true
L["Postfix"] = true
L["The postfix for this marquee"] = true
L["Alignment"] = true
L["The alignment information"] = true
L["Text Update"] = true
L["How often to update the text. A value of zero means the text won't repeatedly update."] = true
L["Scroll Speed"] = true
L["How fast to scroll the marquee."] = true
L["Direction"] = true
L["Which direction to scroll."] = true
L["Columns"] = true
L["How wide the marquee is. If your text is cut short then increase this value."] = true
L["Don't right trim"] = true
L["Prevent trimming white space to the right of text"] = true
L["Feats"] = true
L["Feats:"] = true
L["Loading Achievements..."] = true
L["PVP Rank"] = true
L["PVP Rank:"] = true
L["Alliance"] = true
L["Horde"] = true
L["Arena 2s"] = true
L["Arena 3s"] = true
L["Arena 5s"] = true

-- Mouse Gestures
L["Left Button"] = true
L["Right Button"] = true
L["Center Button"] = true
L["Up"] = true
L["Down"] = true
L["Add Gesture"] = true
L["Add a gesture"] = true
L["Restore Defaults"] = true
L["Restore Defaults"] = true
L["You'll need to reload your UI. Type /reload"] = true
L["Delete"] = true
L["Delete this widget"] = true


-- Appearance
L["Scale Slider"] = true
L["Adjust tooltip scale"] = true
L["Tooltip Font"] = true
L["Set the tooltip's font"] = true
L["Normal font size"] = true
L["Set the normal font size"] = true
L["Bold font size"] = true
L["Set the bold font size"] = true
L["Tooltip Border"] = true
L["Set the tooltip's border style"] = true
L["Tooltip Background"] = true
L["Set the tooltip's background style"] = true
L["Tooltip Top Padding"] = true
L["Set the tooltip's top side padding"] = true
L["Tooltip Bottom Padding"] = true
L["Set the tooltip's bottom side padding"] = true
L["Tooltip Left Padding"] = true
L["Set the tooltip's left side padding"] = true
L["Tooltip Right Padding"] = true
L["Set the tooltip's right side padding"] = true
L["Tooltip Edge Size"] = true
L["Set the tooltip's edge size"] = true
L["Clamp Left"] = true
L["Clamp Right"] = true
L["Clamp Top"] = true
L["Clamp Bottom"] = true
L["Background Color"] = true
L["Set options for background color"] = true
L["Guild and friends"] = true
L["Background color for your guildmates and friends."] = true
L["Hostile players"] = true
L["Background color for hostile players."] = true
L["Hostile non-player characters"] = true
L["Background color for hostile non-player characters."] = true
L["Neutral non-player characters"] = true
L["Background color for neutral non-player characters."] = true
L["Friendly players"] = true
L["Background color for friendly players."] = true
L["Friendly non-player characters"] = true
L["Background color for friendly non-player characters."] = true
L["Dead"] = true
L["Background color for dead units."] = true
L["Tapped"] = true
L["Background color for when a unit is tapped by another."] = true
L["Other Tooltips"] = true
L["Background color for other tooltips."] = true

-- Bars
L["Add Bar"] = true
L["Add a bar"] = true
L["Delete"] = true
L["Enabled"] = true
L["Whether the bar is enabled or not"] = true
L["Texture #1"] = true
L["This bar's texture"] = true
L["Texture #2"] = true
L["This bar's texture"] = true

-- Borders
L["Add Border"] = true
L["Add a border"] = true

-- Fade
L["World Units"] = true
L["What to do with tooltips for world frames"] = true
L["Unit Frames"] = true
L["What to do with tooltips for unit frames"] = true
L["Other Frames"] = true
L["What to do with tooltips for other frames (spells, macros, items, etc..)"] = true
L["World Objects"] = true
L["What to do with tooltips for world objects (mailboxes, portals, etc..)"] = true


-- Histograms
L["Add Histogram"] = true
L["Add a histogram"] = true
L["Restore Defaults"] = true
L["Restore Defaults"] = true
L["Toggle whether this histogram is enabled or not."] = true

-- Portrait
L["Size"] = true
L["The square portrait's width and height"] = true
L["3d Model"] = true
L["Whether to show the portrait as a 3d model (toggled true) or a 2d model (toggled false)"] = true

-- Position
L["World Units"] = true
L["Where to anchor the tooltip when mousing over world characters"] = true
L["X-axis offset: %d-%d"] = true
L["The x-axis offset used to position the tooltip in relationship to the anchor point"] = true
L["Y-axis offset: %d-%d"] = true
L["The y-axis offset used to position the tooltip in relationship to the anchor point"] = true
L["In Combat"] = true
L["Where to anchor the world unit tooltip while in combat"] = true
L["X-axis offset: %d-%d"] = true
L["The x-axis offset used to position the tooltip in relationship to the anchor point"] = true
L["Y-axis offset: %d-%d"] = true
L["The y-axis offset used to position the tooltip in relationship to the anchor point"] = true
L["Unit Frames"] = true
L["Where to anchor the tooltip when mousing over a unit frame"] = true
L["X-axis offset: %d-%d"] = true
L["The x-axis offset used to position the tooltip in relationship to the anchor point"] = true
L["Y-axis offset: %d-%d"] = true
L["The y-axis offset used to position the tooltip in relationship to the anchor point"] = true
L["Other tooltips"] = true
L["Where to anchor most other tooltips"] = true
L["X-axis offset: %d-%d"] = true
L["The x-axis offset used to position the tooltip in relationship to the anchor point"] = true
L["Y-axis offset: %d-%d"] = true
L["The y-axis offset used to position the tooltip in relationship to the anchor point"] = true

-- Texts
L["Whether the histogram is enabled or not"] = true
L["Add Text"] = true
L["Add a text widget"] = true
L["Restore Defaults"] = true
L["Restore Defaults"] = true

-- PVP icon
L["PvP Icon"] = true
L["Add Point"] = true
L["Add a new point"] = true
L["Icon Point"] = true
L["Which point of the PvP icon is attached at the relative point."] = true
L["Relative Point"] = true
L["Which point of StarTip's tooltip should the PvP icon be attached."] = true
L["X Offset"] = true
L["X axis offset from attached point."] = true
L["Y Offset"] = true
L["Y axis offset from attached point."]  = true
L["Delete"] = true
L["Delete this point"] = true



































