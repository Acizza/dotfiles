local cpu_usage = {}

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local widget = require("widgets/value_monitor")

local usage = require("widgets/panel/cpu_usage/usage")
local popup = require("widgets/panel/cpu_usage/popup")

cpu_usage.update_time_secs = 1.5

local string_format = string.format
local string_match = string.match
local string_gmatch = string.gmatch

local monitor_widget = ValueMonitor:new {
    label = "CPU",
    format_value = function(value)
        return string_format("%.01f%%", value)
    end,
}

cpu_usage.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    buttons = gears.table.join(
        awful.button({}, 1, function() popup:toggle() end)
    ),
    monitor_widget.textbox,
}

awful.widget.watch("cat /proc/stat", cpu_usage.update_time_secs, function(_, stdout)
    local jiffies = string_gmatch(string_match(stdout, "cpu (.-)\n"), "%d+")
    local usage_pcnt = usage.calculate_core_usage(0, jiffies)

    monitor_widget:set_value(usage_pcnt)

    if popup:is_open() then
        popup:update_usages(stdout)
    end
end)

return cpu_usage