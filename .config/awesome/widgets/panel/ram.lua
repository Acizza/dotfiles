local ram = {}

local awful = require("awful")
local config = require("config")
local wibox = require("wibox")
local widget = require("widgets/value_monitor")

local widget_config = config.widgets.ram

local math_max = math.max
local math_floor = math.floor
local tonumber = tonumber
local string_match = string.match
local string_format = string.format

local monitor_widget = ValueMonitor:new {
    label = "RAM"
}

function monitor_widget:on_set(usage_data)
    local usage_gb = usage_data.used_kb / 1024 / 1024
    local usage_pcnt = usage_data.used_kb / math_max(usage_data.total, 1.0) * 100

    return {
        formatted = string_format("%.03f GB (%d%%)", usage_gb, math_floor(usage_pcnt))
    }
end

ram.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    monitor_widget.textbox,
}

awful.widget.watch("free", widget_config.update_time_secs, function(widget, stdout)
    -- This pattern grabs the "total" and "available" fields
    local ram_info = { string_match(stdout, "Mem:%s-(%d+).-(%d+)\n") }
    ram_info.total = tonumber(ram_info[1])
    ram_info.used_kb = ram_info.total - ram_info[2]

    monitor_widget:set_value(ram_info)
end)

return ram