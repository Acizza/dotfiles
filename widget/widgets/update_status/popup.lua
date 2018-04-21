local wibox = require("wibox")
local gears = require("gears")

require("widget/value_monitor")
require("widget/popup")

local os_date = os.date
local io_open = io.open

local popup = WidgetPopup:new {
    width = 325,
    height = 200,
}

local uptime_widget = ValueMonitor:new {
    label = "Uptime",
    format_value = function(time)
        return os_date("!%H:%M:%S", time)
    end,
    is_formatted_equal = function() return false end,
}

gears.timer {
    timeout = 1,
    autostart = true,
    callback = function()
        local uptime_file = io_open("/proc/uptime")
        local uptime_contents = uptime_file:read()
        uptime_file:close()

        local uptime_seconds = uptime_contents:sub(1, uptime_contents:find(' '))
        
        uptime_widget:set_value(uptime_seconds)
    end,
}

popup:setup({
    layout = wibox.layout.fixed.vertical,
    {
        layout = wibox.container.margin,
        top = 10,
        bottom = 20,
        {
            markup = "<b>System Stats</b>",
            align = "center",
            widget = wibox.widget.textbox(),
        }
    },
    {
        layout = wibox.container.margin,
        left = 25,
        uptime_widget.textbox,
    },
})

return popup