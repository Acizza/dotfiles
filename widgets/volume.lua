local volume = {}

local awful = require("awful")
local config = require("config")
local wibox = require("wibox")
local widget = require("widgets/widget")

volume.update_time_secs = 1
volume.muted_color = "#ffe100"

local last_status = {
    volume = 0,
    muted = false,
}

local monitor_widget = ValueMonitor:new {
    label = "VOL",
    format_value = function(status)
        return string.format("%d%%", status.volume)
    end,
    updated_value = function(values, status, last_status)
        local has_changed = status.volume ~= last_status.volume or
                            status.muted ~= last_status.muted

        if has_changed and status.muted then
            values.label_color = volume.muted_color
            values.value_color = volume.muted_color
        end

        return has_changed
    end,
    is_formatted_equal = function() return false end,
    last_value = {
        volume = 0,
        muted = false,
    }
}

volume.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    monitor_widget.textbox,
}

-- TODO: hook into audio lower / raise keys and perform this once / infrequently
awful.widget.watch("amixer sget " .. config.audio_source, volume.update_time_secs, function(_, stdout)
    local volume_info = table.pack(string.match(stdout, "%[(%d+)%%%] %[(%a+)%]"))

    local status = {
        volume = volume_info[1],
        muted = volume_info[2] == "off"
    }

    monitor_widget:set_value(status)
end)

return volume