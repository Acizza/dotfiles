local cpu_usage = {}

local awful = require("awful")
local beautiful = require("beautiful")
local config = require("config")
local gears = require("gears")
local wibox = require("wibox")
local widget = require("widgets/value_monitor")

local usage = require("widgets/panel/cpu_usage/usage")
local popup = require("widgets/panel/cpu_usage/popup")

local widget_config = config.widgets.cpu_usage

local string_format = string.format
local string_match = string.match
local string_gmatch = string.gmatch

local monitor_widget = ValueMonitor:new {
    label = "CPU"
}

function monitor_widget:on_set(usage_pcnt)
    local values = {
        formatted = string_format("%.01f%%", usage_pcnt)
    }

    if usage_pcnt >= 90 then
        values.value_color = beautiful.critical_color
    elseif usage_pcnt >= 75 then
        values.value_color = beautiful.warning_color
    end

    return values
end

cpu_usage.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    buttons = gears.table.join(
        awful.button({}, 1, function() popup:toggle() end)
    ),
    monitor_widget.textbox,
}

awful.widget.watch("cat /proc/stat", widget_config.update_time_secs, function(_, stdout)
    local jiffies = {
        string_match(stdout,
            "cpu  (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-)\n")
    }

    local usage_pcnt = usage.calculate_core_usage(0, jiffies)

    monitor_widget:set_value(usage_pcnt)

    if popup:is_open() then
        popup:update_usages(stdout)
    end
end)

return cpu_usage