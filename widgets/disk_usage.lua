local disk_usage = {}

local awful = require("awful")
local wibox = require("wibox")
local widget = require("widgets/widget")

disk_usage.partitions = { "/", "/home" }
disk_usage.update_time_secs = 30
disk_usage.space_between_partitions = 20

local run_command = "df -k " .. table.concat(disk_usage.partitions, " ")
local partition_data = {}

for _,partition in pairs(disk_usage.partitions) do
    partition_data[#partition_data + 1] = {
        partition = partition,
        monitor_widget = ValueMonitor:new {
            label = partition,
            format_value = function(available_kb)
                local usage_gb = available_kb / 1024 / 1024
                return string.format("%0.02f GB", usage_gb)
            end,
        },
    }
end

do
    local widgets = {}
    local is_first_index = true

    for _,data in pairs(partition_data) do
        if not is_first_index then
            table.insert(widgets, {
                widget = wibox.container.margin,
                left = disk_usage.space_between_partitions,
                {
                    layout = wibox.layout.fixed.horizontal,
                    data.monitor_widget.textbox,
                }
            })
        else
            table.insert(widgets, data.monitor_widget.textbox)
        end

        is_first_index = false
    end

    disk_usage.widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        unpack(widgets)
    }
end

awful.widget.watch(run_command, disk_usage.update_time_secs, function(widget, stdout)
    for _,data in pairs(partition_data) do
        local usage_info = table.pack(
            stdout:match("%d+%s-(%d+)%s-%d+%%%s-" .. data.partition .. "\n"))

        local available_kb = usage_info[1]
        data.monitor_widget:set_value(available_kb)
    end
end)

return disk_usage