local cpu_usage = {}

local awful = require("awful")
local wibox = require("wibox")
local widget = require("widgets/widget")

cpu_usage.update_time_secs = 1.5

local monitor_widget = ValueMonitor:new {
    label = "CPU",
    format_value = function(value)
        return string.format("%.01f%%", value)
    end,
}

cpu_usage.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    monitor_widget.textbox,
}

local last_state = {
    total_jiffies = 0,
    work_jiffies = 0,
}

awful.widget.watch("cat /proc/stat", cpu_usage.update_time_secs, function(widget, stdout)
    -- https://stackoverflow.com/a/3017438
    local state = {
        total_jiffies = 0,
        work_jiffies = 0,
    }

    local index = 1
    
    for jiffie in stdout:match("cpu (.-)\n"):gmatch("%d+") do
        state.total_jiffies = state.total_jiffies + jiffie

        if index <= 3 then
            state.work_jiffies = state.work_jiffies + jiffie
        end

        index = index + 1
    end

    local total_over_period = state.total_jiffies - last_state.total_jiffies
    local work_over_period = state.work_jiffies - last_state.work_jiffies

    local usage = work_over_period / total_over_period * 100
    monitor_widget:set_value(usage)

    last_state = state
end)

return cpu_usage