{
    "variables": {
        "foo": 100
    },
    /*"display_cfa631": {
        "driver": "crystalfontz",
        "backlight": 100, 
        "contrast": 50, 
        "layout": "layout_bar", 
        "model": "632", 
        "port": "/dev/ttyUSB0", 
        "baud": 19200,
        "rows": 2,
        "cols": 20
    }, 
    "display_cfa634": {
        "driver": "crystalfontz",
        "backlight": 100, 
        "contrast": 50, 
        "layout": "layout_icons", 
        "model": "634", 
        "port": "/dev/ttyUSB1", 
        "baud": 19200,
        "rows": 4,
        "cols": 20
    }, */ 
    "display_cfa1": {
        //"driver": "crystalfontz",
        //"driver": "qt",
        "backlight": 100, 
        "contrast": 50, 
        "layout0": "layout_bar", 
        "layout1": "layout_1", 
        "layout2": "layout_karo", 
        "layout3": "layout_bignums", 
        "layout4": "layout_american_flag", 
        "layout5": "layout_intel", 
        "layout6": "layout_marquee1", 
        "layout7": "layout_dolby", 
        "layout8": "layout_bolt",
        "model": "533", 
        "port": "/dev/ttyUSB0", 
        "baud": 19200, 
        "widget0": "widget_key_up", 
        "widget1": "widget_key_down"
    },
    "display_xmms2_pcm": {
        //"driver": "qt",
        //"gif-file": "xmms2_pcm.gif",
        "rows": 2,
        "cols": 4,
        "layout0": "layout_xmms2_pcm_24x16", 
        "layout-timeout": 0
    }, 
    "display_xmms2_peak": {
        //"driver": "qt",
        //"gif-file": "xmms2_peak.gif",
        "rows": 4,
        "cols": 20,
        "layout0": "layout_xmms2_peak",
        "layout-timeout": 0
    },
    "display_xmms2_spectrum": {
        //"driver": "qt",
        //"gif-file": "xmms2_spectrum.gif",
        "rows": 4,
        "cols": 20,
        "layout0": "layout_xmms2_spectrum",
        "layout-timeout": 0
    },
    "display_cfa634": {
        //"driver": "crystalfontz",
        "backlight": 100,
        "contrast": 60,
        "layout-timeout": 0,
        "layout0": "layout_visualization",
        "layout1": "layout_bar",
        "layout2": "layout_icons",
        "layout3": "layout_bignums",
        "layout4": "layout_american_flag",
        "layout5": "layout_intel",
        "layout6": "layout_marquee1",
        "layout7": "layout_dolby",
        "layout8": "layout_bolt",
        "model": "635+",
        "port": "/dev/ttyUSB2",
        "speed": 115200,
        "widget0": "widget_key_up",
        "widget1": "widget_key_down"
    },
    "display_pertelian": {
        //"driver": "pertelian",
        "backlight": 1, 
        "layout0": "layout_icons",
        "layout1": "layout_1",
        "layout2": "layout_karo",
        "layout3": "layout_bignums",
        "layout4": "layout_american_flag",
        "layout5": "layout_intel",
        "layout6": "layout_marquee1",
        "layout7": "layout_dolby",
        "layout8": "layout_bolt",
        "port": "/dev/ttyUSB3"
    }, 
    "display_qt_graphic_test": {
        //"driver": "qtgraphic",
        //"layout0": "layout_full_256x64", 
        //"layout0": "layout_xmms2_pcm_256x64",
        "layout0": "layout_bignums",
        //"gif-file": "graphic_test.gif",
        "background": "ffffff6f",
        "layout-timeout": 0,
        "transition-speed": 50,
        "rows": 64,
        "cols": 256,
        "pixels": "2x2",
        "widget0": "widget_key_up",
        "widget1": "widget_key_down"
    },
    "display_pico_graphic": {
        //"driver": "picographic", 
        //"gif-file": "qtgraphic.gif",
        "layout-timeout": 20000,
        "layout1": "layout_xmms2_pcm_256x64", 
        "layout0": "layout_full_256x64",
        "transition-speed": 50,
        "rows": 64,
        "cols": 256
    }, 
    "display_nifty_out": {
        //"driver": "qtgraphic",
        //"gif-file": "nifty3.gif",
        "background": "ffffff6f",
        "cols": 256,
        "rows": 64,
        "pixels": "2x2",
        "layout-timeout": 0,
        "widget0": "widget_key_up",
        "widget1": "widget_key_down",
        "transition-speed": 50,
        "layout0": "layout_full_256x64"
    },
    "display_nifty_in": {
        //"driver": "nifty",
        "layout0": "layout_histogram_large",
        "layout-timeout": 0,
        "update": 100,
        "background": "ffffff6f",
        "layers": 3,
        "update": 25,
        "port": 8766
    },
    "display_sdl": {
        "driver": "sdl",
        //"gif-file": "smooth_lcd.gif",
        "gif-speed": 50,
        "pixels": "2x2",
        "layers": 3,
        "background": "d9ccf16f",
        "fill": 1,
        "rows": 64,
        "cols": 256,
        "layout-timeout": 0,
        "update": 25,
        "widget0": "widget_key_up",
        "widget1": "widget_key_down",
        "transition-speed": 50,
        "refresh-rate": 25,
        "layout0": "layout_full_256x64"
    },
    "layout_histogram_large": {
        "layer2": {
            "row1": {
                //"col1": "widget_nifty2"
            }
        },
        "row1": {
            "col1": "widget_xmms2_pcm_256x64"
        },
        "transition": "A"
    },
    "layout_full_256x64": {
        "layer2": {
            "row1": {
                "col1": "widget_histogram_large"
            }
        },
        "layer3": {
            "row1": {
                "col1": "widget_xmms2_pcm_256x64"
            }
        },
        "row1": {
            "col1": "widget_CPULabel",
            "col6": "widget_CPU",
            "col11": "widget_CPUBar",
            "col21": "widget_RAMLabel",
            "col26": "widget_RAMFree",
            "col31": "widget_RAMTotal"
        },
        "row2": {
            "col1": "widget_IDELabel",
            "col6": "widget_IDEIn",
            "col17": "widget_IDEOut",
            "col28": "widget_IDEBar"
        },
        "row3": {
            "col1": "widget_FSSpace"
        },
        "row4": {
            "col1": "widget_WLANLabel",
            "col6": "widget_WLANIn",
            "col17": "widget_WLANOut",
            "col28": "widget_WLANBar"
        },
        "row6": {
            "col1": "widget_icon_heartbeat",
            "col2": "widget_icon_ekg",
            "col3": "widget_icon_heart",
            "col4": "widget_icon_blob",
            "col5": "widget_icon_wave",
            "col6": "widget_icon_timer",
            "col7": "widget_icon_rain",
            "col8": "widget_icon_karo",
            "col9": "widget_icon_heartbeat",
            "col10": "widget_icon_ekg",
            "col11": "widget_icon_heart",
            "col12": "widget_icon_blob",
            "col13": "widget_icon_wave",
            "col14": "widget_icon_timer",
            "col15": "widget_icon_rain",
            "col16": "widget_icon_karo",
            "col17": "widget_icon_heartbeat",
            "col18": "widget_icon_ekg",
            "col19": "widget_icon_heart",
            "col20": "widget_icon_blob",
            "col21": "widget_icon_wave",
            "col22": "widget_icon_timer",
            "col23": "widget_icon_rain",
            "col24": "widget_icon_karo",
            "col25": "widget_icon_heartbeat",
            "col26": "widget_icon_ekg",
            "col27": "widget_icon_heart",
            "col28": "widget_icon_blob",
            "col29": "widget_icon_wave",
            "col30": "widget_icon_timer",
            "col31": "widget_icon_rain",
            "col32": "widget_icon_karo",
            "col33": "widget_icon_heartbeat",
            "col34": "widget_icon_ekg",
            "col35": "widget_icon_heart",
            "col36": "widget_icon_blob",
            "col37": "widget_icon_blob",
            "col38": "widget_icon_wave",
            "col39": "widget_icon_timer",
            "col40": "widget_icon_rain",
            "col41": "widget_icon_karo",
            "col42": "widget_icon_heartbeat"
            
        },
        "row7": {
            "col1": "widget_Time",
            "col22": "widget_UptimeLabel",
            "col30": "widget_Uptime"
        },
        "row8": {
            "col1": "widget_bottom_ticker"
        },
        "transition": "T"
    },
    "layout_blank": {
        "keyless": 1,
        "layout-timeout": 0
    },
    "layout_xmms2_pcm_256x64": {
        "row1": {
            "col1": "widget_xmms2_pcm_256x64"
        },
        "transition": "A"
    },
    "layout_xmms2_pcm_24x16": {
        "row1": {
            "col1": "widget_xmms2_pcm_24x16"
        }
    },
    "layout_xmms2_peak": {
        "row1": {
            "col1": "widget_xmms2_peak"
        }
    },
    "layout_xmms2_spectrum": {
        "row1": {
            "col1": "widget_xmms2_spectrum"
        },
        "transition": "U"
    },
    "layout_1": {
        "row1": {
            "col1": "widget_cpu_label",
            //"col11": "widget_cpu_histogram",
            "col6": "widget_cpu"
        }, 
        "row2": {
            "col1": "widget_wlan0_label", 
            //"col11": "widget_wlan0_histogram",
            "col7": "widget_wlan0"
        }, 
        "row3": {
        }, 
        "row4": {
            "col1": "widget_bottom_ticker"
        }, 
        "transition": "U"
    }, 
    "layout_visualization": {
        "row1": {
            "col1": "widget_xmms2_pcm_24x16",
            "col17": "widget_xmms2_pcm_24x16",
            "col9": "widget_xmms2_pcm_24x16"
        },
        "row3": {
            "col13": "widget_xmms2_pcm_24x16",
            "col5": "widget_xmms2_pcm_24x16"
        }
    },
    "layout_american_flag": {
        "row1": {
            "col1": "widget_gif_american_flag",
            "col17": "widget_gif_american_flag", 
            "col9": "widget_gif_american_flag"
        }, 
        "row3": {
            "col13": "widget_gif_american_flag", 
            "col5": "widget_gif_american_flag"
        },
        "transition": "L"
    }, 
    "layout_bar": {
        "row1": {
            "col1": "widget_ram_label",
            "col10": "widget_ram_total", 
            "col5": "widget_ram_active"
        }, 
        "row2": {
            "col1": "widget_wlan0_label", 
            "col10": "widget_wlan0_bar", 
            "col7": "widget_wlan0"
        }, 
        "row3": {
            "col1": "widget_icon_wave", 
            "col10": "widget_icon_ekg", 
            "col11": "widget_icon_rain", 
            "col12": "widget_icon_blob", 
            "col13": "widget_icon_wave", 
            "col14": "widget_icon_ekg", 
            "col15": "widget_icon_rain", 
            "col16": "widget_icon_blob", 
            "col17": "widget_icon_wave", 
            "col18": "widget_icon_ekg", 
            "col19": "widget_icon_rain", 
            "col2": "widget_icon_ekg", 
            "col20": "widget_icon_blob", 
            "col3": "widget_icon_rain", 
            "col4": "widget_icon_blob", 
            "col5": "widget_icon_wave", 
            "col6": "widget_icon_ekg", 
            "col7": "widget_icon_rain", 
            "col8": "widget_icon_blob", 
            "col9": "widget_icon_wave"
        }, 
        "row4": {
            "col1": "widget_bottom_ticker"
        }, 
        "transition": "B"
    }, 
    "layout_bignums": {
        "row2": {
            "col1": "widget_cpu_label", 
            "col10": "widget_bignums"
        }, 
        "row3": {
            "col14": "widget_percent"
        },
        "transition": "B"
    }, 
    "layout_bolt": {
        "row1": {
            "col1": "widget_gif_bolt", 
            "col17": "widget_gif_bolt", 
            "col9": "widget_gif_bolt"
        }, 
        "row3": {
            "col13": "widget_gif_bolt", 
            "col5": "widget_gif_bolt"
        },
        "transition": "B"
    }, 
    "layout_dolby": {
        "row1": {
            "col1": "widget_gif_dolby", 
            "col17": "widget_gif_dolby", 
            "col9": "widget_gif_dolby"
        }, 
        "row3": {
            "col13": "widget_gif_dolby", 
            "col5": "widget_gif_dolby"
        },
        "transition": "B"
    }, 
    "layout_icons": {
        "row1": {
            "col1": "widget_icon_heartbeat", 
            "col10": "widget_icon_ekg", 
            "col11": "widget_icon_heart", 
            "col12": "widget_icon_blob", 
            "col13": "widget_icon_wave", 
            "col14": "widget_icon_timer", 
            "col15": "widget_icon_rain", 
            "col16": "widget_icon_karo", 
            "col17": "widget_icon_heartbeat", 
            "col18": "widget_icon_ekg", 
            "col19": "widget_icon_heart", 
            "col2": "widget_icon_ekg", 
            "col20": "widget_icon_blob", 
            "col3": "widget_icon_heart", 
            "col4": "widget_icon_blob", 
            "col5": "widget_icon_wave", 
            "col6": "widget_icon_timer", 
            "col7": "widget_icon_rain", 
            "col8": "widget_icon_karo", 
            "col9": "widget_icon_heartbeat"
        }, 
        "row2": {
            "col1": "widget_icon_wave", 
            "col10": "widget_icon_timer", 
            "col11": "widget_icon_rain", 
            "col12": "widget_icon_karo", 
            "col13": "widget_icon_heartbeat", 
            "col14": "widget_icon_ekg", 
            "col15": "widget_icon_heart", 
            "col16": "widget_icon_blob", 
            "col17": "widget_icon_wave", 
            "col18": "widget_icon_timer", 
            "col19": "widget_icon_rain", 
            "col2": "widget_icon_timer", 
            "col20": "widget_icon_karo", 
            "col3": "widget_icon_rain", 
            "col4": "widget_icon_karo", 
            "col5": "widget_icon_heartbeat", 
            "col6": "widget_icon_ekg", 
            "col7": "widget_icon_heart", 
            "col8": "widget_icon_blob", 
            "col9": "widget_icon_wave"
        }, 
        "row3": {
            "col1": "widget_icon_heartbeat", 
            "col10": "widget_icon_ekg", 
            "col11": "widget_icon_heart", 
            "col12": "widget_icon_blob", 
            "col13": "widget_icon_wave", 
            "col14": "widget_icon_timer", 
            "col15": "widget_icon_rain", 
            "col16": "widget_icon_karo", 
            "col17": "widget_icon_heartbeat", 
            "col18": "widget_icon_ekg", 
            "col19": "widget_icon_heart", 
            "col2": "widget_icon_ekg", 
            "col20": "widget_icon_blob", 
            "col3": "widget_icon_heart", 
            "col4": "widget_icon_blob", 
            "col5": "widget_icon_wave", 
            "col6": "widget_icon_timer", 
            "col7": "widget_icon_rain", 
            "col8": "widget_icon_karo", 
            "col9": "widget_icon_heartbeat"
        }, 
        "row4": {
            "col1": "widget_icon_wave", 
            "col10": "widget_icon_timer", 
            "col11": "widget_icon_rain", 
            "col12": "widget_icon_karo", 
            "col13": "widget_icon_heartbeat", 
            "col14": "widget_icon_ekg", 
            "col15": "widget_icon_heart", 
            "col16": "widget_icon_blob", 
            "col17": "widget_icon_wave", 
            "col18": "widget_icon_timer", 
            "col19": "widget_icon_rain", 
            "col2": "widget_icon_timer", 
            "col20": "widget_icon_karo", 
            "col3": "widget_icon_rain", 
            "col4": "widget_icon_karo", 
            "col5": "widget_icon_heartbeat", 
            "col6": "widget_icon_ekg", 
            "col7": "widget_icon_heart", 
            "col8": "widget_icon_blob", 
            "col9": "widget_icon_wave"
        }, 
        "transition": "B"
    }, 
    "layout_intel": {
        "row1": {
            "col1": "widget_gif_intel", 
            "col17": "widget_gif_intel", 
            "col9": "widget_gif_intel"
        }, 
        "row3": {
            "col13": "widget_gif_intel", 
            "col5": "widget_gif_intel"
        },
        "transition": "B"
    }, 
    "layout_karo": {
        "row1": {
            "col1": "widget_icon_karo", 
            "col10": "widget_icon_karo", 
            "col11": "widget_icon_karo", 
            "col12": "widget_icon_karo", 
            "col13": "widget_icon_karo", 
            "col14": "widget_icon_karo", 
            "col15": "widget_icon_karo", 
            "col16": "widget_icon_karo", 
            "col17": "widget_icon_karo", 
            "col18": "widget_icon_karo", 
            "col19": "widget_icon_karo", 
            "col2": "widget_icon_karo", 
            "col20": "widget_icon_karo", 
            "col3": "widget_icon_karo", 
            "col4": "widget_icon_karo", 
            "col5": "widget_icon_karo", 
            "col6": "widget_icon_karo", 
            "col7": "widget_icon_karo", 
            "col8": "widget_icon_karo", 
            "col9": "widget_icon_karo"
        }, 
        "row2": {
            "col1": "widget_icon_karo", 
            "col10": "widget_icon_karo", 
            "col11": "widget_icon_karo", 
            "col12": "widget_icon_karo", 
            "col13": "widget_icon_karo", 
            "col14": "widget_icon_karo", 
            "col15": "widget_icon_karo", 
            "col16": "widget_icon_karo", 
            "col17": "widget_icon_karo", 
            "col18": "widget_icon_karo", 
            "col19": "widget_icon_karo", 
            "col2": "widget_icon_karo", 
            "col20": "widget_icon_karo", 
            "col3": "widget_icon_karo", 
            "col4": "widget_icon_karo", 
            "col5": "widget_icon_karo", 
            "col6": "widget_icon_karo", 
            "col7": "widget_icon_karo", 
            "col8": "widget_icon_karo", 
            "col9": "widget_icon_karo"
        }, 
        "row3": {
            "col1": "widget_icon_karo", 
            "col10": "widget_icon_karo", 
            "col11": "widget_icon_karo", 
            "col12": "widget_icon_karo", 
            "col13": "widget_icon_karo", 
            "col14": "widget_icon_karo", 
            "col15": "widget_icon_karo", 
            "col16": "widget_icon_karo", 
            "col17": "widget_icon_karo", 
            "col18": "widget_icon_karo", 
            "col19": "widget_icon_karo", 
            "col2": "widget_icon_karo", 
            "col20": "widget_icon_karo", 
            "col3": "widget_icon_karo", 
            "col4": "widget_icon_karo", 
            "col5": "widget_icon_karo", 
            "col6": "widget_icon_karo", 
            "col7": "widget_icon_karo", 
            "col8": "widget_icon_karo", 
            "col9": "widget_icon_karo"
        }, 
        "row4": {
            "col1": "widget_icon_karo", 
            "col10": "widget_icon_karo", 
            "col11": "widget_icon_karo", 
            "col12": "widget_icon_karo", 
            "col13": "widget_icon_karo", 
            "col14": "widget_icon_karo", 
            "col15": "widget_icon_karo", 
            "col16": "widget_icon_karo", 
            "col17": "widget_icon_karo", 
            "col18": "widget_icon_karo", 
            "col19": "widget_icon_karo", 
            "col2": "widget_icon_karo", 
            "col20": "widget_icon_karo", 
            "col3": "widget_icon_karo", 
            "col4": "widget_icon_karo", 
            "col5": "widget_icon_karo", 
            "col6": "widget_icon_karo", 
            "col7": "widget_icon_karo", 
            "col8": "widget_icon_karo", 
            "col9": "widget_icon_karo"
        }, 
        "transition": "B"
    }, 
    "plugins": {
        "i2c_sensors-path": "/sys/bus/i2c/devices/1-0028/"
    }, 
    "widget_nifty1": {
        "type": "nifty",
        "height": 64,
        "width": 256,
        "update": 50,
        "port": 8766
    },
    "widget_nifty2": {
        "type": "nifty",
        "height": 64,
        "width": 256,
        "update": 50,
        "port": 8766
    },
    "widget_histogram_large": {
        "type": "histogram",
        "expression": "procstat.Cpu('busy', 10)",
        "height": 8,
        "width": 43,
        "update": 10,
        "foreground": "d90cf17f"
    },
    "widget_hddtemp": {
        "type": "text",
        "expression": "'IDE Temp' + exec.Exec('hddtemp /dev/sda | cut -f 3 -d :', 999)",
        "length": 14,
        "align": "L",
        "update": 999
    },
    "widget_FSSpace": {
        "type": "text",
        "expression": "fsspace_a = ((statfs.Statfs('/', 'bavail')*statfs.Statfs('/', 'bsize'))/ 1024/ 1024);fsspace_b = ((statfs.Statfs('/media/Windows', 'bavail')*statfs.Statfs('/media/Windows', 'bsize'))/1024/1024);c = '/ ' + fsspace_a + 'MB /media/disk/ ' + fsspace_b + ' MB';
        ",
        "length": 42,
        "align": "M",
        "speed": 30
    },
    "widget_CPU": {
        "type": "text",
        "expression": "procstat.Cpu('busy', 500)",
        "postfix": "'% '",
        "length": 5,
        "precision": 1,
        "align": "R",
        "update": 50
    },
    "widget_CPUBar": {
        "type": "bar",
        "expression": "procstat.Cpu('busy', 500)",
        "expression2": "procstat.Cpu('system', 500)",
        "length": 10,
        "min": "1",
        "max": "100",
        "direction": "E",
        "style": "H",
        "update": 50
    },
    "widget_CPULabel": {
        "type": "text",
        "expression": "'CPU:'",
        "length": 4,
        "align": "L",
        "bold": 1
    },
    "widget_RAMTotal": {
        "type": "text",
        "expression": "meminfo.Meminfo('MemTotal')/1024",
        "postfix": "'MB FREE'",
        "length": 11,
        "precision": 0,
        "align": "L",
        "update": 50
    },
    "widget_RAMFree": {
        "type": "text",
        "expression": "meminfo.Meminfo('MemFree')/1024",
        "postfix": "'/'",
        "length": 5,
        "precision": 0,
        "align": "R",
        "update": 50
    },
    "widget_RAMLabel": {
        "type": "text",
        "expression": "'RAM:'",
        "length": 4,
        "align": "L",
        "bold": 1
    },
    "widget_IDEIn": {
        "type": "text",
        "expression": "diskstats.Diskstats('sd.', 'read_sectors', 500)/2048",
        "prefix": "'In '",
        "postfix": "'MB'",
        "precision": 2,
        "align": "R",
        "length": 10,
        "update": 500
    },
    "widget_IDEOut": {
        "type": "text",
        "expression": "diskstats.Diskstats('sd.', 'write_sectors', 500)/2048",
        "prefix": "'Out'",
        "postfix": "'MB'",
        "precision": 2,
        "align": "R",
        "length": 10,
        "update": 500
    },
    "widget_IDEBar": {
        "type": "bar",
        "expression": "diskstats.Diskstats('sda', 'read_sectors', 500)",
        "expression2": "diskstats.Diskstats('sda', 'write_sectors', 500)",
        "length": 14,
        "direction": "E",
        "style": "H",
        "update": 500
    },
    "widget_IDELabel": {
        "type": "text",
        "expression": "'IDE:'",
        "length": 4,
        "align": "L",
        "bold": 1
    },
    "widget_WLANLabel": {
        "type": "text",
        "expression": "'WLAN:'",
        "length": 5,
        "align": "L",
        "bold": 1
    },
    "widget_WLANIn": {
        "type": "text",
        "expression": "netdev.Fast('wlan0', 'Rx_bytes', 500)/1024",
        "prefix": "'OUT'",
        "postfix": "'KB'",
        "length": 9,
        "precision": 0,
        "align": "R",
        "update": 50
    },
    "widget_WLANOut": {
        "type": "text",
        "expression": "netdev.Fast('wlan0', 'Tx_bytes', 500)/1024",
        "prefix": "'IN'",
        "postfix": "'KB'",
        "length": 9,
        "precision": 0,
        "align": "R",
        "update": 50
    },
    "widget_WLANBar": {
        "type": "bar",
        "expression": "netdev.Fast('wlan0', 'Rx_bytes', 500)",
        "expression2": "netdev.Fast('wlan0', 'Tx_bytes', 500)",
        "length": 14,
        "direction": "E",
        "style": "H",
        "update": 50
    },
    "widget_TimeLabel": {
        "type": "text",
        "expression": "'TIME:'",
        "length": 5,
        "align": "L",
        "bold": 1
    },
    "widget_Time": {
        "type": "text",
        "expression": "time.Strftime('%a,%d/%m %H:%M:%S', time.Time())",
        "length": 20,
        "align": "L",
        "update": 999
    },
    "widget_UptimeLabel": {
        "type": "text",
        "expression": "'UPTIME:'",
        "length": 7,
        "align": "L",
        "bold": 1
    },
    "widget_Uptime": {
        "type": "text",
        "expression": "uptime.Uptime('%d d %H:%M:%S')",
        "length": 21,
        "align": "L",
        "update": 999
    },
    "widget_bignums": {
        "expression": "procstat.Cpu('user', 500)", 
        "type": "bignums", 
        "max": "100",
        "min": "0",
        "update": 500
    }, 
    "widget_bottom_marquee": {
        "align": "M", 
        "expression": "uname.Uname('sysname') + ' ' + uname.Uname('nodename') + ' ' + uname.Uname('release') + ' ' + cpuinfo.Cpuinfo('model name')", 
        "type": "text", 
        "speed": 100, 
        "length": 16
    }, 
    "widget_bottom_ticker": {
        "align": "P", 
        "expression": "uname.Uname('sysname') + ' ' + uname.Uname('nodename') + ' ' + uname.Uname('release') + ' ' + cpuinfo.Cpuinfo('model name')", 
        "type": "text", 
        "speed": 30,
        "bold": 1,
        "length": 42
    }, 
    "widget_cpu": {
        "align": "R", 
        "expression": "procstat.Cpu('busy', 500)", 
        "postfix": "'%'", 
        "precision": 0, 
        "type": "text", 
        "update": 500, 
        "length": 5
    }, 
    "widget_cpu_bar": {
        "direction": "W", 
        "expression": "procstat.Cpu('busy', 500)", 
        "length": 10, 
        "max": "100", 
        "min": "0", 
        "style": "H", 
        "type": "bar", 
        "update": 500
    }, 
    "widget_cpu_histogram": {
        "direction": "E", 
        "expression": "procstat.Cpu('busy', 500)", 
        "gap": 1, 
        "length": 10, 
        "max": "100", 
        "min": "0", 
        "type": "histogram", 
        "update": 500
    }, 
    "widget_cpu_label": {
        "align": "L", 
        "expression": "'CPU:'", 
        "type": "text", 
        "length": 4
    }, 
    "widget_dow": {
        "align": "L", 
        "expression": "", 
        "type": "text"
    }, 
    "widget_dow_end": {
        "align": "L", 
        "expression": "'\\200'", 
        "type": "text", 
        "length": 1
    }, 
    "widget_dow_label": {
        "align": "L", 
        "expression": "'Ambient:'", 
        "type": "text", 
        "length": 10
    }, 
    "widget_gif_american_flag": {
        "file": "gifs/American_Flag_ani.gif", 
        "type": "gif", 
        "update": "250", 
        "width": 24, 
        "xpoint": 1,
        "inverted": 1
    }, 
    "widget_gif_bolt": {
        "file": "gifs/lightning_bolt_ani.gif", 
        "type": "gif", 
        "update": "250",
        "inverted": 1
    }, 
    "widget_gif_dolby": {
        "file": "gifs/dolby_ani.gif", 
        "type": "gif", 
        "update": "250",
        "inverted": 1
    }, 
    "widget_gif_intel": {
        "file": "gifs/intel_logo_ani.gif", 
        "start": 1, 
        "end": 6, 
        "type": "gif", 
        "update": "250",
        "inverted": 1
    }, 
    "widget_gif_marquee1": {
        "file": "gifs/marquee1.gif", 
        "height": 8, 
        "type": "gif", 
        "update": "250", 
        "width": 12,
        "inverted": 1
    }, 
    "widget_gif_marquee2": {
        "file": "gifs/marquee2.gif", 
        "type": "gif", 
        "update": "250",
        "inverted": 1
    }, 
    "widget_gif_marquee3": {
        "file": "gifs/marquee3.gif", 
        "type": "gif", 
        "update": "250",
        "inverted": 1
    }, 
    "widget_gif_marquee4": {
        "file": "gifs/marquee4.gif", 
        "type": "gif", 
        "update": "250",
        "inverted": 1
    }, 
    "widget_icon_blob": {
        "bitmap": {
            "row1": ".....|.....|.....", 
            "row2": ".....|.....|.***.", 
            "row3": ".....|.***.|*...*", 
            "row4": "..*..|.*.*.|*...*", 
            "row5": ".....|.***.|*...*", 
            "row6": ".....|.....|.***.", 
            "row7": ".....|.....|.....", 
            "row8": ".....|.....|....."
        }, 
        "speed": "foo", 
        "type": "icon"
    }, 
    "widget_icon_ekg": {
        "bitmap": {
            "row1": ".....|.....|.....|.....|.....|.....|.....|.....", 
            "row2": ".....|....*|...*.|..*..|.*...|*....|.....|.....", 
            "row3": ".....|....*|...*.|..*..|.*...|*....|.....|.....", 
            "row4": ".....|....*|...**|..**.|.**..|**...|*....|.....", 
            "row5": ".....|....*|...**|..**.|.**..|**...|*....|.....", 
            "row6": ".....|....*|...*.|..*.*|.*.*.|*.*..|.*...|*....", 
            "row7": "*****|*****|****.|***..|**..*|*..**|..***|.****", 
            "row8": ".....|.....|.....|.....|.....|.....|.....|....."
        }, 
        "speed": "foo", 
        "type": "icon"
    }, 
    "widget_icon_heart": {
        "bitmap": {
            "row1": ".....|.....|.....|.....|.....|.....", 
            "row2": ".*.*.|.....|.*.*.|.....|.....|.....", 
            "row3": "*****|.*.*.|*****|.*.*.|.*.*.|.*.*.", 
            "row4": "*****|.***.|*****|.***.|.***.|.***.", 
            "row5": ".***.|.***.|.***.|.***.|.***.|.***.", 
            "row6": ".***.|..*..|.***.|..*..|..*..|..*..", 
            "row7": "..*..|.....|..*..|.....|.....|.....", 
            "row8": ".....|.....|.....|.....|.....|....."
        }, 
        "speed": "foo", 
        "type": "icon"
    }, 
    "widget_icon_heartbeat": {
        "bitmap": {
            "row1": ".....|.....", 
            "row2": ".*.*.|.*.*.", 
            "row3": "*****|*.*.*", 
            "row4": "*****|*...*", 
            "row5": ".***.|.*.*.", 
            "row6": ".***.|.*.*.", 
            "row7": "..*..|..*..", 
            "row8": ".....|....."
        }, 
        "speed": "foo", 
        "type": "icon"
    }, 
    "widget_icon_karo": {
        "bitmap": {
            "row1": ".....|.....|.....|.....|..*..|.....|.....|.....", 
            "row2": ".....|.....|.....|..*..|.*.*.|..*..|.....|.....", 
            "row3": ".....|.....|..*..|.*.*.|*...*|.*.*.|..*..|.....", 
            "row4": ".....|..*..|.*.*.|*...*|.....|*...*|.*.*.|..*..", 
            "row5": ".....|.....|..*..|.*.*.|*...*|.*.*.|..*..|.....", 
            "row6": ".....|.....|.....|..*..|.*.*.|..*..|.....|.....", 
            "row7": ".....|.....|.....|.....|..*..|.....|.....|.....", 
            "row8": ".....|.....|.....|.....|.....|.....|.....|....."
        }, 
        "speed": "foo", 
        "type": "icon"
    }, 
    "widget_icon_rain": {
        "bitmap": {
            "row1": "...*.|.....|.....|.*...|....*|..*..|.....|*....", 
            "row2": "*....|...*.|.....|.....|.*...|....*|..*..|.....", 
            "row3": ".....|*....|...*.|.....|.....|.*...|....*|..*..", 
            "row4": "..*..|.....|*....|...*.|.....|.....|.*...|....*", 
            "row5": "....*|..*..|.....|*....|...*.|.....|.....|.*...", 
            "row6": ".*...|....*|..*..|.....|*....|...*.|.....|.....", 
            "row7": ".....|.*...|....*|..*..|.....|*....|...*.|.....", 
            "row8": ".....|.....|.*...|....*|..*..|.....|*....|...*."
        }, 
        "speed": "foo", 
        "type": "icon"
    }, 
    "widget_icon_squirrel": {
        "bitmap": {
            "row1": ".....|.....|.....|.....|.....|.....", 
            "row2": ".....|.....|.....|.....|.....|.....", 
            "row3": ".....|.....|.....|.....|.....|.....", 
            "row4": "**...|.**..|..**.|...**|....*|.....", 
            "row5": "*****|*****|*****|*****|*****|*****", 
            "row6": "...**|..**.|.**..|**...|*....|.....", 
            "row7": ".....|.....|.....|.....|.....|.....", 
            "row8": ".....|.....|.....|.....|.....|....."
        }, 
        "speed": "foo", 
        "type": "icon"
    }, 
    "widget_icon_timer": {
        "bitmap": {
            "row1": ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|", 
            "row2": ".***.|.*+*.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.+++.|.+*+.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|", 
            "row3": "*****|**+**|**++*|**+++|**++.|**++.|**+++|**+++|**+++|**+++|**+++|+++++|+++++|++*++|++**+|++***|++**.|++**.|++***|++***|++***|++***|++***|*****|", 
            "row4": "*****|**+**|**+**|**+**|**+++|**+++|**+++|**+++|**+++|**+++|+++++|+++++|+++++|++*++|++*++|++*++|++***|++***|++***|++***|++***|++***|*****|*****|", 
            "row5": "*****|*****|*****|*****|*****|***++|***++|**+++|*++++|+++++|+++++|+++++|+++++|+++++|+++++|+++++|+++++|+++**|+++**|++***|+****|*****|*****|*****|", 
            "row6": ".***.|.***.|.***.|.***.|.***.|.***.|.**+.|.*++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.++*.|.+**.|.***.|.***.|.***.|.***.|", 
            "row7": ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|", 
            "row8": ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|"
        }, 
        "speed": "foo", 
        "type": "icon"
    }, 
    "widget_icon_wave": {
        "bitmap": {
            "row1": "..**.|.**..|**...|*....|.....|.....|.....|.....|....*|...**", 
            "row2": ".*..*|*..*.|..*..|.*...|*....|.....|.....|....*|...*.|..*..", 
            "row3": "*....|....*|...*.|..*..|.*...|*....|....*|...*.|..*..|.*...", 
            "row4": "*....|....*|...*.|..*..|.*...|*....|....*|...*.|..*..|.*...", 
            "row5": "*....|....*|...*.|..*..|.*...|*....|....*|...*.|..*..|.*...", 
            "row6": ".....|.....|....*|...*.|..*..|.*..*|*..*.|..*..|.*...|*....", 
            "row7": ".....|.....|.....|....*|...**|..**.|.**..|**...|*....|.....", 
            "row8": ".....|.....|.....|.....|.....|.....|.....|.....|.....|....."
        }, 
        "speed": "foo", 
        "type": "icon"
    }, 
    "widget_key_down": {
        "expression": "lcd.Transition(-1)", 
        "key": 2, 
        "type": "key"
    }, 
    "widget_key_up": {
        "expression": "lcd.Transition(1)", 
        "key": 1, 
        "type": "key"
    }, 
    "widget_percent": {
        "expression": "'%'", 
        "type": "text"
    }, 
    "widget_ram_active": {
        "align": "L", 
        "expression": "meminfo.Meminfo('Active')/1024", 
        "type": "text", 
        "postfix": "'/'",
        "precision": 0,
        "update": 500, 
        "length": 5
    }, 
    "widget_ram_label": {
        "align": "L", 
        "expression": "'Ram:'", 
        "type": "text", 
        "length": 4
    }, 
    "widget_ram_total": {
        "align": "L", 
        "expression": "meminfo.Meminfo('MemTotal')/1024", 
        "type": "text", 
        "precision": 0,
        "update": 500, 
        "length": 5
    }, 
    "widget_system_bar": {
        "expression": "procstat.Cpu('system', 500)", 
        "style": "H", 
        "type": "bar", 
        "width": 10
    }, 
    "widget_system_histogram": {
        "direction": "E", 
        "expressionn": "procstat.Cpu('system', 500)", 
        "gap": 1, 
        "type": "histogram", 
        "width": 10
    }, 
    "widget_system_label": {
        "align": "R", 
        "prefix": "'System: '", 
        "type": "text", 
        "length": 10
    }, 
    "widget_wlan0": {
        "align": "L", 
        "expression": "netdev.Fast('wlan0', 'Tx_bytes', 100) /1024", 
        "precision": 0, 
        "type": "text", 
        "update": 500, 
        "length": 3
    }, 
    "widget_wlan0_bar": {
        "expression":  "netdev.Fast('wlan0', 'Rx_bytes', 500) / 1024", 
        "expression2": "netdev.Fast('wlan0', 'Tx_bytes', 500) / 1024", 
        //"style": "H", 
        "type": "bar", 
        "update": 500, 
        "width": 6
    }, 
    "widget_wlan0_histogram": {
        "direction": "E", 
        "expression": 
"(netdev.Fast('wlan0', 'Rx_bytes', 500) + netdev.Fast('wlan0', 'Tx_bytes', 500)) /1024", 
        "gap": 1, 
        "type": "histogram", 
        "update": 500, 
        "width": 10
    }, 
    "widget_wlan0_label": {
        "expression": "'wlan0:'", 
        "type": "text", 
        "length": 6
    }, 
    "widget_wlan0_short_bar": {
        "expression": "(netdev.Fast('wlan0', 'Rx_bytes', 500) + netdev.Fast('wlan0', 'Tx_bytes', 500)) /1024", 
        "length": 7, 
        "style": "N", 
        "type": "bar", 
        "update": 500
    },
    "widget_635_script": {
        "file": "635_script.js",
        "type": "script"
    }
}
