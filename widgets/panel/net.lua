local net = {}

local awful = require("awful")
local config = require("config")
local wibox = require("wibox")
local widget = require("widgets/value_monitor")

local string_format = string.format
local string_match = string.match

local widget_config = config.widgets.net

local download_monitor = ValueMonitor:new {
    label = "D"
}

local upload_monitor = ValueMonitor:new {
    label = "U"
}

local function update_widget_value(widget, new_usage_bytes)
    local last_value = widget.last_value or new_usage_bytes
    local usage_bytes = (new_usage_bytes - last_value) / widget_config.update_time_secs

    return {
        formatted = string_format("%.02f MB/s", usage_bytes / 1024 / 1024)
    }
end

download_monitor.on_set = update_widget_value
upload_monitor.on_set = update_widget_value

net.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    download_monitor.textbox,
    {
        layout = wibox.container.margin,
        left = widget_config.space_between_stats,
        upload_monitor.textbox,
    },
}

awful.widget.watch("cat /proc/net/dev", widget_config.update_time_secs, function(widget, stdout)
    local raw_stats = {
        string_match(stdout,
            widget_config.interface .. ":%s+(%d+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+(%d+)")
    }

    download_monitor:set_value(raw_stats[1])
    upload_monitor:set_value(raw_stats[2])
end)

return net