local beautiful = require("beautiful")
local wibox = require("wibox")

ValueMonitor = {}
ValueMonitor.__index = ValueMonitor

local string_format = string.format

-- Creates a new value monitor.
--
-- Possible table contents for the values parameter:
-- label: The name to display next to the value.
-- label_color: The color of the label.
-- value_color: The color of the value.
-- textbox: The textbox widget to place generated text in.
-- updated_value(values, value, last_value):
--   This function allows an update to be halted based off the value of the return boolean,
--   and allows you to apply certain parameters to a specific update by setting table
--   values in the "values" parameter.
--   
--   The current list of update-specific values that can be used are as follows:
--     label,
--     label_color,
--     value_color
-- format_value(value): The function to format raw values into a more readable format.
-- is_formatted_equal(value, last):
--   Called after formatting a value to see if it's the same as the previous formatted value.
--   A textbox update will be halted if it returns false.
-- last_value: The raw value that was used for the last update.
-- last_formatted_value: The formatted value used for the last update.
function ValueMonitor:new(values)
    local value_monitor = {
        label = values.label or "Label",
        label_color = values.label_color or beautiful.widget_label,
        value_color = values.value_color or beautiful.fg_normal,
        textbox = values.textbox or wibox.widget.textbox(),
        last_value = values.last_value or nil,
        last_formatted_value = values.last_formatted_value or nil,
    }

    setmetatable(value_monitor, ValueMonitor)
    return value_monitor
end

-- Updates the value of the monitor and caches it.
--
-- The contained textbox's markup will not be updated if the provided
-- value hasn't changed, as updating a textbox's markup is expensive.
function ValueMonitor:set_value(value)
    local update_info = self:on_set(value)
    if update_info.halt then return end

    local formatted_value = update_info.formatted or value

    if self:is_formatted_equal(formatted_value) then
        return
    end

    local text = string_format(
        "<span color=\"%s\">%s</span> <span color=\"%s\">%s</span>",
        update_info.label_color or self.label_color,
        update_info.label or self.label,
        update_info.value_color or self.value_color,
        formatted_value
    )

    self.textbox.markup = text

    self.last_value = value
    self.last_formatted_value = formatted_value
end

function ValueMonitor:on_set()
    return {}
end

function ValueMonitor:is_formatted_equal(value)
    return value == self.last_formatted_value
end