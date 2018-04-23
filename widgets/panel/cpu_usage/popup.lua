local popup = {}

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local usage = require("widgets/panel/cpu_usage/usage")

local string_format = string.format
local string_gmatch = string.gmatch

local popup = WidgetPopup:new {
    width = 200,
    height = 300,
}

popup.usage_monitors = {}

function popup:initialize()
    awful.spawn.easy_async("nproc", function(num_cores)
        -- TODO: don't use magic numbers
        self.wibar.height = 60 + (beautiful.get_font_height(beautiful.font) + 2.5) * num_cores
        self:set_position()

        local cpu_usage_widgets = {}

        for i = 1, num_cores do
            local monitor = ValueMonitor:new {
                label = "CPU " .. i,
                format_value = function(value)
                    return string_format("%.01f%%", value)
                end,
            }

            monitor:set_value("0")
            monitor.textbox.align = "center"

            popup.usage_monitors[i] = monitor
            cpu_usage_widgets[i] = monitor.textbox
        end

        self:setup({
            layout = wibox.layout.fixed.vertical,
            {
                layout = wibox.container.margin,
                top = 20,
                bottom = 20,
                {
                    markup = "<b>CPU Usage</b>",
                    align = "center",
                    widget = wibox.widget.textbox(),
                }
            },
            unpack(cpu_usage_widgets),
        })
    end)
end

function popup:update_usages(stat_output)
    local cpu_lines = string_gmatch(stat_output, "cpu(%d+)%s(.-)\n")

    for core_num,cpu_line in cpu_lines do
        local jiffies = string_gmatch(cpu_line, "%d+")
        local usage_pcnt = usage.calculate_core_usage(core_num, jiffies)

        self.usage_monitors[1 + core_num]:set_value(usage_pcnt)
    end
end

return popup