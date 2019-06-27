local cpu_usage = {
    total_cores = 0,
}

local awful = require("awful")
local beautiful = require("beautiful")
local config = require("config")
local wibox = require("wibox")
local widget = require("widgets/value_monitor")

local usage = require("widgets/panel/cpu_usage/usage")

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
    monitor_widget.textbox,
}

local popup = {
    usage_monitors = {},
    widget = {},
}

awful.widget.watch("cat /proc/stat", widget_config.update_time_secs, function(_, stdout)
    local jiffies = {
        string_match(stdout,
            "cpu  (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-)\n")
    }

    local usage_pcnt = usage.calculate_core_usage(0, jiffies)

    monitor_widget:set_value(usage_pcnt)

    if popup.widget.visible then
        cpu_usage._update_popup(stdout)
    end
end)

awful.spawn.easy_async("nproc", function(num_cores)
    cpu_usage.total_cores = num_cores

    local usage_widgets = {}

    for i = 1, num_cores do
        local monitor = ValueMonitor:new {
            label = i
        }

        monitor.on_set = function(_, value)
            return { formatted = string_format("%.01f%%", value) }
        end

        monitor:set_value("0")
        monitor.textbox.align = "center"

        popup.usage_monitors[i] = monitor
        usage_widgets[i] = monitor.textbox
    end

    popup.widget = awful.popup {
        widget = wibox.widget {
            {
                layout = wibox.layout.fixed.vertical,
                {
                    layout = wibox.container.margin,
                    bottom = 10,
                    {
                        markup = "<b>CPU Usage</b>",
                        align = "center",
                        widget = wibox.widget.textbox,
                    },
                },
                table.unpack(usage_widgets),
            },
            margins = 10,
            widget = wibox.container.margin,
        },
        opacity = config.panel_opacity,
        ontop = true,
        border_width = 1,
        visible = false,
        hide_on_right_click = true,
    }
    
    popup.widget:bind_to_widget(cpu_usage.widget)
end)

cpu_usage._update_popup = function(stdout)
    for core = 1, cpu_usage.total_cores do
        local jiffies = {
            string_match(stdout,
                "cpu" .. core - 1 .. " (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-) (%d-)\n")
        }

        local usage_pcnt = usage.calculate_core_usage(core, jiffies)
        popup.usage_monitors[core]:set_value(usage_pcnt)
    end
end

return cpu_usage