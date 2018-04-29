local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local file = require("util/file")

require("widgets/value_monitor")
require("widgets/popup")

local os_date = os.date
local io_open = io.open
local string_match = string.match

local dpi = require("beautiful.xresources").apply_dpi

local popup = WidgetPopup:new {
    width = 150,
    height = 100,
}

function popup:initialize()
    self.uptime_timer = gears.timer {
        timeout = 1,
        autostart = false,
        callback = function() popup:update_uptime() end,
    }
    
    self.uptime_widget = ValueMonitor:new {
        label = "Uptime"
    }

    self.uptime_widget.on_set = function(_, time)
        return { formatted = os_date("!%H:%M:%S", time) }
    end

    self.kernel_widget = ValueMonitor:new {
        label = "Kernel",
    }

    self:update_kernel_version()

    self.graphics_driver_ver_widget = ValueMonitor:new {
        label = "GPU Driver",
    }

    self:update_graphics_driver_ver()

    self.lua_runtime_widget = ValueMonitor:new {
        label = "Runtime",
    }

    self:update_lua_runtime()

    self:setup({
        layout = wibox.layout.fixed.vertical,
        {
            layout = wibox.container.margin,
            top = dpi(10),
            bottom = dpi(10),
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
        {
            align = "center",
            widget = self.lua_runtime_widget.textbox,
        }
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
    local uptime_contents = file.read("/proc/uptime")
    local uptime_seconds = uptime_contents:sub(1, uptime_contents:find(' '))
    
    self.uptime_widget:set_value(uptime_seconds)
end

function popup:update_kernel_version()
    awful.spawn.easy_async("uname -r", function(stdout)
        self.kernel_widget:set_value(stdout:sub(1, #stdout - 1))
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

function popup:update_lua_runtime()
    if type(jit) == "table" then
        local version = jit.version
        local extra_tag_pos = version:find('-')

        if extra_tag_pos ~= nil then
            version = version:sub(1, extra_tag_pos - 1)
        end

        self.lua_runtime_widget:set_value(version)
    else
        self.lua_runtime_widget:set_value(_VERSION)
    end
end

return popup