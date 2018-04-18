local volume_widget = {}

local awful = require("awful")
local config = require("config")
local wibox = require("wibox")
local widget = require("widgets/widget")

volume_widget.update_time_secs = 15
volume_widget.muted_color = "#ffe100"

local run_command = "amixer sget " .. config.audio_source

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
            values.label_color = volume_widget.muted_color
            values.value_color = volume_widget.muted_color
        end

        return has_changed
    end,
    is_formatted_equal = function() return false end,
    last_value = {
        volume = 0,
        muted = false,
    }
}

volume_widget.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    monitor_widget.textbox,
}

local function update_from_output(stdout)
    local volume_info = table.pack(string.match(stdout, "%[(%d+)%%%] %[(%a+)%]"))

    local status = {
        volume = volume_info[1],
        muted = volume_info[2] == "off"
    }

    monitor_widget:set_value(status)
end

function volume_widget.update()
    awful.spawn.easy_async(run_command, function(stdout)
        update_from_output(stdout)
    end)
end

awful.widget.watch(run_command, volume_widget.update_time_secs, function(_, stdout)
    update_from_output(stdout)
end)

return volume_widget