local net = {}

local awful = require("awful")
local config = require("config")
local wibox = require("wibox")
local widget = require("widgets/value_monitor")

local string_format = string.format
local string_match = string.match

local widget_config = config.widgets.net

local net_monitor = ValueMonitor:new {
    label = "NET",
    last_value = {0, 0},
}

local function simplify_size(bytes)
    bytes = bytes / 1024

    if bytes < 1024 then
        return {
            value = bytes,
            symbol = "kb"
        }
    end

    bytes = bytes / 1024

    return {
        value = bytes,
        symbol = "mb"
    }
end

net_monitor.on_set = function(widget, new_bytes)
    local usage_down = (new_bytes[1] - widget.last_value[1]) / widget_config.update_time_secs
    local usage_up = (new_bytes[2] - widget.last_value[2]) / widget_config.update_time_secs

    local down = simplify_size(usage_down)
    local up = simplify_size(usage_up)

    return {
        formatted = string_format("%.01f %s / %.01f %s",
            down.value,
            down.symbol,
            up.value,
            up.symbol)
    }
end

net.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    net_monitor.textbox,
}

awful.widget.watch("cat /proc/net/dev", widget_config.update_time_secs, function(widget, stdout)
    local raw_stats = {
        string_match(stdout,
            widget_config.interface .. ":%s+(%d+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+(%d+)")
    }

    net_monitor:set_value(raw_stats)
end)

return net