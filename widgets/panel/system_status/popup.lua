local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

require("widgets/value_monitor")
require("widgets/popup")

local os_date = os.date
local io_open = io.open
local string_match = string.match

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

    self.kernel_widget = ValueMonitor:new {
        label = "Kernel",
    }

    self:update_kernel_version()

    self.graphics_driver_ver_widget = ValueMonitor:new {
        label = "GPU Driver",
    }

    self:update_graphics_driver_ver()

    self:setup({
        layout = wibox.layout.flex.vertical,
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
            widget = self.uptime_widget.textbox,
        },
        {
            align = "center",
            widget = self.kernel_widget.textbox,
        },
        {
            align = "center",
            widget = self.graphics_driver_ver_widget.textbox,
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

function popup:update_kernel_version()
    awful.spawn.easy_async("uname -r", function(stdout)
        self.kernel_widget:set_value(stdout)
    end)
end

function popup:update_graphics_driver_ver()
    awful.spawn.easy_async("modinfo nvidia", function(stdout, _, _, exit_code)
        if exit_code ~= 0 then
            self.graphics_driver_ver_widget:set_value("unknown")
            return
        end

        local version = string_match(stdout, "version:%s+(.-)\n")
        self.graphics_driver_ver_widget:set_value(version)
    end)
end

return popup