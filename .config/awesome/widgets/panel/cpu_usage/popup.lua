local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local usage = require("widgets/panel/cpu_usage/usage")

local string_format = string.format
local string_match = string.match

local dpi = require("beautiful.xresources").apply_dpi

local popup = WidgetPopup:new {
    width = 100,
    height = 150,
}

popup.usage_monitors = {}

local total_cores = 0

function popup:initialize()
    awful.spawn.easy_async("nproc", function(num_cores)
        -- TODO: don't use magic numbers
        self.wibar.height = 60 + (beautiful.get_font_height(beautiful.font) + 2.5) * num_cores
        self:set_position()

        total_cores = num_cores

        local cpu_usage_widgets = {}

        for i = 1, num_cores do
            local monitor = ValueMonitor:new {
                label = "CPU " .. i
            }

            monitor.on_set = function(_, value)
                return { formatted = string_format("%.01f%%", value) }
            end

            monitor:set_value("0")
            monitor.textbox.align = "center"

            popup.usage_monitors[i] = monitor
            cpu_usage_widgets[i] = monitor.textbox
        end

        self:setup({
            layout = wibox.layout.fixed.vertical,
            {
                layout = wibox.container.margin,
                top = dpi(10),
                bottom = dpi(10),
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
    for core = 1, total_cores do
        local jiffies = {
            string_match(stat_output,
                "cpu" .. core - 1 .. " (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-)\n")
        }

        local usage_pcnt = usage.calculate_core_usage(core, jiffies)
        self.usage_monitors[core]:set_value(usage_pcnt)
    end
end

return popup