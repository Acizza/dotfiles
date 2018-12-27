local volume_widget = {}

local awful = require("awful")
local beautiful = require("beautiful")
local config = require("config")
local gears = require("gears")
local wibox = require("wibox")
local widget = require("widgets/value_monitor")
local audio_module = require("module/audio")

local widget_config = config.widgets.volume

local string_match = string.match
local string_format = string.format

local run_command = "amixer sget " .. config.audio_source

local monitor_widget = ValueMonitor:new {
    label = "VOL",
    last_value = {
        volume = 0,
        muted = false,
    }
}

function monitor_widget:on_set(status)
    local has_changed = status.volume ~= self.last_value.volume or
                        status.muted ~= self.last_value.muted

    if not has_changed then
        return { halt = true }
    end

    local values = {
        formatted = string_format("%d%%", status.volume)
    }

    if status.muted then
        values.label_color = beautiful.warning_color
        values.value_color = beautiful.warning_color
    end

    return values
end

function monitor_widget:is_formatted_equal()
    return false
end

volume_widget.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    buttons = gears.table.join(
        awful.button({}, 3, audio_module.toggle_volume_mute),
        awful.button({}, 4, audio_module.increment_volume),
        awful.button({}, 5, audio_module.decrement_volume)
    ),
    monitor_widget.textbox,
}

local function update_from_output(stdout)
    local volume_info = { string_match(stdout, "%[(%d+)%%%] %[(%a+)%]") }

    local status = {
        volume = volume_info[1] or 0,
        muted = volume_info[2] == nil and true or volume_info[2] == "off",
    }

    monitor_widget:set_value(status)
end

function volume_widget.update()
    awful.spawn.easy_async(run_command, update_from_output)
end

awful.widget.watch(run_command, widget_config.update_time_secs, function(_, stdout)
    update_from_output(stdout)
end)

audio_module.add_volume_set_hook(volume_widget.update)

return volume_widget