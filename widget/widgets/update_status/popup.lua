local wibox = require("wibox")
local gears = require("gears")

require("widget/value_monitor")
require("widget/popup")

local os_date = os.date
local io_open = io.open

local popup = WidgetPopup:new {
    width = 300,
    height = 200,
}

function popup:initialize()
    self.uptime_timer = gears.timer {
        timeout = 1,
        autostart = false,
        callback = function() popup:update_uptime() end,
    }
    
    self.uptime_widget = ValueMonitor:new {
        label = "Uptime",
        format_value = function(time)
            return os_date("!%H:%M:%S", time)
        end,
        is_formatted_equal = function() return false end,
    }

    self:setup({
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
            align = "center",
            widget = popup.uptime_widget.textbox,
        },
    })
end

function popup:on_open()
    self:update_uptime()
    self.uptime_timer:again()
end

function popup:on_close()
    self.uptime_timer:stop()
end

function popup:update_uptime()
    local uptime_file = io_open("/proc/uptime")
    local uptime_contents = uptime_file:read()
    uptime_file:close()

    local uptime_seconds = uptime_contents:sub(1, uptime_contents:find(' '))
    
    self.uptime_widget:set_value(uptime_seconds)
end

return popup