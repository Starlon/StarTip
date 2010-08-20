

local ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_MARQUEE, ALIGN_AUTOMATIC, ALIGN_PINGPONG = 1, 2, 3, 4, 5, 6
local SCROLL_RIGHT, SCROLL_LEFT = 1, 2

local foo = 500

StarTip.config = {
    ["display_startip"] = {
		["driver"] = "qtip",
		["layers"] = 3,
		["background"] = "d9ccf16f",
		["rows"] = 6,
		["cols"] = 30,
		["layout-timeout"] = 0,
		["update"] = 25,
		["widget0"] = "widget_key_up",
		["widget1"] = "widget_key_down",
		["transition-speed"] = 50,
		["refresh-rate"] = 25,
		["layout0"] = "layout_startip"
    },
	["layout_blank"] = {
		["keyless"] = 1,
		["layout-timeout"] = 0
    },
	["layout_startip"] = {
		["row1"] = {
    		["col1"] = "widget_name_label",
    		["col10"] = "widget_name"
        }, 
		["row2"] = {
    		["col1"] = "widget_class_label", 
    		["col10"] = "widget_class"
        }, 
		["row3"] = {
			["col1"] = "widget_race_label",
			["col10"] = "widget_race",
		},
		["row4"] = {
			["col1"] = "widget_level_label",
			["col10"] = "widget_level",
		},
		["row5"] = {
			["col1"] = "widget_mem_label",
			["col10"] = "widget_mem"
		},
		["row6"] = {
			["col1"] = "widget_cpu_label",
			["col10"] = "widget_cpu"
		},
		["transition"] = "U"
    }, 
	["widget_name_label"] = {
		type = "text",
		value = 'return "Name:"',
		prefix = '',
		postfix = '',
		precision = 0xbabe,
		align = ALIGN_RIGHT,
		cols = 9,
		color = "return 0xffffffff"
	},
	["widget_name"] = {
		type = "text",
		value = "return UnitName('player')",
		cols = 40,
		align = ALIGN_MARQUEE,
		update = 100000,
		speed = 300,
		direction = SCROLL_LEFT,
		dontRtrim = true
	},
	["widget_class_label"] = {
		type = "text",
		value = 'return "Class:"',
		cols = 9,
		align = ALIGN_RIGHT
	},
	["widget_class"] = {
		type = "text",
		value = "return UnitClass('player')",
		cols = 10
	},
	["widget_race_label"] = {
		type = "text",
		value = 'return "Race:"',
		cols = 9,
		align = ALIGN_RIGHT
	},
	["widget_race"] = {
		type = "text",
		value = "return UnitRace('player')",
		cols = 10
	},
	["widget_level_label"] = {
		type = "text",
		value = 'return "Level:"',
		cols = 9,
		align = ALIGN_RIGHT,
	},
	["widget_level"] = {
		type = "text",
		value = "return UnitLevel('player')",
		cols = 10
	},
	["widget_mem_label"] = {
		type = "text",
		value = "return 'Memory:'",
		cols = 9,
		align = ALIGN_RIGHT
	},
	["widget_mem"] = {
		type = "text",
		value = [[
mem, percent, memdiff, totalMem, totaldiff = GetMemUsage("StarTip")
if mem then
	if totaldiff == 0 then totaldiff = 1 end
    self.memperc = memdiff / totaldiff * 100
    return memshort(tonumber(format("%.2f", mem))) .. " (" .. format("%.2f", self.memperc) .. "%)"
end]],
		cols = 20,
		update = 1000,
		dontRtrim = true
	},
	["widget_cpu_label"] = {
		type = "text",
		value = "return 'CPU:'",
		cols = 9,
		align = ALIGN_RIGHT
	},
	["widget_cpu"] = {
		type = "text",
		value = [[
cpu, percent, cpudiff, totalCPU, totaldiff = GetCPUUsage("StarTip")
if cpu then
    if totaldiff == 0 then totaldiff = 1 end
    self.cpuperc = cpudiff / totaldiff * 100
    return timeshort(cpu) .. " (" .. format("%.2f", self.cpuperc)  .. "%)"
end
]],
		cols = 20,
		update = 1000,
		dontRtrim = true
	},
	["widget_icon_blob"] = {
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
		["speed"] = "return foo", 
		["type"] = "icon"
    }, 
	["widget_icon_ekg"] = {
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
		["speed"] = "return foo", 
		["type"] = "icon"
    }, 
	["widget_icon_heart"] = {
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
		["speed"] = "return foo", 
		["type"] = "icon"
    }, 
	["widget_icon_heartbeat"] = {
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
		["speed"] = "return foo", 
		["type"] = "icon"
    }, 
	["widget_icon_karo"] = {
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
		["speed"] = "return foo", 
		["type"] = "icon"
    }, 
	["widget_icon_rain"] = {
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
		["speed"] = "return foo", 
		["type"] = "icon"
    }, 
	["widget_icon_squirrel"] = {
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
		["speed"] = "return foo", 
		["type"] = "icon"
    }, 
	["widget_icon_timer"] = {
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
		["speed"] = "return foo", 
		["type"] = "icon"
    }, 
	["widget_icon_wave"] = {
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
		["speed"] = "return foo", 
		["type"] = "icon"
    }, 
	["widget_key_down"] = {
		["expression"] = "lcd.Transition(-1)", 
		["key"] = 2, 
		["type"] = "key"
    }, 
	["widget_key_up"] = {
		["expression"] = "lcd.Transition(1)", 
		["key"] = 1, 
		["type"] = "key"
    }, 
	["widget_percent"] = {
		["expression"] = "'%'", 
		["type"] = "text"
    } 
}