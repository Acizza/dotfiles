local config = {}
local awful = require("awful")
local gears = require("gears")
local util = require("util")

config.dev_environment = false

config.home_path = os.getenv("HOME") .. "/"
config.awesome_config = gears.filesystem.get_configuration_dir()

config.theme_path = config.awesome_config .. "theme.lua"
config.wallpaper = util.random_file_in_dir(config.home_path .. "backgrounds/active/")

config.modkey = "Mod4"

config.program_shortcuts = {
    {
        modifier = { config.modkey },
        key = "Return",
        exec = "termite"
    },
    {
        modifier = { config.modkey },
        key = "backslash",
        exec = "firefox"
    },
    {
        modifier = { config.modkey },
        key = "bracketright",
        exec = "termite -e ranger"
    },
    {
        modifier = { config.modkey },
        key = "p",
        exec = "code"
    },
    {
        modifier = { config.modkey },
        key = "Next",
        exec = "gnome-system-monitor"
    },
}

config.tags = { "web", "dev", "term", "steam", "misc" }

config.clock_format = "%a %b %d, %H:%M:%S"
config.panel_opacity = 0.8

config.floating_windows = {
    class = {
        "steam",
    }
}

config.startup_programs = {
    "numlockx",
    "ibus-daemon -d",
    "sh -c 'sleep 10; exec ~/projects/rust/bcnotif/target/release/bcnotif'"
}

config.audio_source = "Master"

return config