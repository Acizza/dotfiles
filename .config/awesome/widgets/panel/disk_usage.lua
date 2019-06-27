local disk_usage = {}

local awful = require("awful")
local config = require("config")
local wibox = require("wibox")
local widget = require("widgets/value_monitor")

local widget_config = config.widgets.disk_usage

local string_format = string.format
local string_match = string.match

local run_command = "df -k " .. table.concat(widget_config.partitions, " ")
local partition_data = {}

for _,partition in pairs(widget_config.partitions) do
    local monitor = ValueMonitor:new {
        label = partition
    }

    monitor.on_set = function(_, available_kb)
        local usage_gb = available_kb / 1024 / 1024
        
        return {
            formatted = string_format("%0.02f GB", usage_gb)
        }
    end

    partition_data[#partition_data + 1] = {
        partition = partition,
        monitor_widget = monitor,
    }
end

do
    local widgets = {}
    local is_first_index = true

    for _,data in pairs(partition_data) do
        local widget

        if not is_first_index then
            widget = {
                widget = wibox.container.margin,
                left = widget_config.space_between_partitions,
                {
                    layout = wibox.layout.fixed.horizontal,
                    data.monitor_widget.textbox,
                }
            }
        else
            widget = data.monitor_widget.textbox
        end

        widgets[#widgets + 1] = widget
        is_first_index = false
    end

    disk_usage.widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        table.unpack(widgets)
    }
end

awful.widget.watch(run_command, widget_config.update_time_secs, function(widget, stdout)
    for _,data in pairs(partition_data) do
        local usage_info = {
            string_match(stdout, "%d+%s-(%d+)%s-%d+%%%s-" .. data.partition .. "\n")
        }

        local available_kb = usage_info[1]
        data.monitor_widget:set_value(available_kb)
    end
end)

return disk_usage